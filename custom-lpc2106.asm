;;; -*- Mode:Asm Mode:outline-minor-mode outline-regexp:";;;+" comment-start: "; " -*-
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; custom-lpc2106.asm purpose
        
        ;; The purpose of this file (custom-lpc2106.asm) is to contain all
        ;; the code for Riscy Pygness that is specific to the lpc2106.  It
        ;; is included by riscy.asm when the target is the lpc2106.  (It might
        ;; even be specific to the board, e.g. the Olimex LPC-P2106 board. If
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
        .include "olimex-lpc2106-equates.s"

        .equ PLLCLKIN, 14745600  ;  Main crystal clock frequency
        .equ PLL_MULTIPLIER, 1   ;  Multiplier must be 1 since we turn off PLL
        .equ CPUDIVISOR, 1       ;  (does the 2106 have a cpu clock divisor?)
        .equ PCLKDIVISOR, 4      ; must be 1, 2, or 4
        .equ TIMER0_PRESCALE_DIVISOR, 1 ; (does the 2106 have a timer prescale divisor?)
        ;.equ BAUDRATE, 115200
        .equ BAUDRATE, 38400
        .equ SPIDIVISOR, 128     ; slow it way down for testing -- fcs 31 July 2006


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Equates that do calculations and so are not likely to change
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; frequency is given in number of clocks per second

        ;; Unlike the LPC23xx and maybe others, the LPC2106 has a single
        ;; PCLK.
        
        .equ PLLCLK, (PLLCLKIN * PLL_MULTIPLIER)
        .equ CCLK, (PLLCLK / CPUDIVISOR)

        ;; Unlike the lpc2378, the lpc2106 has only a single PCLK.
        ;; The formula for the value to set the VPDIV register is
        ;;            (PCLKDIVISOR % 4)  (see p. 52 of manual)
        ;; We do not need to use the "case" statement; we could simply
        ;; do     .equ PCLKVALUE, (PCLKVALUE % 4)   instead
        .if PCLKDIVISOR == 1
          .equ PCLKVALUE, 1             ; divide by 1
        .endif
        .if PCLKDIVISOR == 2
          .equ PCLKVALUE, 2             ; divide by 2
        .endif
        .if PCLKDIVISOR == 4
          .equ PCLKVALUE, 0             ; divide by 4
        .endif

        .equ  PCLK, CCLK / PCLKDIVISOR   ; most timing depends on PCLK
        
        ;; I think the 2106's timer0 does not have a separate divisor for its PCLK
        ;;  but we will leave this equate here for the moment?
        .equ PCLK_TIMER0_DIVISOR, PCLKDIVISOR
        
        .equ TIMER0FREQ, ((CCLK / PCLK_TIMER0_DIVISOR) / TIMER0_PRESCALE_DIVISOR)
        
        .equ  SPICLK, PCLK / SPIDIVISOR

        ;; Here are PCLK (peripheral bus) clock rates we can get with
        ;;  a 14.7456 MHz crystal and the corresponding SPICLK if we
        ;;  use an spi divisor of 8 (the fastest allowed), and the
        ;;  time 512 bytes times 8 bits = 4096 bits would take
        ;;  (of course, there will be additional overhead)
        ;;                 PCLK       SPICLK     512 Bytes
        ;;         3,686,400 Hz       460,800          9 ms
        ;;         7,372,800 Hz       921,600        4.5 ms
        ;;        14,745,600 Hz     1,843,200        2.2 ms
        ;;        29,491,200 Hz     3,686,400        1.1 ms
        ;;        58,982,400 Hz     7,372,800        0.6 ms
        ;; Does the MMC disk have a maximum allowed speed?  Apparently
        ;;  that is a parameter that should be read directly from the
        ;;  card, but can go up to 20 MHz.


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Clocks
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_clocks:


        ;; Initialize LPC2106 Clocks
        
        ;;   Set Peripheral Bus Speed
             ;;   vpbdiv       %4       valueNeededByVPBDIV
             ;;        1        1       b'01'
             ;;        2        2       b'10' 
             ;;        4        0       b'00'
        ;;         ldr r6, = VPBDIV
        ;;         mov r0, #(PCLKDIVISOR % 4)
        ;;         str r0, [r6]

        ldr r6, = VPBDIV
        ldr r0, = PCLKVALUE
        str r0, [r6]

        mov pc, lr              ; rts
        

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; I/O Ports and Peripherals
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_ports:
        ;; LPC2106
        ;; Only "legacy" I/O is available on the 2106, not "fast I/O"
        ;; So, watch closely to see if we need to factor out I/O access
        ;; so that riscy.asm does not accidentally do the wrong thing.

        ;; make P0.7 an output for the LED and all others will be input pins
        ;; this assumes the Olimex P2106 board
        ldr r6, = IO0DIR
        ;ldr r0, = 0x80          ; bit 7 is on
        ldr r0, = LED_MASK       ; bit 7 is on
        str r0, [r6]             ; make bit 7 an output and all others be inputs

        ;; UART0 Initialization
pin_init:    
        ldr r6, = PINSEL0
        mov r1, #0x10000 ;  could have done
        add r1, r1, #0x5 ;     ldr r1, = #0x10005  instead
                          ; i.e. $00010005
                          ;  sets P0.0 and P0.1 for use by uart0 tx and rx
                          ;  and sets P0.8 for use by uart1 tx  ( but not rx )
        str r1, [r6]

setup_uarts:    
        ldr r6, = U0BASE 
        
        ; Write to U0LCR to set DLAB bit and then set baud rate, etc.
        mov r1, #0x83        ; access divisor latches, 8 bits, 1 stop, no parity
        strb r1, [r6, # ULCR]
        ; Now set divisor latches for 9600 bps with 14.745 Mhz xtal, no PLL,
        ;    pclk 1/4 of cclk, so at 14.7456 MHz, pclk is 3,686,400, which, 
        ;    divided by 16 is 230,400.  So, here is the table of divisor 
        ;    latch values and baud rates:
        ;        divisor        bps
        ;              1        230,400
        ;              2        115,200
        ;              4         57,600
        ;              6         38,400
        ;             12         19,200
        ;             24          9,600

        ; We would like to calculate the baud rate DIVISOR automatically
        ;  based on CCLK, PCLK, and BAUDRATE set near beginning of
        ;  this file.  Note, this works only for divisors less
        ;  than 256.

        ; So, the formula (ignoring partials)
        ;  baudrate = PCLK / (16 * DIVISOR)
        ;  16 * DIVISOR * baudrate = PCLK
        ;  DIVISOR = PCLK / (16 * baudrate)
        ; E.g. with a 12 MHz CCLK and a 3 MHz PCLK
        ;    (/ 3000000.0 (* 16 115200))  1.6276041666666667
        ;    (/ 3000000.0 (* 16  57600))  3.2552083333333335
        ;    (/ 3000000.0 (* 16  38400))  4.8828125
        ;    (/ 3000000.0 (* 16  19200))  9.765625
        ;    (/ 3000000.0 (* 16   9600))  19.53125
        ;    (/ 3000000.0 (* 16   4800))  39.0625
        ;    (/ 3000000.0 (* 16   2400))  78.125
        ;    (/ 3000000.0 (* 16   1200))  156.25
        ;
        ; So, without partials, I guess 4800 bps or less will have the least error
        
        .equ  DIVISOR, PCLK / (16 * BAUDRATE)
        
        mov r1, # DIVISOR
        strb r1, [r6, # UDLL]
        mov r1, #0
        strb r1, [r6, # UDLM]

        mov r1, #03
        strb r1, [r6, # ULCR]   ; turn off access to divisor latches but
                                ;   leave uart0 set to 8 bits, 1 stop, no parity

        mov r0, #1
        strb r0, [r6, # UFCR]   ;  enable FIFOs (required)

        ; initialize TX on uart1 (but not RX)
        ; this will be used for the LCD
        ldr r6, = U1BASE
        ; Write to U1LCR to set DLAB bit and then set baud rate, etc.
        mov r1, #0x83        ; access divisor latches, 8 bits, 1 stop, no parity
        strb r1, [r6, # ULCR]
        ; Now set divisor latches for 9600 bps with 14.745 Mhz xtal, no PLL,
        ;    pclk 1/4 of cclk, so at 14.7456 MHz, pclk is 3,686,400, which, 
        ;    divided by 16 is 230,400.  So, here is the table of divisor 
        ;    latch values and baud rates:
        ;        divisor        bps
        ;              1        230,400
        ;              2        115,200
        ;              4         57,600
        ;              6         38,400
        ;             12         19,200
        ;             24          9,600
        .equ  DIVISOR1, PCLK / (16 * 9600)
        mov r1, # DIVISOR1      ; should be 12 for 9600 pbs, or 4 for 57600
        strb r1, [r6, # UDLL]
        mov r1, #0
        strb r1, [r6, # UDLM]
        mov r1, #03
        strb r1, [r6, # ULCR]   ; turn off access to divisor latches but
                                ;   leave uart1 set to 8 bits, 1 stop, no parity
        mov r0, #1
        strb r0, [r6, # UFCR]   ; enable FIFOs (required)

        mov pc, lr              ; rts

        
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LED Subroutines
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;  Note, these routines are specific to the Olimex board which has
        ;;    an LED on P0.7
ledOnSub:     
        ldr r6, = IO0CLR
        ldr r1, = LED_MASK      ; bit 7 is on
        str r1, [r6]            ; make bit 7 zero (to turn on the LED)
        mov pc, lr
ledOffSub:     
        ldr r6, = IO0SET
        ldr r1, = LED_MASK      ; bit 7 is on
        str r1, [r6]            ; make bit 7 one (to turn off the LED)
        mov pc, lr

;; ;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;; LED Forth Primitives
;; ;;;  ** note, primitives cannot be placed in the include files, only in riscy.asm
;; ;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;         ;; LED on and off primitives (for testing)
;;         ;;    Note, these routines are specific to the Olimex board which has
;;         ;;    an LED on i/o bit 7
;; ledOn:     
;;         ldr r6, = IO0CLR
;;         ldr r1, = LED_MASK      ; bit 7 is on
;;         str r1, [r6]            ; make bit 7 zero (to turn on the LED)
;;         nxt
;; ledOff:     
;;         ldr r6, = IO0SET
;;         ldr r1, = LED_MASK      ; bit 7 is on
;;         str r1, [r6]            ; make bit 7 one (to turn off the LED)
;;         nxt

        