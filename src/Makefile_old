RM := @rm -rf
ECO := @echo

# SCRIPTS_DIR=scripts
# CODE_DIR=code
# BUILD_DIR=build

# CC=avr-gcc

# C_FILES = main led buffer serial remote sdcard sd_raw adc inverter timer messaging acr state motherboard lcd lcd_messages fan fault buzzer songs

# # Define all object files.
# O_NAMES = $(C_FILES:%=$(BUILD_DIR)/%.o)
# # O_NAMES += $(LUFA_OBJ:%=$(BUILD_DIR)/%)
# C_NAMES = $(C_FILES:%=$(CODE_DIR)/%.c)

# C_STD = gnu99

# C_FLAGS = -g -Os -Wall -fshort-enums
# C_FLAGS += -DDEBUG

# ----------------- makefile 1 ---------------
# TARGET=OUT

# build: clean create_build_dir $(TARGET).hex
# build: speed_test.c
# 	gcc -o speedtest.out speed_test.c
# --------------------------------------------

# all: build flash
# # reset: reset_via_usb launch
# test: build flash watch
# flash: reset_via_serial run_flash

# flash_debug: reset_via_serial run_flash debug
# all_debug: all debug

# reset_via_serial:
# 	python $(SCRIPTS_DIR)/reset_serial.py

# debug:
# 	python $(SCRIPTS_DIR)/debug_read.py

# debug_reset:
# 	python $(SCRIPTS_DIR)/debug_reset.py

# run_flash:
# 	avrdude -p $(MCU) -P $(PORT) -e -c avr109 -b 115200 -U flash:w:$(TARGET).hex

# create_build_dir:
# 	@if ! [ -d "$(BUILD_DIR)/" ]; then mkdir $(BUILD_DIR)/; fi

# $(BUILD_DIR)/%.o: $(CODE_DIR)/%.c
# 	$(CC) $(C_FLAGS) $(LUFA_FLAGS) -mmcu=$(MCU) -DF_CPU=$(F_CPU) -std=$(C_STD) -c $< -o $@

# #TODO: this needs to be better
# lufa_build:
# 	cp LUFAConfig.h $(BUILD_DIR)/. && cd $(BUILD_DIR) && $(CC) $(C_FLAGS) $(LUFA_FLAGS) -mmcu=$(MCU) -DF_CPU=$(F_CPU) -std=$(C_STD) -c $(LUFA_SRC:%=../%)

# .SECONDARY : $(TARGET).elf
# .PRECIOUS : $(O_NAMES)
# %.elf: $(O_NAMES) #lufa_build
# 	$(CC) -g -mmcu=$(MCU) $(LUFA_LINK_FLAGS) $(O_NAMES) -o $@

# %.hex: %.elf
# 	avr-objcopy -j .text -j .data -O ihex $< $@

# clean:
# 	$(RM) $(BUILD_DIR) $(TARGET).elf $(TARGET).hex

# -include usb.mk 

# watch:
# 	python $(SCRIPTS_DIR)/console.py



#  In order to be a bit more efficient, let's try the following:
# Makefile 2

# CC=gcc
# CFLAGS=-I.

# hellomake: hellomake.o hellofunc.o
#      $(CC) -o hellomake hellomake.o hellofunc.o -I.
# -------------------- makefile 2 ----------------------

CC=gcc
CFLAGS=-I.

build: speed_test.o
	$(CC) -o speedtest.out speed_test.o $(CFLAGS)
# -------------------- makefile 2 ----------------------

# So now we've defined some constants CC and CFLAGS. It turns out these are 
# special constants that communicate to make how we want to compile the files 
# hellomake.c and hellofunc.c. In particular, the macro CC is the C compiler 
# to use, and CFLAGS is the list of flags to pass to the compilation command. 
# By putting the object files--hellomake.o and hellofunc.o--in the dependency 
# list and in the rule, make knows it must first compile the .c versions 
# individually, and then build the executable hellomake.


# Using this form of makefile is sufficient for most small scale projects. 
# However, there is one thing missing: dependency on the include files. 
# If you were to make a change to hellomake.h, for example, make would not 
# recompile the .c files, even though they needed to be. In order to fix 
# this, we need to tell make that all .c files depend on certain .h files. 
# We can do this by writing a simple rule and adding it to the makefile.
# Makefile 3

# CC=gcc
# CFLAGS=-I.
# DEPS = hellomake.h

# %.o: %.c $(DEPS)
# 	$(CC) -c -o $@ $< $(CFLAGS)

# hellomake: hellomake.o hellofunc.o 
# 	gcc -o hellomake hellomake.o hellofunc.o -I.

# This addition first creates the macro DEPS, which is the set of .h files 
# on which the .c files depend. Then we define a rule that applies to all 
# files ending in the .o suffix. The rule says that the .o file depends upon 
# the .c version of the file and the .h files included in the DEPS macro. 
# The rule then says that to generate the .o file, make needs to compile 
# the .c file using the compiler defined in the CC macro. The -c flag says 
# to generate the object file, the -o $@ says to put the output of the 
# compilation in the file named on the left side of the :, the $< is the 
# first item in the dependencies list, and the CFLAGS macro is defined as 
# above.

# As a final simplification, let's use the special macros $@ and $^, which 
# are the left and right sides of the :, respectively, to make the overall 
# compilation rule more general. In the example below, all of the include 
# files should be listed as part of the macro DEPS, and all of the object 
# files should be listed as part of the macro OBJ.
# Makefile 4

# CC=gcc
# CFLAGS=-I.
# DEPS = hellomake.h
# OBJ = hellomake.o hellofunc.o 

# %.o: %.c $(DEPS)
# 	$(CC) -c -o $@ $< $(CFLAGS)

# hellomake: $(OBJ)
# 	gcc -o $@ $^ $(CFLAGS)

# So what if we want to start putting our .h files in an include directory, 
# our source code in a src directory, and some local libraries in a lib 
# directory? Also, can we somehow hide those annoying .o files that hang 
# around all over the place? The answer, of course, is yes. The following 
# makefile defines paths to the include and lib directories, and places the 
# object files in an obj subdirectory within the src directory. It also has 
# a macro defined for any libraries you want to include, such as the math 
# library -lm. This makefile should be located in the src directory. 
# Note that it also includes a rule for cleaning up your source and 
# object directories if you type make clean. The .PHONY rule keeps make 
# from doing something with a file named clean.
# Makefile 5

# IDIR =../include
# CC=gcc
# CFLAGS=-I$(IDIR)

# ODIR=obj
# LDIR =../lib

# LIBS=-lm

# _DEPS = hellomake.h
# DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

# _OBJ = hellomake.o hellofunc.o 
# OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))


# $(ODIR)/%.o: %.c $(DEPS)
# 	$(CC) -c -o $@ $< $(CFLAGS)

# hellomake: $(OBJ)
# 	gcc -o $@ $^ $(CFLAGS) $(LIBS)

# .PHONY: clean

# clean:
# 	rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~ 

# So now you have a perfectly good makefile that you can modify to manage 
# small and medium-sized software projects. You can add multiple rules to 
# a makefile; you can even create rules that call other rules. For more 
# information on makefiles and the make function, check out the GNU Make 
# Manual, which will tell you more than you ever wanted to know (really). 