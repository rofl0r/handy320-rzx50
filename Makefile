#
# Unified Makefile for Handy/SDL Portable Lynx Emulator
#
# by James L. Hammons
#
# This software is licensed under the GPL v2 or any later version. Set the
# file GPL.TXT for details. ;-)
#

# Figure out which system we're compiling for, and set the appropriate variables

#OSTYPE=msys
#OSTYPE=dingux
OSTYPE=gcwzero

ifeq "$(OSTYPE)" "msys"	
EXESUFFIX  = .exe

CC         = gcc
LD         = gcc
STRIP      = strip

else
ifeq "$(OSTYPE)" "dingux"
EXESUFFIX  = .dge

CC         = mipsel-linux-gcc
LD         = mipsel-linux-gcc
STRIP      = mipsel-linux-strip

else
ifeq "$(OSTYPE)" "gcwzero"
EXESUFFIX  = 

CC         = mipsel-linux-gcc
LD         = mipsel-linux-gcc
STRIP      = mipsel-linux-strip

endif
endif
endif

TARGET     = handy320

ifeq "$(OSTYPE)" "msys"
# Note that we use optimization level 2 instead of 3--3 doesn't seem to gain much over 2
CFLAGS   = -DDINGUX -MMD -Wall -Wno-comment -Wno-unknown-pragmas -Wno-unused-variable -O2 -Wno-switch -DANSI_GCC -DSDL_PATCH -ffast-math -fomit-frame-pointer 
CPPFLAGS = -DDINGUX -MMD -Wall -O2 -Wno-switch -Wno-non-virtual-dtor -DANSI_GCC -DSDL_PATCH -ffast-math -fomit-frame-pointer -g 
else
ifeq "$(OSTYPE)" "dingux"
CFLAGS = -DDINGUX -MMD -Wall -Wno-comment -Wno-unknown-pragmas -Wno-unused-variable  -O2 -march=mips32 -mtune=r4600 -fomit-frame-pointer -fsigned-char -ffast-math \
	-falign-functions -falign-loops -falign-labels -falign-jumps -funroll-loops -fno-builtin -fno-common -DANSI_GCC -DSDL_PATCH 
CPPFLAGS = $(CFLAGS)
else
ifeq "$(OSTYPE)" "gcwzero"
#CFLAGS = -DGCWZERO -DDINGUX -MMD -Wall -Wno-comment -Wno-unknown-pragmas -Wno-unused-variable  -g -O0 -march=mips32r2 -DANSI_GCC -DSDL_PATCH 
CFLAGS = -DGCWZERO -DDINGUX -MMD -Wall -Wno-comment -Wno-unknown-pragmas -Wno-unused-variable  -O3 -march=mips32r2 -DANSI_GCC -DSDL_PATCH 
#-fomit-frame-pointer -fsigned-char -ffast-math -falign-functions -falign-loops -falign-labels -falign-jumps -funroll-loops -fno-builtin -fno-common 
CPPFLAGS = $(CFLAGS)
endif
endif
endif

ifeq "$(OSTYPE)" "msys"	
LDFLAGS = -mconsole
LIBS = -static -lstdc++ -Wl,-Bdynamic -lSDL -lSDLmain -lmingw32 -lz
else
ifeq "$(OSTYPE)" "dingux"
LDFLAGS =
LIBS = -lstdc++ -lSDL -lz -lpthread 
else
ifeq "$(OSTYPE)" "gcwzero"
LDFLAGS =
LIBS = -lstdc++ -lSDL -lz -lpthread -lSDL_image -lSDL_ttf
endif
endif
endif


INCS = -I./src -I./src/handy-0.95 -I./src/sdlemu 
OBJS = \
		obj/cart.o \
		obj/memmap.o \
		obj/mikie.o \
		obj/ram.o \
		obj/rom.o \
		obj/susie.o \
		obj/system.o \
		obj/errorhandler.o \
		obj/unzip.o \
		obj/sdlemu_filter.o \
		obj/handy_sdl_main.o \
		obj/handy_sdl_handling.o \
		obj/handy_sdl_graphics.o \
		obj/handy_sdl_sound.o \
		obj/gui.o \
		obj/font.o

all: obj $(TARGET)$(EXESUFFIX)
	@echo "*** Looks like it compiled OK... Give it a whirl!"

clean:
	@echo -n "*** Cleaning out the garbage..."
	@rm -rf obj
	@rm -f ./$(TARGET)$(EXESUFFIX)
	@echo done!

obj:
	@mkdir obj

obj/%.o: src/gui/%.cpp
	@echo "*** Compiling $<..."
	$(CC) $(CPPFLAGS) $(INCS) -c $< -o $@

obj/%.o: src/handy-0.95/%.cpp
	@echo "*** Compiling $<..."
	$(CC) $(CPPFLAGS) $(INCS) -c $< -o $@

obj/%.o: src/%.c
	@echo "*** Compiling $<..."
	$(CC) $(CFLAGS) $(INCS) -c $< -o $@

obj/%.o: src/%.cpp
	@echo "*** Compiling $<..."
	$(CC) $(CPPFLAGS) $(INCS) -c $< -o $@

obj/%.o: src/sdlemu/%.c
	@echo "*** Compiling $<..."
	$(CC) $(CFLAGS) $(INCS) -c $< -o $@

obj/%.o: src/sdlemu/%.cpp
	@echo "*** Compiling $<..."
	$(CC) $(CPPFLAGS) $(INCS) -c $< -o $@

obj/%.o: src/zlib-113/%.c
	@echo "*** Compiling $<..."
	$(CC) $(CFLAGS) $(INCS) -c $< -o $@
	
$(TARGET)$(EXESUFFIX): $(OBJS)
	@echo "*** Linking it all together..."
	$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)
	$(STRIP) --strip-all $(TARGET)$(EXESUFFIX)

# Pull in dependencies autogenerated by gcc's -MMD switch
# The "-" in front is there just in case they haven't been created yet

-include obj/*.d
