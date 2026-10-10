#!/usr/bin/env python3
"""
Minimal org.freedesktop.Notifications DBus server.

Replaces the system notification daemon (dunst/mako/etc). Every call to
Notify() is stored, printed as a JSON array to stdout (matching the
deflisten contract eww expects) and automatically expired after a fixed
5 second lifetime, regardless of the expire_timeout the client asked for.

If the client passes a "sound-file" hint (and not "suppress-sound"),
it's played via paplay. Themed "sound-name" lookups aren't supported
since no sound theme is assumed to be installed.

Some clients (e.g. Discord) don't pass an icon path at all -- they embed
the raw pixel data via the "image-data"/"icon_data" hint instead. That's
decoded with GdkPixbuf and written out as a PNG under /tmp so the eww
`image` widget (which only takes a file path) has something to point at.

Do-not-disturb is controlled out-of-band over a unix socket (see the
`dnd` CLI) rather than DBus, since it's a local-only concern with no
freedesktop notifications spec equivalent. When dnd is on, incoming
notifications are neither displayed nor announced with a sound -- they're
acknowledged to the caller (a valid id is returned) and otherwise dropped.
`mute`/`unmute` just silence/restore the sound while leaving popups on.
"""

import json
import os
import socket
import subprocess
import sys
import tempfile

import gi

gi.require_version("GLib", "2.0")
gi.require_version("Gio", "2.0")
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import Gio, GLib, GdkPixbuf

BUS_NAME = "org.freedesktop.Notifications"
OBJECT_PATH = "/org/freedesktop/Notifications"
LIFETIME_MS = 5000
SOCKET_PATH = os.path.join(
    os.environ.get("XDG_RUNTIME_DIR", tempfile.gettempdir()), "eww-notification-daemon.sock"
)

INTROSPECTION_XML = """
<node>
  <interface name="org.freedesktop.Notifications">
    <method name="GetCapabilities">
      <arg direction="out" name="capabilities" type="as"/>
    </method>
    <method name="Notify">
      <arg direction="in"  name="app_name"    type="s"/>
      <arg direction="in"  name="replaces_id" type="u"/>
      <arg direction="in"  name="app_icon"    type="s"/>
      <arg direction="in"  name="summary"     type="s"/>
      <arg direction="in"  name="body"        type="s"/>
      <arg direction="in"  name="actions"     type="as"/>
      <arg direction="in"  name="hints"       type="a{sv}"/>
      <arg direction="in"  name="expire_timeout" type="i"/>
      <arg direction="out" name="id"          type="u"/>
    </method>
    <method name="CloseNotification">
      <arg direction="in" name="id" type="u"/>
    </method>
    <method name="GetServerInformation">
      <arg direction="out" name="name"         type="s"/>
      <arg direction="out" name="vendor"       type="s"/>
      <arg direction="out" name="version"      type="s"/>
      <arg direction="out" name="spec_version" type="s"/>
    </method>
    <signal name="NotificationClosed">
      <arg name="id"     type="u"/>
      <arg name="reason" type="u"/>
    </signal>
    <signal name="ActionInvoked">
      <arg name="id"     type="u"/>
      <arg name="action_key" type="s"/>
    </signal>
  </interface>
</node>
"""

notifications = {}
next_id = 1
ICON_DIR = tempfile.gettempdir()
dnd_enabled = False
muted = False


def handle_dnd_command(fd, condition, sock):
    global dnd_enabled, muted

    conn, _ = sock.accept()
    try:
        command = conn.recv(64).decode().strip()
        if command == "on":
            dnd_enabled = True
            reply = "dnd on"
        elif command == "off":
            dnd_enabled = False
            reply = "dnd off"
        elif command == "mute":
            muted = True
            reply = "muted"
        elif command == "unmute":
            muted = False
            reply = "unmuted"
        elif command == "status":
            reply = json.dumps({"dnd": dnd_enabled, "muted": muted})
        else:
            reply = f"unknown command: {command}"
        conn.sendall((reply + "\n").encode())
    finally:
        conn.close()
    return True


def start_dnd_socket():
    try:
        os.remove(SOCKET_PATH)
    except OSError:
        pass
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.bind(SOCKET_PATH)
    sock.listen(5)
    sock.setblocking(False)
    GLib.io_add_watch(sock.fileno(), GLib.IO_IN, handle_dnd_command, sock)
    return sock


def extract_icon(notif_id, hints, app_icon):
    image_data = hints.get("image-data") or hints.get("icon_data")
    if image_data:
        width, height, rowstride, has_alpha, bits_per_sample, channels, data = image_data
        pixbuf = GdkPixbuf.Pixbuf.new_from_bytes(
            GLib.Bytes.new(bytes(data)),
            GdkPixbuf.Colorspace.RGB,
            has_alpha,
            bits_per_sample,
            width,
            height,
            rowstride,
        )
        path = os.path.join(ICON_DIR, f"eww-notif-icon-{notif_id}.png")
        pixbuf.savev(path, "png", [], [])
        return path

    icon = hints.get("image-path") or hints.get("image_path") or app_icon
    if icon.startswith("file://"):
        icon = icon[len("file://") :]
    return icon


def emit_state():
    ordered = sorted(notifications.values(), key=lambda n: n["id"])
    print(json.dumps(ordered), flush=True)


def close_notification(connection, notif_id, reason):
    if notif_id not in notifications:
        return
    icon = notifications[notif_id]["icon"]
    if icon.startswith(os.path.join(ICON_DIR, "eww-notif-icon-")):
        try:
            os.remove(icon)
        except OSError:
            pass
    del notifications[notif_id]
    emit_state()
    connection.emit_signal(
        None,
        OBJECT_PATH,
        BUS_NAME,
        "NotificationClosed",
        GLib.Variant("(uu)", (notif_id, reason)),
    )


def handle_method_call(
    connection, sender, object_path, interface_name, method_name, parameters, invocation
):
    global next_id

    if method_name == "GetCapabilities":
        invocation.return_value(
            GLib.Variant("(as)", (["body", "actions", "icon-static", "sound"],))
        )
        return

    if method_name == "Notify":
        (app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout) = (
            parameters.unpack()
        )

        notif_id = replaces_id if replaces_id else next_id
        if not replaces_id:
            next_id += 1

        if dnd_enabled:
            invocation.return_value(GLib.Variant("(u)", (notif_id,)))
            return

        icon = extract_icon(notif_id, hints, app_icon)

        notifications[notif_id] = {
            "id": notif_id,
            "app_name": app_name,
            "summary": summary,
            "body": body,
            "icon": icon,
        }
        emit_state()

        if not muted and not hints.get("suppress-sound"):
            sound_file = hints.get("sound-file")
            if sound_file:
                if sound_file.startswith("file://"):
                    sound_file = sound_file[len("file://") :]
                subprocess.Popen(
                    ["paplay", sound_file],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )

        GLib.timeout_add(LIFETIME_MS, lambda: close_notification(connection, notif_id, 1) or False)

        invocation.return_value(GLib.Variant("(u)", (notif_id,)))
        return

    if method_name == "CloseNotification":
        (notif_id,) = parameters.unpack()
        close_notification(connection, notif_id, 3)
        invocation.return_value(None)
        return

    if method_name == "GetServerInformation":
        invocation.return_value(
            GLib.Variant("(ssss)", ("eww-notify", "eww", "1.0", "1.2"))
        )
        return

    invocation.return_dbus_error(
        "org.freedesktop.DBus.Error.UnknownMethod", f"Unknown method {method_name}"
    )


def on_bus_acquired(connection, name):
    node_info = Gio.DBusNodeInfo.new_for_xml(INTROSPECTION_XML)
    interface_info = node_info.interfaces[0]
    connection.register_object(
        OBJECT_PATH,
        interface_info,
        handle_method_call,
        None,
        None,
    )


def on_name_lost(connection, name):
    sys.stderr.write(
        "notification_daemon: could not acquire org.freedesktop.Notifications "
        "(another notification daemon is likely running)\n"
    )
    sys.exit(1)


def main():
    emit_state()
    start_dnd_socket()
    Gio.bus_own_name(
        Gio.BusType.SESSION,
        BUS_NAME,
        Gio.BusNameOwnerFlags.NONE,
        on_bus_acquired,
        None,
        on_name_lost,
    )
    GLib.MainLoop().run()


if __name__ == "__main__":
    main()
