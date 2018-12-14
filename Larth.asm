;---------------------------------------------------
;                  Larth Odyssey  
;   
;                    A game by
;
;         WizKid (Massimiliano De Ruvo) / Graphics
;
;         Wanax   (Andrea Schincaglia)  / Code  
;               
;             Warlock Entertainment 2018
;----------------------------------------------------               
; Variabili
;----------------------------------------------------    
        !source "Variable.asm"       
;------------------------ macros --------------------------

!source "Macros.asm"

;---------------------- program ---------------------------        
; 
; BASIC loader with start address $080d
;-----------------------------------------------------------
        
        * = $0801
   
        !byte $0C,$08,$0A,$00,$9E,$20,$32
        !byte $30,$36,$34,$00,$00,$00,$00,$00
        
StartGame
          jsr PalNtsc
          lda #$00               ; Black background and border
          sta VIC_BORDER_COLOR
          lda #$06
          sta VIC_BACKGROUND_COLOR        
                                  ; address 1 = $30: all RAM
                                  ;           = $31: read CHAR ROM, else all RAM
                                  ;           = $32: read kernal + CHAR ROM, else all RAM
                                  ;           = $35: enable I/O, else all RAM
                                  ;           = $36: enable kernal and I/O, else all RAM
; disable interrupts
          sei
          +set8im 1, $35                  ; Set ROM layout and enable interrupts.
          +set8im VIC_CONTROL_MODE, $0B   ; Turn display off
          jsr ClearBitmap
          +decodelzw SPRITE_LOCATION, Sprite_Larth
          jsr StartIrq
          jsr BitmapModeOn
          jsr DrawScreen
          jsr Settbadr
          
          +decodelzw CHARSET,CharSetMC_lzw  ;set depack address set pointer to data
          +writetext 5,3,info2_t   
          +writetext 5,12,info3_t
          +writetext 10,20,info4_t
          +writetext 5,22,info4_t
          
          jmp *
          
          !align $100,$00
          
          !source "FunctionLibrary.asm"
          !source "ScreenLibrary.asm"
          !source "Irq.asm"
          !source "Memory.asm"
        