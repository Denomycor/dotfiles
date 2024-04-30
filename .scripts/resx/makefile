#vars
TARGET := placeholder
COMMIT := _$(shell git rev-parse --short HEAD) #$(shell date +_%H_%M_%d_%m_%y) 
DEPENDENCIES := 
 
EXTENSION := cpp
HEADEREXT := h
CC := g++

INCLUDEDIR := include
OBJDIR := obj
SRCDIR := src
BINDIR := bin

SRCFILES := $(shell find $(SRCDIR) -type f \( -iname "*.$(EXTENSION)" \) -exec basename \{} \;)
HEADERFILES := $(shell find $(INCLUDEDIR) -type f \( -iname "*.$(HEADEREXT)" \) -exec basename \{} \;)
OBJFILES := $(SRCFILES:%.$(EXTENSION)=%.o)

MACROS :=
BASEFLAGS := $(addprefix -D ,$(MACROS)) --std=c++17 -Wall
DEBUGFLAGS := $(BASEFLAGS) -g
RELEASEFLAGS := $(BASEFLAGS) -O2

#accumulators
TERM :=
FLAGS :=

#builds
standard: FLAGS = $(BASEFLAGS)
standard: TERM = _standard
standard: clean setup $(TARGET)

debug: FLAGS = $(DEBUGFLAGS)
debug: TERM = _debug
debug: clean setup $(TARGET)

release: FLAGS = $(RELEASEFLAGS)
release: TERM = _release
release: clean setup $(TARGET)

#build target
$(TARGET): $(OBJFILES)
	$(CC) $(FLAGS) $(addprefix $(OBJDIR)/,$^) -o $(BINDIR)/$@$(COMMIT)$(TERM) $(DEPENDENCIES)


#compile object files
%.o: $(SRCDIR)/%.$(EXTENSION)
	$(CC) $(FLAGS) -o $(addprefix $(OBJDIR)/,$@) -c $^ -I $(INCLUDEDIR)
%.o: $(SRCDIR)/**/%.$(EXTENSION)
	$(CC) $(FLAGS) -o $(addprefix $(OBJDIR)/,$@) -c $^ -I $(INCLUDEDIR)


#clean directory
clean:
	@rm -rf $(OBJDIR)
	@rm -rf $(BINDIR)


#setup directory
setup: 
	@mkdir -p $(OBJDIR)
	@mkdir -p $(BINDIR)


#get todo list
todo:
	@grep -R TODO -n | tr -s ' ' | grep -v makefile

#print makefile info
info:
		@echo TARGET = $(TARGET)
		@echo EXTENSION = $(EXTENSION)
		@echo INCLUDEDIR = $(INCLUDEDIR)
		@echo OBJDIR = $(OBJDIR)
		@echo SRCDIR = $(SRCDIR)
		@echo BINDIR = $(BINDIR)
		@echo SRCFILES = $(SRCFILES)
		@echo HEADERFILES = $(HEADERFILES)
		@echo MACROS = $(MACROS)
		@echo BASEFLAGS = $(BASEFLAGS)
		@echo DEBUGFLAGS = $(DEBUGFLAGS)
		@echo RELEASEFLAGS = $(RELEASEFLAGS)
		@echo CC = $(CC)

