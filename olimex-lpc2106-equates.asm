;;; -*- Mode:Asm Mode:outline-minor-mode outline-regexp:";;;+" comment-start: "; " -*-
        
;;; olimex-lpc2106-equates.asm

;;; Frank Sergeant  frank@pygmy.utoh.org
;;; Equates specific to the Olimex P2106 board

        ;; it will be preprocessed into olimex-lpc2106-equates.s by
        ;; the preprocessor that converts semicolons to at-signs so
        ;; it can be included in various assembly programs for the
        ;; Olimex board.

;;; Equates

        ;; The LED is on PORT0, pin 7

        ;;  3322 2222 2222 1111 1111 1100 0000 0000
        ;;  1098 7654 3210 9876 5432 1098 7654 3210
        ;;  xxxx xxxx xxxx xxxx xxxx xxxx 1xxx xxxx
        ;;  0000 0000 0000 1000 0000 0000 0000 0000  in binary
        ;;     0    0    0    8    0    0    0    0  = 0x00080000 in hex

        ;; So an orr or bic(and) mask is 0x00000080
        
        .equ LED_MASK, 0x00000080
        
