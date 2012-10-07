;;; -*- Mode:Asm Mode:outline-minor-mode outline-regexp:";;;+" comment-start: "; " -*-
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; custom-lpc23xx.asm purpose
        
        ;; The purpose of this file (custom-lpc23xx.asm) is to contain all
        ;; the code for Riscy Pygness that is specific to the lpc23xx.  It
        ;; is included by riscy.asm when the target is the lpc23xx.  (It might
        ;; even be specific to the board, e.g. the Olimex LPC-P2378 board. If
        ;; we need to make changes for a different board, then we will make
        ;; more variants of the custom*.asm files.)

;;; NOTE
        ;; Four subroutines and 2 Forth primitives must be defined.

        ;; The following subroutines must be defined, even if they do nothing,
        ;; because riscy.asm will call them.
        ;; 
        ;;      setup_clocks
        ;;      setup_ports
        ;;      ledOnSub
        ;;      ledOffSub

        ;; The following Forth primitives must be defined, even if they do nothing,
        ;; because riscy.asm will call them.
        ;;
        ;;      ledOn
        ;;      ledOff
        
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        .include "equates-lpc2xxx.s"
        .include "olimex-lpc2378-equates.s"

        .equ PLLCLKIN, 12000000  ;  Main crystal clock frequency
        .equ PLL_MULTIPLIER, 1   ;  Multiplier must be 1 since we turn off PLL
        .equ CPUDIVISOR, 1
        .equ PCLKDIVISOR, 1             ; must be 1, 2, or 4
        .equ TIMER0_PRESCALE_DIVISOR, 1
        .equ BAUDRATE, 38400
        ;.equ BAUDRATE, 115200
        ;.equ BAUDRATE, 2400
        .equ  SPIDIVISOR, 128   ; slow it way down for testing -- fcs 31 July 2006

        .equ fractional, 1
        
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Equates that do calculations and so are not likely to change
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; frequency is given in number of clocks per second

        ;; Unlike the LPC2106 and others, the LPC2378 has multiple
        ;; PCLKs.  For now, we will set all the PCLKs to the same
        ;; value.
        
        .equ PLLCLK, (PLLCLKIN * PLL_MULTIPLIER)
        .equ CCLK, (PLLCLK / CPUDIVISOR)

        ;; Set ALL the PCLKs to the same value for now
        ;;  i.e. the value to divide CCLK by to get the default PCLKs
        .if PCLKDIVISOR == 1
          .equ PCLKVALUE, 0x55555555    ; divide by 1
        .endif
        .if PCLKDIVISOR == 2
          .equ PCLKVALUE, 0xAAAAAAAA    ; divide by 2
        .endif
        .if PCLKDIVISOR == 4
          .equ PCLKVALUE, 0x00000000    ; divide by 4
        .endif

        .equ PCLK, (CCLK / PCLKDIVISOR)

        .equ PCLK_TIMER0_DIVISOR, PCLKDIVISOR
        
        .equ TIMER0FREQ, ((CCLK / PCLK_TIMER0_DIVISOR) / TIMER0_PRESCALE_DIVISOR)

        ;.equ SECONDS, 1         ; let's have the LED on for 1 second
                                ;  then off for 1 second

        ;.equ LEDDELAY, (SECONDS * TIMER0FREQ)

        ;; with a PCLK of 3000000, the best frequency for producing
        ;; a variety of baud rates is 1,843,200 Hz.  We can get close
        ;; to it by using a fractional divider value of 8 / (8+5) = 8/13.
        ;; (* (/ 8.0 13.0) 3000000)  --> 1846153.846.
        ;; Then the udl (uart divisor latch) for various baud rates should be
        ;;      115200  1
        ;;       57600  2
        ;;       38400  3
        ;;       19200  6
        ;;        9600 12
        ;;        4800 24
        ;; However, 115,200 cannot be used since the udl *must* be 2 or greater.
        ;; One solution would be to change the PCLK to be twice as fast.
           .equ MULVAL, 8
           .equ DIVADDVAL, 5

          ;; A PCLK of 12 MHz (or 6 or 3 MHz) is not very good for dividing down
          ;; to produce the standard serial port baud rates.  We like to convert
          ;; PCLK into a different frequency that *does* divide down to the
          ;; standard baud rates.  1.843200 MHz, or a multiple of it, is perfect.
          ;; By prescaling PCLK with the fractional divider register, we can
          ;; close enough.  5/13ths of 3 MHz is 1.846154.
        
          ;; If we knew PCLK would be 3 MHz, we could hard code PRESCALEDPCLK as 1846154
          ;.equ PRESCALEDPCLK, 1846154

          ;; but to be more flexible, we will calculate it instead.

          ;; We would like to write it as the following but the math seems to exceed the
          ;;  assembler's capability
          ;.equ PRESCALEDPCLKTST, (PCLK * 5) / 13   ; close to the optimal 1,843,200 Hz or a multiple

          ;; So, we write it as follows
          .equ PRESCALEDPCLK, (4 * 1846154) / PCLKDIVISOR
        
        ;; serial port speed calculations
        .ifdef fractional
                .equ  DIVISOR, PRESCALEDPCLK / (16 * BAUDRATE)
        .else
                .equ DIVISOR, PCLK / (16 * BAUDRATE)
        .endif
        
        .equ  SPICLK, PCLK / SPIDIVISOR
        
        
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Clocks
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_clocks:
        str lr, [sp, #-4]!  ; push return address onto machine stack
                            ;  because this subroutine will itself call
                            ;  other subroutines

        
        ;; disconnect and disable the PLL

        ; clear the 2 ls bits of PLLCON to prepare to disable and
        ; disconnect the PLL.  bit1=PLLC, bit0=PLLE.  However,
        ; the manual, p. 44, shows disconnecting with one feed sequence
        ; then disabling with another feed sequence, so that's what
        ; we will do here.

        ldr r1, = PLLCON 
        ldr r0, [r1]
        bic r0, r0, #2    ; clear bit 1 (PLLC) to disconnect PLL 
        str r0, [r1]

        bl feed_pll


        ldr r1, = PLLCON 
        ldr r0, [r1]
        bic r0, r0, #1     ; clear bit 0 (PLLE) to disable PLL
        str r0, [r1]
        
        bl feed_pll

        ; At this point, the PLL should be off and disconnected and
        ; the selected clock source should be providing the clock to the
        ; CPU, bypassing the PLL.  This clock source should be the IRC
        ; (4 MHz), providing the CPU clock divider is set to 1.

        ; Set the CPU clock divider so it divides by CPUDIVISOR.
        ; (Set the value of the CCLKCFG reg to 1 less than the
        ; desired divider.)
        ldr r1, = CCLKCFG
        mov r0, # (CPUDIVISOR - 1)

        strb r0, [r1]

        ; Turn on the main clock, wait for it to stabilize, then
        ; switch from the IRC clock to the main clock.

        ldr r1, = SCS
        ldr r0, [r1]
        bic r0, r0, #0x10     ; clear bit 4 to select 1-20MHz OSRANGE
        str r0, [r1]
        orr r0, r0, #0x20  ; set bit 5 OSCEN to start main oscillator
        str r0, [r1]
oscstab:   
        ; wait for main oscillator to stabilize by reading bit 6 (OSCSTAT)
        ; until it goes to 1.
        ldr r0, [r1]
        tst r0, #0x40       ; Wait for OSCSTAT
        beq oscstab         ;   to go true.

chgclk:
        ; for LPC2378, now that the main oscillator is stable,
        ; switch from the IRC clock to the main clock
        ldr r1, = CLKSRCSEL
        mov r0, #1
        strb r0, [r1]

pclksetup:
        ;; Rather than one PCLK there are PCLKs for lots of peripherals.
        ;; Let's set *all* of them to the same divisor then later we
        ;; can change specific ones if necessary.
        ldr r0, = PCLKVALUE      ; divide by PCLKDIVISOR
        ldr r1, = PCLKSEL0
        str r0, [r1]
        ldr r1, = PCLKSEL1
        str r0, [r1]

        ;; end of subroutine
        ;;  since this routine itself calls subroutines, we saved the link register
        ;;  upon entry, so rather than returning with 'mov pc, lr', we pop the
        ;;  saved link register directly into the pc
        ldr pc, [sp], #4    ; rts


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; I/O Ports and Peripherals
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_ports:
        ;; use fast I/O for all ports
        
        ;; select fast GPIO mode for ports 0 and 1
        ldr r6, = SCS
        ldr r0, [r6]
        orr r0, r0, #1          ; set bit zero (GPIOM) to force fast GPIO mode
        str r0, [r6]

        ;; Clear all the mask bits so that no pins are masked
        ldr r6, = FIO0MASK
        mov r0, #0
        str r0, [r6]            ; FIO0MASK
        str r0, [r6, #0x20]     ; FIO1MASK
        str r0, [r6, #0x40]     ; FIO2MASK
        str r0, [r6, #0x60]     ; FIO3MASK
        str r0, [r6, #0x80]     ; FIO4MASK

        ;; Set up LED pin (this assumes the Olimex LPC P-2378 board.
        ldr r6, = PINSEL3
        ;; set P1.19 as a GPIO pin
        ;; P1.19 is controlled by bits 7:6 of PINSEL3
        ldr r0, [r6]
        bic r0, r0, # 0xc0      ; clear bits 7:6 to force GPIO mode
        str r0, [r6]

        ;; set LED output pin (i.e. P1.19) as an output
        ldr r6, = FIO1DIR             ; for PORT1
        mov r0, # LED_MASK       ;  all inputs except for pin 19
        str r0, [r6]
        
        ;; set pins P0.2 and P0.3 to be UART0 tx and rx
        ldr r6, = PINSEL0
        mov r0, #0             ; start off with all GPIO
                               ;   then OR in any needed 1 bits
        
        ;; bits 7:6 control RXD0    bits 5:4 control TXD0
        orr r0, r0, #0x50      ; i.e. b'01010000'
        ;; put any additional function selections for PINSEL0 here
        str r0, [r6]

        
setup_uarts_lpc2378:    
        ldr r6, = U0BASE 
        mov r0, #0x83        ; access divisor latches, 8 bits, 1 stop, no parity
        strb r0, [r6, # ULCR]
          mov r0, # (DIVISOR / 256) ; most significant byte of divisor
          strb r0, [r6, # UDLM]
        
          mov r0, # (DIVISOR % 256) ; least significant byte of divisor
          strb r0, [r6, #UDLL]
        mov r0, #03
        strb r0, [r6, # ULCR]   ; turn off access to divisor latches but
                                ;   leave uart0 set to 8 bits, 1 stop, no parity

        .ifdef fractional
           ;; set up fractional divider register
           ldr r0, = ((MULVAL * 16) + DIVADDVAL)
           str r0, [r6, # UFDR]
        .else
           ;; make the code take the same number of bytes
           ldr r0, = 0x10       ; this says do not use the FDR
           str r0, [r6, # UFDR]
        .endif
        
        mov r0, #1
        strb r0, [r6, # UFCR]   ;  enable FIFOs (required)

        ;; testing only, go into an echo loop
;; echo:
;;         bl rx
;;         bl tx
;;         b echo

        mov pc, lr              ; rts


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LED Subroutines
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;  Note, these routines are specific to the Olimex board which has
        ;;    an LED on P1.19
ledOnSub:     
        ldr r6, = FIO1CLR
        ldr r1, = LED_MASK      ; bit P1.19 is on
        str r1, [r6]            ; make bit P1.19 zero (to turn on the LED)
        mov pc, lr
ledOffSub:     
        ldr r6, = FIO1SET
        ldr r1, = LED_MASK      ; bit P1.19 is on
        str r1, [r6]            ; make bit P1.19 one (to turn off the LED)
        mov pc, lr

        
;; ;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;; LED Forth Primitives
;; ;;;  ** note, primitives cannot be placed in the include files, only in riscy.asm
;; ;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;         ;; LED on and off primitives (for testing)
;;         ;;    Note, these routines are specific to the Olimex board which has
;;         ;;    an LED on i/o bit P1.19
;; ledOn:     
;;         ldr r6, = FIO1CLR
;;         ldr r1, = LED_MASK      ; bit 19 is on
;;         str r1, [r6]            ; make bit 19 zero (to turn on the LED)
;;         nxt
;; ledOff:     
;;         ldr r6, = FIO1SET
;;         ldr r1, = LED_MASK      ; bit 19 is off
;;         str r1, [r6]            ; make bit 19 one (to turn off the LED)
;;         nxt


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subroutines Used Only By Other Subroutines In This File
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Feed the PLL
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
feed_pll:  ;; PLL feed sequence
        ldr r1, = PLLFEED
        mov r0, #0xaa
        strb r0, [r1]
        mov r0, #0x55
        strb r0, [r1]
        mov pc, lr
        