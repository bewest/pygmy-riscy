;;; -*- Mode:Asm Mode:outline-minor-mode outline-regexp:";;;+" comment-start: "; " -*-
        
;;; led1-2103.asm

;;; Frank Sergeant  frank@pygmy.utoh.org
;;; Test program for the Olimex LPC P-2103 board.

;;; Flash the STAT LED connected to P0.26
        ;; Leave the clock however it is set up by the bootloader.
        ;; Do not set up stacks (therefore no subroutines).
        ;; Set the GPIOM bit, so we can use the Fast GPIO.

        .include "equates-lpc2xxx.s"
        .include "olimex-lpc2103-equates.s"

;;; Misc Equates
        ;.equ LEDDELAY, 20000
        ;.equ LEDDELAY, 40000
        .equ LEDDELAY, 80000

;;; Code
        .code 32

.section .text
        .global vectors
        .org 0

        .global _start

;;; Vectors
; each interrupt vector runs an endless loop except for reset 
vectors:
        b _start
        b .
        b .
        b .
        b .
        b .
        b .
        b .


.section .text

_start:

;;;; Clock
        ;; leave the clock however it is set up by the bootloader

;;;; Ports
        ;; Set the GPIOM bit so we can use the Fast GPIO.
        ;; (The bootloader might have set the GPIOM bit but we set it
        ;; explicitly to be sure.)

        ;; select fast GPIO mode for ports 0 and 1
        ldr r6, = SCS
        ldr r0, [r6]
        orr r0, r0, #1          ; set bit zero (GPIOM) to force fast GPIO mode
        str r0, [r6]

        ;; Clear all the mask bits so that no pins are masked
        ldr r6, = FIO0MASK
        mov r0, #0
        str r0, [r6]            ; FIO0MASK

        ldr r6, = PINSEL1
        ;; set P0.26 as a GPIO pin
        ;; P0.26 is controlled by bits 21:20 of PINSEL1
        ;; xxxx xxxx xx11 xxxx xxxx xxxx xxxx xxxx
        ;;    0    0    3    0    0    0    0    0
        ldr r0, [r6]
        bic r0, r0, # 0x00300000  ; clear bits 21:20 to force GPIO mode
        str r0, [r6]

        ;; set LED output pin (i.e. P0.26) as an output
        ldr r6, = FIO0DIR             ; for PORT1
        mov r0, # STAT_LED_MASK       ;  all inputs except for pin 19
        str r0, [r6]
        
        ;; r0 still contains STAT_LED_MASK
        ldr r5, = FIO0CLR
        ldr r6, = FIO0SET

1:      
        str r0, [r5]            ; clear P0.26, turning on LED

        ;; kill some time
        ldr r1, = LEDDELAY
2:      subs r1, r1, #1
        bne 2b
        
        str r0, [r6]            ; set P0.26, turning off LED

        ;; kill some time
        ldr r1, = LEDDELAY
3:      subs r1, r1, #1
        bne 3b
        

        b 1b                    ; continue forever


