# Copyright (c) 2026 Mohammed Safwan

GUI_FRAMEWORKS = IOKit Cocoa OpenGL CoreVideo

CC = clang
IDIR = ./include
SDIR = ./src
BDIR = ./build
ODIR = $(BDIR)/obj
LDIR = ./lib
DYLIBDIR = dylib
DDIR = $(BDIR)/deps
LIBS = m
BINDIR = $(BDIR)/bin
DLL_EXT = dylib
STATIC_EXT = a
FRAMEWORKS = 
CFLAGS = -Wall -Wextra -pedantic -I$(IDIR) -std=c99 
TARGET = main

_SRC = $(shell find $(SDIR) -type f -name "*.c")
__SRC = $(shell echo $(_SRC) | tr "/" " ")
SRC = $(filter %.c, $(__SRC))
VPATH = $(shell find $(SDIR) -type d) $(shell find $(LDIR) -type d)

DEPS = $(shell find $(IDIR) -type f -name "*.h")
OBJ = $(patsubst %.c, $(ODIR)/%.o, $(SRC))

_DEPS = $(shell echo $(DEPS) | tr "/" " ")
NEAT_DEPS = $(filter %.h, $(_DEPS))
_LIBS.DLL = $(shell find $(LDIR) -type f -name "*.$(DLL_EXT)")
_LIBS.STA = $(shell find $(LDIR) -type f -name "*.$(STATIC_EXT)")

_LIBS1.STA = $(shell echo $(_LIBS.STA) | tr "/" " ")
_LIBS2.STA = $(filter %.$(STATIC_EXT), $(_LIBS1.STA)) 

_LIBS3.STA = $(patsubst %.$(STATIC_EXT),%, $(_LIBS2.STA))
_LIBS4.STA = $(patsubst lib%,%, $(_LIBS3.STA))

_LIBS1.DLL = $(shell echo $(_LIBS.DLL) | tr "/" " ")
_LIBS2.DLL = $(filter %.$(DLL_EXT), $(_LIBS1.DLL)) 
_MY_DLLS  = $(addprefix $(BINDIR)/$(DYLIBDIR)/,$(_LIBS2.DLL))

_LIBS3.DLL = $(patsubst %.$(DLL_EXT),%, $(_LIBS2.DLL))
_LIBS4.DLL = $(patsubst lib%,%, $(_LIBS3.DLL))

LIBS += $(_LIBS4.STA) $(_LIBS4.DLL)
LIB_CFLAGS = -L$(LDIR) $(addprefix -l, $(LIBS)) -Wl,-rpath,@loader_path/$(DYLIBDIR) 

FRAMEWORKS_CFLAGS = $(addprefix -framework ,$(FRAMEWORKS))

FINAL_CFLAGS = $(CFLAGS) $(LIB_CFLAGS) $(FRAMEWORKS_CFLAGS)

all : $(TARGET)

setup:
	@mkdir -p $(SDIR)
	@mkdir -p $(IDIR)
	@mkdir -p $(LDIR)
	@touch $(SDIR)/main.c

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
	@echo "Dylib binary  : $(BINDIR)/$(DYLIBDIR)"
	@echo "Frameworks    : $(FRAMEWORKS)"
	@echo "CFLAGS        : $(CFLAGS)"
	@echo "FINAL_CFLAGS  : $(FINAL_CFLAGS)"

.PHONY: all clean run info setup

$(BINDIR)/$(DYLIBDIR)/%.dylib : %.dylib | $(BINDIR)/$(DYLIBDIR)
	@cp $< $(BINDIR)/$(DYLIBDIR)
	@install_name_tool -id '@rpath/$*.dylib' $<

$(TARGET): $(OBJ) $(DEPS) $(_MY_DLLS) | $(BINDIR) $(LDIR) $(BINDIR)/$(DYLIBDIR)
	$(CC) -o $(BINDIR)/$@ $(FINAL_CFLAGS) $(OBJ)

$(OBJ): $(ODIR)/%.o : %.c | $(ODIR) $(SDIR) $(IDIR) $(DDIR)
	$(CC) -o $@ $(CFLAGS) -MMD -MF $(DDIR)/$*.dep -c $<	
include $(wildcard $(DDIR)/*.dep)

$(BDIR) :
	@mkdir -p $(BDIR)

$(ODIR) : $(BDIR)
	@mkdir -p $(ODIR)

$(BINDIR) : $(BDIR)
	@mkdir -p $(BINDIR)

$(BINDIR)/$(DYLIBDIR) : $(BINDIR)
	@mkdir -p $(BINDIR)/$(DYLIBDIR)

$(DDIR) : $(BDIR)
	@mkdir -p $(DDIR)
