;;; -*- Mode:Asm Mode:outline-minor-mode outline-regexp:";;;+" comment-start: "; " -*-
        
;;; olimex-lpc2294-equates.asm

;;; Frank Sergeant  frank@pygmy.utoh.org
;;; Equates specific to the Olimex LPC-L2294 board

        ;; This file will be preprocessed into
        ;; olimex-lpc2294-equates.s by the preprocessor that converts
        ;; semicolons to at-signs so it can be included in various
        ;; assembly programs for the Olimex board.

;;; Equates

        ;; The STAT LED is on PORT1, pin 23
        ;; Note, P1.23 is in position 23 (dec) or 0x17 (hex).

        ;; Pin numbers of Port 1 in decimal, binary, and hex:

        ;;  3322 2222 2222 1111 1111 1100 0000 0000
        ;;  1098 7654 3210 9876 5432 1098 7654 3210
        ;;  xxxx xxxx Yxxx xxxx xxxx xxxx xxxx xxxx
        ;;  0000 0000 1000 0000 0000 0000 0000 0000  in binary
        ;;     0    0    8    0    0    0    0    0  = 0x00800000 in hex

        ;; So an orr or bic(and) mask is 0x00800000
        
        .equ STAT_LED_MASK, 0x00800000
        .equ LED_MASK, STAT_LED_MASK
        
