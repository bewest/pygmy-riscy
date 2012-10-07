;;; -*- Mode:Asm Mode:outline-minor-mode outline-regexp:";;;+" comment-start: "; " -*-
        
;;; olimex-p2103-equates.asm

;;; Frank Sergeant  frank@pygmy.utoh.org
;;; Equates specific to the Olimex P2103 board

        ;; it will be preprocessed into olimex-p2103-equates.s by
        ;; the preprocessor that converts semicolons to at-signs so
        ;; it can be included in various assembly programs for the
        ;; Olimex board.

;;; Equates

        ;; The STAT LED is on PORT0, pin 26
        ;; Note, P0.26 is in position 26 (dec) or 0x1A (hex)
        ;; in decimal

        ;;  3322 2222 2222 1111 1111 1100 0000 0000
        ;;  1098 7654 3210 9876 5432 1098 7654 3210
        ;;  xxxx xYxx xxxx xxxx xxxx xxxx xxxx xxxx
        ;;  0000 0000 0000 0000 0000 0000 0000 0000  in binary
        ;;     0    4    0    0    0    0    0    0  = 0x04000000 in hex

        ;; So an orr or bic(and) mask is 0x04000000
        
        .equ STAT_LED_MASK, 0x04000000
        .equ LED_MASK, STAT_LED_MASK
        
;;; Test of an equate that cannot be loaded into the Lisp *equates* table

        .equ BADKEY, 37 + 24
        .equ BADKEY2, 0B00110101
