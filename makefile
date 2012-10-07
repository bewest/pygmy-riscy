# ######################################################################
#    Riscy Pygness makefile                                            #
#                                                                      #
#    See the Riscy Pygness User Manual for instructions.               # 
#                                                                      #
# ######################################################################


# ######################################################################
# Set especially these variables for your environment
# ######################################################################

PORT = /dev/ttyS0
BIN = /usr/local/arm/bin
PREASM = /usr/local/bin/preasm.tcl

# I would like to make CCLK conditional upon the chip (or board) but
# that information is not available at the time 'make xxx.dl' is run.
# So, this must be edited for the particular board you are working with.
CCLK = 14746

# Download speed for the serial port (for the flash loader)
DLBAUD = 38400

INCLUDES = custom-lpc23xx.s custom-lpc2106.s custom-lpc2103.s custom-lpc2294.s

ASMFLAGS = -mcpu=arm7tdmi -ahls -mapcs-32 -gstabs

LNKFLAGS =  -v -T lpcriscy.ld -nostartfiles

ZIPFILES = COPYING license20040130.txt makefile led1-2103.asm led1-2378.asm \
   riscy.asm custom-*.asm equates-lpc2xxx.asm olimex-*-equates.asm \
   riscy.tcl util.tcl preasm.tcl lpcriscy.ld riscy \
   kernel-*.bin kernel-*.dictionary kernel.fth forthblocks.el \
   lpc2106.cfg openocd2106.cfg .gdbinit \
   lpc2103.cfg openocd2103.cfg  \
   manual.html r burn .emacs-example

.PRECIOUS: %.o %.hex %.bin %.srec %.elf %.s

all: lpc2294 lpc2106 lpc2103 lpc23xx 

clean:
	@ echo "...cleaning"
	rm -f *.o *.elf *.hex led*.s *.bin *.lst *.lnkh *.lnkt

#zipdate =  `date +%Y%m%d-%H%M`
zipdate =  `date +%Y%m%d`

zip:
	zip riscypygness-$(zipdate).zip $(ZIPFILES)

bzip:
	tar -cjvf riscypygness-$(zipdate).tar.bz2 $(ZIPFILES)
	md5sum riscypygness-$(zipdate).tar.bz2 > riscypygness-$(zipdate).tar.bz2.md5

gzip:
	tar -czvf riscypygness-$(zipdate).tar.gz $(ZIPFILES)
	md5sum riscypygness-$(zipdate).tar.gz > riscypygness-$(zipdate).tar.gz.md5

# Note, the md5 checksums can be checked with, e.g.,
#    md5sum -c riscypygness-20101107-2108.tar.bz2.md5

# Each board or CPU will have its customized rules so the correct 
# includes will be used with the general riscy.asm file and so that
# download baud rates, etc., can be set up

lpc2103 : BOARD = lpc2103
lpc2103 : CCLK  = 14746
# lpc2103 on the Olimex board uses a 14.7456 MHz clock

lpc2106 : BOARD = lpc2106
lpc2106 : CCLK  = 14746
# lpc2106 on the Olimex board uses a 14.7456 MHz clock

lpc2294 : BOARD = lpc2294
lpc2294 : CCLK  = 14746
# This is for the lpc2294 with no suffix (i.e., not enhanced, no
# fractional baud rate generator).
# lpc2294 on the Olimex board uses a 14.7456 MHz clock

lpc23xx : BOARD = lpc23xx
lpc23xx : CCLK  = 14748
# lpc2378 uses an internally generated clock of 14.748 MHz for bootloading
# regardless of the crystal on the board.


lpc2294: kernel-lpc2294.bin kernel-lpc2294.dictionary

lpc2103: kernel-lpc2103.bin kernel-lpc2103.dictionary

lpc2106: kernel-lpc2106.bin kernel-lpc2106.dictionary

lpc23xx: kernel-lpc23xx.bin kernel-lpc23xx.dictionary


kernel-lpc2294.bin kernel-lpc2294.dictionary : \
   custom-lpc2294.s  equates-lpc2xxx.s  olimex-lpc2294-equates.s  riscy-lpc2294.bin kernel.fth
	cp riscy-lpc2294.bin riscy.bin
	cp riscy-lpc2294.lnkt riscy.lnkt
	cp riscy-lpc2294.lst riscy.lst
	./riscy.tcl -flash 1 -chip lpc2294 && cp kernel.bin kernel-lpc2294.bin; cp kernel.dictionary kernel-lpc2294.dictionary

kernel-lpc2103.bin kernel-lpc2103.dictionary : \
   custom-lpc2103.s  equates-lpc2xxx.s  olimex-lpc2103-equates.s  riscy-lpc2103.bin kernel.fth
	cp riscy-lpc2103.bin riscy.bin
	cp riscy-lpc2103.lnkt riscy.lnkt
	cp riscy-lpc2103.lst riscy.lst
	./riscy.tcl -flash 1 -chip lpc2103 && cp kernel.bin kernel-lpc2103.bin; cp kernel.dictionary kernel-lpc2103.dictionary

kernel-lpc2106.bin kernel-lpc2106.dictionary : \
   custom-lpc2106.s  equates-lpc2xxx.s  olimex-lpc2106-equates.s  riscy-lpc2106.bin kernel.fth
	cp riscy-lpc2106.bin riscy.bin
	cp riscy-lpc2106.lnkt riscy.lnkt
	cp riscy-lpc2106.lst riscy.lst
	./riscy.tcl -flash 1 -chip lpc2106 && cp kernel.bin kernel-lpc2106.bin; cp kernel.dictionary kernel-lpc2106.dictionary

kernel-lpc23xx.bin kernel-lpc23xx.dictionary : \
   custom-lpc23xx.s  equates-lpc2xxx.s  olimex-lpc2378-equates.s  riscy-lpc23xx.bin kernel.fth
	cp riscy-lpc23xx.bin riscy.bin
	cp riscy-lpc23xx.lnkt riscy.lnkt
	cp riscy-lpc23xx.lst riscy.lst
	./riscy.tcl -flash 1 -chip lpc23xx && cp kernel.bin kernel-lpc23xx.bin; cp kernel.dictionary kernel-lpc23xx.dictionary

# Create the board-specific source code files for the primitives from
# the general riscy.asm file.

riscy-lpc2294.asm : riscy.asm
	sed -e 's/<BOARD>/lpc2294/' riscy.asm > riscy-lpc2294.asm
riscy-lpc2103.asm : riscy.asm
	sed -e 's/<BOARD>/lpc2103/' riscy.asm > riscy-lpc2103.asm
riscy-lpc2106.asm : riscy.asm
	sed -e 's/<BOARD>/lpc2106/' riscy.asm > riscy-lpc2106.asm
riscy-lpc23xx.asm : riscy.asm
	sed -e 's/<BOARD>/lpc23xx/' riscy.asm > riscy-lpc23xx.asm


#%.s: %.asm makefile
%.s: %.asm
	$(PREASM) $*.asm $@ 

%.o: %.s 
	$(BIN)/arm-elf-as -mcpu=arm7tdmi -mapcs-32 -gstabs -ahls=$*.lst  -o $@ $*.s

%.dis: %.elf
	$(BIN)/arm-elf-objdump  -d --source $<  > $@

%.hex: %.bin
	$(BIN)/arm-elf-objcopy --input-target binary  --output-target ihex  $<  $*.hex

%.srec: %.bin
	$(BIN)/arm-elf-objcopy --input-target binary  --output-target srec  $<  $*.srec

%.bin: %.elf
	$(BIN)/arm-elf-objcopy -O binary $<  $*.bin

%.elf: %.o
	@ echo "...linking $@"
	$(BIN)/arm-elf-ld $(LNKFLAGS) -o $@ $<
	$(BIN)/arm-elf-objdump -h $@ > $*.lnkh
	$(BIN)/arm-elf-objdump -t $@ > $*.lnkt

%.dl: %.bin
	@ echo " about to down load with CCLK = $(CCLK)"
	lpc21isp -verify -bin $*.bin  $(PORT) $(DLBAUD) $(CCLK)

