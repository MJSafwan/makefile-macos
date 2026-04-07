GUI_FRAMEWORKS = IOKit Cocoa OpenGL CoreVideo

CC = clang
IDIR = ./include
SDIR = ./src
BDIR = ./build
ODIR = $(BDIR)/obj
LDIR = ./lib
BINDIR = $(BDIR)/bin
LIBS = m
DLL_EXT = dylib
STATIC_EXT = a
FRAMEWORKS = 
CFLAGS = -Wall -Wextra -pedantic -I$(IDIR) -std=c99 
TARGET = main

all : $(TARGET)

setup:
	@mkdir -p $(SDIR)
	@mkdir -p $(IDIR)
	@mkdir -p $(LDIR)
	@echo "#include <stdio.h>\n\nint main(void) {\n    printf(\"Hello, World!\");\n    return 0;\n}">> $(SDIR)/$(TARGET).c

clean : 
	@rm -rf $(BDIR)

run : $(TARGET)
	@$(BINDIR)/$(TARGET)

info :
	@echo "Source dir    : $(SDIR)"
	@echo "Include dir   : $(IDIR)"
	@echo "Lib dir       : $(LDIR)"
	@echo "Build dir     : $(BDIR)"
	@echo "Object dir    : $(ODIR)"
	@echo "Binary dir    : $(BINDIR)"
	@echo "Source files  : $(SRC)"
	@echo "Header files  : $(NEAT_DEPS)"
	@echo "Libs          : $(LIBS)"
	@echo "Frameworks    : $(FRAMEWORKS)"
	@echo "CFLAGS        : $(CFLAGS)"
	@echo "FINAL_CFLAGS  : $(FINAL_CFLAGS)"

.PHONY: all clean run info setup

_SRC = $(shell find $(SDIR) -type f -name "*.c")
__SRC = $(shell echo $(_SRC) | tr "/" " ")
SRC = $(filter %.c, $(__SRC))
VPATH = $(shell find $(SDIR) -type d)

DEPS = $(shell find $(IDIR) -type f -name "*.h")
OBJ = $(patsubst %.c, $(ODIR)/%.o, $(SRC))

_DEPS = $(shell echo $(DEPS) | tr "/" " ")
NEAT_DEPS = $(filter %.h, $(_DEPS))
_LIBS = $(shell find $(LDIR) -type f -name "*.$(DLL_EXT)")
_LIBS += $(shell find $(LDIR) -type f -name "*.$(STATIC_EXT)")

_LIBS1 = $(shell echo $(_LIBS) | tr "/" " ")
_LIBS1.1 = $(filter %.$(DLL_EXT) %.$(STATIC_EXT), $(_LIBS1)) 

_LIBS2 = $(patsubst %.$(STATIC_EXT),%, $(_LIBS1.1))
_LIBS3 = $(patsubst %.$(DLL_EXT),%, $(_LIBS2))
_LIBS4 = $(patsubst lib%,%, $(_LIBS3))

LIBS += $(_LIBS4)
LIB_CFLAGS = -L$(LDIR) $(addprefix -l, $(LIBS))

FRAMEWORKS_CFLAGS = $(addprefix -framework ,$(FRAMEWORKS))

FINAL_CFLAGS = $(CFLAGS) $(LIB_CFLAGS) $(FRAMEWORKS_CFLAGS)

$(TARGET): $(OBJ) $(DEPS) | $(BINDIR) $(LDIR)
	$(CC) -o $(BINDIR)/$@ $(FINAL_CFLAGS) $(OBJ)

$(OBJ): $(ODIR)/%.o : %.c  $(DEPS) | $(ODIR) $(SDIR) $(IDIR)
	$(CC) -o $@ $(CFLAGS) -c $<	

$(BDIR) :
	@mkdir -p $(BDIR)

$(ODIR) : $(BDIR)
	@mkdir -p $(ODIR)

$(BINDIR) : $(BDIR)
	@mkdir -p $(BINDIR)
