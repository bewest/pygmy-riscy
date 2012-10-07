;;; -*- Mode:Asm Mode:outline-minor-mode outline-regexp:";;;+" comment-start: "; " -*-
        
;;; led1.asm

;;; Frank Sergeant  frank@pygmy.utoh.org
;;; Test program for the Olimex LPC P-2378 board.

;;; Flash the STAT LED connected to P1.19
        ;; Leave the clock however it is set up by the bootloader.
        ;; Do not set up stacks (therefore no subroutines).
        ;; Set the GPIOM bit, so we can use the Fast GPIO.

        .include "equates-lpc23xx.s"
        .include "olimex-lpc2378-equates.s"

;;; Misc Equates
        .equ LEDDELAY, 20000

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
        str r0, [r6, #0x20]     ; FIO1MASK
        str r0, [r6, #0x40]     ; FIO2MASK
        str r0, [r6, #0x60]     ; FIO3MASK
        str r0, [r6, #0x80]     ; FIO4MASK
        

        ldr r6, = PINSEL3
        ;; set P1.19 as a GPIO pin
        ;; P1.19 is controlled by bits 7:6 of PINSEL3
        ldr r0, [r6]
        bic r0, r0, # 0xc0      ; clear bits 7:6 to force GPIO mode
        str r0, [r6]

        ;; set LED output pin (i.e. P1.19) as an output
        ldr r6, = FIO1DIR             ; for PORT1
        mov r0, # STAT_LED_MASK       ;  all inputs except for pin 19
        str r0, [r6]
        
        ;; r0 still contains STAT_LED_MASK
        ldr r5, = FIO1CLR
        ldr r6, = FIO1SET

1:      
        str r0, [r5]            ; clear P1.19, turning on LED

        ;; kill some time
        ldr r1, = LEDDELAY
2:      subs r1, r1, #1
        bne 2b
        
        str r0, [r6]            ; set P1.19, turning off LED

        ;; kill some time
        ldr r1, = LEDDELAY
3:      subs r1, r1, #1
        bne 3b
        

        b 1b                    ; continue forever

        