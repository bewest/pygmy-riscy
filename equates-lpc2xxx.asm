;;; -*- Mode:Asm Mode:outline-minor-mode outline-regexp:";;;+" comment-start: "; " -*-
        
;;; equates-lpc2xxx.asm 

;;; Frank Sergeant  frank@pygmy.utoh.org
;;; Control register addresses for the NXP LPC2xxx family of ARM chips.

        ;; it will be preprocessed into equates-lpc2xxx.s by the preprocessor
        ;;  that converts semicolons to at-signs so it can be included in
        ;;  various assembly programs for the lpc2106 or lpc2378 or other
        ;;  members of the NXP lpc2xxx family

;;; Equates

;;;; Pin Registers
        ;; The PINSELx registers control pin functions such as GPIO vs serial.
        .equ  PINSEL0, 0xe002c000
        .equ  PINSEL1, 0xe002c004
        .equ  PINSEL2, 0xe002c008
        .equ  PINSEL3, 0xe002c00c
        .equ  PINSEL4, 0xe002c010
        .equ  PINSEL5, 0xe002c014
        .equ  PINSEL6, 0xe002c018
        .equ  PINSEL7, 0xe002c01c
        .equ  PINSEL8, 0xe002c020
        .equ  PINSEL9, 0xe002c024

        ;; Note LPC2294 has PINSEL2 at 0xe002c014, which is PINSEL5 for other
        ;;  chips.  On the LPC2294, can access its pinsel2 either as
        ;;  PINSEL5 or as LPC2294PINSEL2

        .equ  LPC2294PINSEL2, PINSEL5
        
        
        ;; The PINMODEx registers control pin pull-up or pull-down resistors.
        .equ  PINMODE0, 0xe002c040
        .equ  PINMODE1, 0xe002c044
        .equ  PINMODE2, 0xe002c048
        .equ  PINMODE3, 0xe002c04c
        .equ  PINMODE4, 0xe002c050
        .equ  PINMODE5, 0xe002c054
        .equ  PINMODE6, 0xe002c058
        .equ  PINMODE7, 0xe002c05c
        .equ  PINMODE8, 0xe002c060
        .equ  PINMODE9, 0xe002c064

        
        ;; The FIOxDIR registers control pin direction -- 0=input, 1=output
        .equ  FIO0DIR, 0x3fffc000
        .equ  FIO1DIR, 0x3fffc020
        .equ  FIO2DIR, 0x3fffc040
        .equ  FIO3DIR, 0x3fffc060
        .equ  FIO4DIR, 0x3fffc080

        ;; The FIOxMASK registers contain a 0 bit for the pins affectable by
        ;;  writing to the associated FIOxSET or FIOxCLR or FIOxPIN registers
        .equ  FIO0MASK, 0x3fffc010
        .equ  FIO1MASK, 0x3fffc030
        .equ  FIO2MASK, 0x3fffc050
        .equ  FIO3MASK, 0x3fffc070
        .equ  FIO4MASK, 0x3fffc090

        ;; The FIOxPIN registers -- writing a 1 or 0 sets or clears associated pin
        .equ  FIO0PIN, 0x3fffc014
        .equ  FIO1PIN, 0x3fffc034
        .equ  FIO2PIN, 0x3fffc054
        .equ  FIO3PIN, 0x3fffc074
        .equ  FIO4PIN, 0x3fffc094
        
        ;; The FIOxSET registers -- writing a 1 bit sets associated pin
        .equ  FIO0SET, 0x3fffc018
        .equ  FIO1SET, 0x3fffc038
        .equ  FIO2SET, 0x3fffc058
        .equ  FIO3SET, 0x3fffc078
        .equ  FIO4SET, 0x3fffc098
        
        ;; The FIOxCLR registers -- writing a 1 bit clears associated pin
        .equ  FIO0CLR, 0x3fffc01c
        .equ  FIO1CLR, 0x3fffc03c
        .equ  FIO2CLR, 0x3fffc05c
        .equ  FIO3CLR, 0x3fffc07c
        .equ  FIO4CLR, 0x3fffc09c

;;;; Slow "legacy" I/O
        .equ  IO0PIN,   0xe0028000
        .equ  IO1PIN,   0xe0028010

        .equ  IO0SET,   0xe0028004
        .equ  IO1SET,   0xe0028014

        .equ  IO0DIR,   0xe0028008
        .equ  IO1DIR,   0xe0028018

        .equ  IO0CLR,   0xe002800c
        .equ  IO1CLR,   0xe002801c

        ;; because we are using a "no suffix" LPC2294, which does not have
        ;; fast I/O, we might also need IO2PIN/SET/DIR/CLR, IO3PIN,..., except
        ;; that on the board we are using, Port 2 and Port 3 are used
        ;; for the external memory bus.  So, we will not define these extra
        ;; registers unless we need them in the future.


        

;;;; System Control and Status
        .equ  SCS,     0xe01fc1a0 ; (32bit)

;;;; Timer registers

        ;; Timer interrupt registers (byte)
        .equ  T0IR, 0xe0004000
        .equ  T1IR, 0xe0008000
        .equ  T2IR, 0xe0070000
        .equ  T3IR, 0xe0074000

        ;; Timer control registers (byte)
        .equ  T0TCR, 0xe0004004
        .equ  T1TCR, 0xe0008004
        .equ  T2TCR, 0xe0070004
        .equ  T3TCR, 0xe0074004

        ;; Timer counter registers -- each increments every PR+1 cycles of PCLK
        .equ  T0TC, 0xe0004008
        .equ  T1TC, 0xe0008008
        .equ  T2TC, 0xe0070008
        .equ  T3TC, 0xe0074008

        ;; Timer prescale registers (32bit)
        .equ  T0PR, 0xe000400C
        .equ  T1PR, 0xe000800C
        .equ  T2PR, 0xe007000C
        .equ  T3PR, 0xe007400C
        
        ;; Timer prescale counter registers (32bit)
        .equ  T0PC, 0xe0004010
        .equ  T1PC, 0xe0008010
        .equ  T2PC, 0xe0070010
        .equ  T3PC, 0xe0074010

        ;; Timer match control registers (16bit) 
        .equ  T0MCR, 0xe0004014
        .equ  T1MCR, 0xe0008014
        .equ  T2MCR, 0xe0070014
        .equ  T3MCR, 0xe0074014

        ;; Timer match register 0 registers (32bit) 
        .equ  T0MR0, 0xe0004018
        .equ  T1MR0, 0xe0008018
        .equ  T2MR0, 0xe0070018
        .equ  T3MR0, 0xe0074018

        ;; Timer match register 1 registers (32bit) 
        .equ  T0MR1, 0xe000401C
        .equ  T1MR1, 0xe000801C
        .equ  T2MR1, 0xe007001C
        .equ  T3MR1, 0xe007401C

        ;; Timer match register 2 registers (32bit) 
        .equ  T0MR2, 0xe0004020
        .equ  T1MR2, 0xe0008020
        .equ  T2MR2, 0xe0070020
        .equ  T3MR2, 0xe0074020

        ;; Timer match register 3 registers (32bit) 
        .equ  T0MR3, 0xe0004024
        .equ  T1MR3, 0xe0008024
        .equ  T2MR3, 0xe0070024
        .equ  T3MR3, 0xe0074024

        ;; Timer capture control registers (32bit) 
        .equ  T0CCR, 0xe0004028
        .equ  T1CCR, 0xe0008028
        .equ  T2CCR, 0xe0070028
        .equ  T3CCR, 0xe0074028

        ;; Timer external match registers
        .equ  T0EMR, 0xe000403C
        .equ  T1EMR, 0xe000803C
        .equ  T2EMR, 0xe007003C
        .equ  T3EMR, 0xe007403C

        
        ;; Timer count control registers (byte) -- select between timer and counter mode
        ;;  in counter mode, select the pin and edge used for counting
        .equ  T0CTCR, 0xe0004070 ; (byte)
        .equ  T1CTCR, 0xe0008070 ; (byte)
        .equ  T2CTCR, 0xe0070070 ; (byte)
        .equ  T3CTCR, 0xe0074070 ; (byte)

        ;; Timer PWM control registers
        .equ  PWM0CON, 0xe0004074
        .equ  PWM1CON, 0xe0008074
        .equ  PWM2CON, 0xe0070074
        .equ  PWM3CON, 0xe0074074
        
        
;;;; Clocking and power control registers

        ;; Clock source selection (byte)
        ;;  #b00  = IRC
        ;;  #b01  = Main oscillator
        ;;  #b10  = RTC
        .equ  CLKSRCSEL, 0xe01fc10c


        ;; PLL registers
        .equ  PLLCON,  0xe01fc080 ; (byte)
        .equ  PLLCFG,  0xe01fc084 ; (32bit)
        .equ  PLLSTAT, 0xe01fc088 ; (32bit)
        .equ  PLLFEED, 0xe01fc08c ; (byte)

        ;; Clock divider registers (byte)
        ;;   Timer0 PCLK divider is controlled by bits
        ;;     3:2 in PCLKSEL0 where
        ;;       00 = CCLK/4
        ;;       01 = CCLK
        ;;       10 = CCLK/2
        .equ  CCLKCFG,    0xe01fc104 ; (byte)   
        .equ  USBCLKCFG,  0xe01fc108 ; (byte)
        .equ  IRCTRIM,    0xe01fc1a4 ; (16bit)
        .equ  PCLKSEL0,   0xe01fc1a8 ; (32bit)
        .equ  PCLKSEL1,   0xe01fc1ac ; (32bit)

        ;; Power control registers (byte)
        .equ  PCON,    0xe01fc0c0 ; (byte)

        .equ  INTWAKE, 0xe01fc144 ; (byte)
        .equ  PCONP,   0xe01fc0c4 ; (32bit)

        ;; LPC2294
        .equ  EXTINT,  0xe01fc140 ;  lpc2294
        ;; INTWAKE is also known as EXTWAKE on the LPC2294
        .equ  EXTWAKE, 0xe01fc144 ; (byte)
        .equ  EXTMODE, 0xe01fc148 ; (byte)
        .equ  EXTPOLAR, 0xe01fc14c ; (byte)
        
        
;;;; Serial Ports (UARTs)
        ;; ** note UART1 modem control/status registers to be added later
        ;; **  and maybe the scratch pad registers and IrDA
        
        ;; Define the 4 base addresses then define the offset
        ;;  values.  Use it like this
        ;;       ldr r6 = U0BASE
        ;;       ldr r1, [r6, #ULCR]
        ;;       str r1, [r6, #UDATA]   etc
        
        ;; base addresses
        .equ  U0BASE,  0xe000c000
        .equ  U1BASE,  0xe0010000
        .equ  U2BASE,  0xe0078000
        .equ  U3BASE,  0xe007c000

        ;; receive buffer and transmit buffer  (DLAB=0)
        .equ  UDATA,  0

        ;; Divisor Latch LSB (DLAB=1)
        .equ  UDLL,   0

        ;; Divisor Latch MSB (DLAB=1)
        .equ  UDLM,   4

        ;; Interrupt Enable Register (DLAB=0)
        .equ  UIER,   4

        ;; Interrupt ID Register (read only)
        .equ  UIIR,   8

        ;; FIFO Control Register (write only)
        .equ  UFCR,   8

        ;; Line Control Register
        .equ  ULCR,   0x0c

        ;; Line Status Register
        .equ  ULSR,  0x14

        ;; Auto-baud Control Register (32bit)
        .equ  UACR,  0x20

        ;; Fractional Divider Register
        .equ  UFDR,  0x28

        ;; Transmit Enable Register
        .equ  UTER,  0x30

;;;; Serial Ports (UARTs) -- Alternatives
        ;; The above approach of using a base address plus offsets is
        ;;  used in riscy.asm but another set of symbols can be more
        ;;  useful in the *.forth files
        .equ  U0DATA,  0xe000c000
        .equ  U0DLL,   0xe000c000
        .equ  U0DLM,   0xe000c004
        .equ  U0IER,   0xe000c004
        .equ  U0IIR,   0xe000c008
        .equ  U0FCR,   0xe000c008
        .equ  U0LCR,   0xe000c00c
        .equ  U0LSR,   0xe000c014
        .equ  U0ACR,   0xe000c020
        .equ  U0FDR,   0xe000c028
        .equ  U0TER,   0xe000c030

        .equ  U1DATA,  0xe0010000
        .equ  U1DLL,   0xe0010000
        .equ  U1DLM,   0xe0010004
        .equ  U1IER,   0xe0010004
        .equ  U1IIR,   0xe0010008
        .equ  U1FCR,   0xe0010008
        .equ  U1LCR,   0xe001000c
        .equ  U1LSR,   0xe0010014
        .equ  U1ACR,   0xe0010020
        .equ  U1FDR,   0xe0010028
        .equ  U1TER,   0xe0010030


;;;; lpc2368 and lpc2378 MMC/SD interface registers
        .equ  MCIPower,      0xe008c000    ; r/w  8
        .equ  MCIClock,      0xe008c004    ; r/w 12
        .equ  MCIArgument,   0xe008c008    ; r/w 32
        .equ  MCICommand,    0xe008c00c    ; r/w 11
        .equ  MCIRespCmd,    0xe008c010    ; ro   6
        .equ  MCIResponse0,  0xe008c014    ; ro  32
        .equ  MCIResponse1,  0xe008c018    ; ro  32
        .equ  MCIResponse2,  0xe008c01c    ; ro  32
        .equ  MCIResponse3,  0xe008c020    ; ro  31
        .equ  MCIDataTimer,  0xe008c024    ; r/w 32
        .equ  MCIDataLength, 0xe008c028    ; r/w 16
        .equ  MCIDataCtrl,   0xe008c02c    ; r/w  8
        .equ  MCIDataCnt,    0xe008c030    ; ro  16
        .equ  MCIStatus,     0xe008c034    ; ro  22
        .equ  MCIClear,      0xe008c038    ; wo  11
        .equ  MCIMask0,      0xe008c03c    ; r/w 22
        .equ  MCIMask1,      0xe008c040    ; r/w 22
        .equ  MCIFifoCnt,    0xe008c048    ; ro  15
        .equ  MCIFIFO,       0xe008c080    ; r/w 32
        ;; note that MCIFIFO is the starting address and the fifo buffer runs
        ;;  from 0xe008c080 to 0xe008c0bc  (i.e. 0xe008c080 thru 0xe008c0bb?
        ;;  for a total of (- #xe008c0bc #xe008c080) 60 bytes -- or maybe
        ;;  (- #xe008c0c0 #xe008c080) for a total of 64, yes, that must be it.
        

;;;; Following section for registers specific to the lpc2106 (or at least they are
        ;; not primarily for the lpc2378

        ;; VPBDIV is the lpc2106's equivalent of the lpc2378's PCLKSEL0 and PCLKSEL1
        .equ  VPBDIV,  0xe01fc100

;;;; Following for lpc210[123]
        .equ  APBDIV,  0xe01fc100

;;;; Analog to Digital (for the LPC210[123], probably for others also but check first)
        .equ  AD0CR,         0xe0034000 ;  r/w 32
        .equ  AD0GDR,        0xe0034004 ;  r/w 32 -- r/w per manual but sb ro?
        .equ  AD0STAT,       0xe0034030 ;  ro 32
        .equ  AD0ITEN,       0xe003400c ;  r/w 32
        .equ  AD0DR0,        0xe0034010 ;  ro 32
        .equ  AD0DR1,        0xe0034014 ;  ro 32
        .equ  AD0DR2,        0xe0034018 ;  ro 32
        .equ  AD0DR3,        0xe003401c ;  ro 32
        .equ  AD0DR4,        0xe0034020 ;  ro 32
        .equ  AD0DR5,        0xe0034024 ;  ro 32
        .equ  AD0DR6,        0xe0034028 ;  ro 32
        .equ  AD0DR7,        0xe003402c ;  ro 32

;;;; GPIO defines 
        ;; these are the "legacy" control registers for the lpc2378's ports 0 and 1
        ;;  and the only way of accessing the lpc2106's port 0.
        ;.equ  IOBASE, 0xe0028000
        .equ  IO0PIN,  0xe0028000
        .equ  IO0SET,  0xe0028004
        .equ  IO0DIR,  0xe0028008
        .equ  IO0CLR,  0xe002800c


;;;; Bit-position equates (for setting or clearing a single bit)

        .equ  BIT0,    0x00000001
        .equ  BIT1,    0x00000002
        .equ  BIT2,    0x00000004
        .equ  BIT3,    0x00000008
        .equ  BIT4,    0x00000010
        .equ  BIT5,    0x00000020
        .equ  BIT6,    0x00000040
        .equ  BIT7,    0x00000080
        .equ  BIT8,    0x00000100
        .equ  BIT9,    0x00000200
        .equ  BIT10,   0x00000400
        .equ  BIT11,   0x00000800
        .equ  BIT12,   0x00001000
        .equ  BIT13,   0x00002000
        .equ  BIT14,   0x00004000
        .equ  BIT15,   0x00008000
        .equ  BIT16,   0x00010000
        .equ  BIT17,   0x00020000
        .equ  BIT18,   0x00040000
        .equ  BIT19,   0x00080000
        .equ  BIT20,   0x00100000
        .equ  BIT21,   0x00200000
        .equ  BIT22,   0x00400000
        .equ  BIT23,   0x00800000
        .equ  BIT24,   0x01000000
        .equ  BIT25,   0x02000000
        .equ  BIT26,   0x04000000
        .equ  BIT27,   0x08000000
        .equ  BIT28,   0x10000000
        .equ  BIT29,   0x20000000
        .equ  BIT30,   0x40000000
        .equ  BIT31,   0x80000000
        