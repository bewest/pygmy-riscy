
# Note, start this within Emacs as
#  M-x arm-elf-gdb --annotate=3

set complaints 1

# for the serial connection to the LPC2294 or LPC2106 using an eCos-generated
#   gdb-stub and /dev/ttyS0 for the serial port at 38400
# set remotebaud 38400
# target remote /dev/ttyS0

# Set up for JTAG and OpenOCD  (see later in file)
#target remote localhost:3333

set output-radix 0x10
set input-radix 0x10

# Following reverts GDB to older behavior allowing access to all
# of target memory.  This should not be necessary once I figure out
# how to tell GDB what memory regions the target has.
#set mem inaccessible-by-default off

# All the LPC ARM chips are little endian
set endian little

dir .
set prompt (arm-gdb) 

cd ~/riscy/lpc2294
#file ~/riscy/lpc2294/riscy-lpc2106.elf
file ~/riscy/lpc2294/riscy-lpc2103.elf
#cd ~/riscy/examples
#file led1.elf

# Set the program file so we can show MIXED C & assembly.
# Must be done before connecting to the target.
#file test.elf

# Connect to OcdLibRemote on port 1000 of localhost.
#target remote localhost:1000

# connect to the simulator
#target sim

# connect to openOCD running on gdb port 3333
target remote localhost:3333
#monitor arm7_9 force_hw_bkpts enable



# Reset the chip to get to a known state.
#monitor reset
#monitor halt

# LPC Init Values
# Disable IRQ & FIRQ, set SVC mode
#set $cpsr = 0xd3

# Increase the packet size to improve download speed.
# Wish this didn't cause an "Are you sure?" popup.
# At least with small programs, they aren't needed.
#set remote memory-write-packet-size 1024
#set remote memory-write-packet-size fixed

# Load the program executable.
#load riscy.elf

# Load the symbols for the program.
#symbol-file riscy.elf

# Set a breakpoint
b _start


# I think I also want breakpoints set at nxtTab and processI
# but wait before trying that
#b nextTab
#b processI

# Run to the breakpoint.
#c






