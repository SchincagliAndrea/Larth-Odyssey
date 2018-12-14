;----------------------------------------------------
; The tiles they are in Koala format:
;
; load address: $6000 - $8710
;               $6000 - $7F3F  Bitmap
;               $7F40 - $8327  Screen RAM
;               $8328 - $870F  Color RAM
;               $8710          Background
;----------------------------------------------------

;----------------------------------------------------
; Attiva la modalità BitMap mode Multicolor
;----------------------------------------------------
!zone BitMapModeOn
BitmapModeOn  
; VIC bank set
        lda $dd00
        and #$fc
        ora #$00
        sta $dd00               ; Set video bank to start at $C000
        
        lda #$18                ; Multicolor on
        sta VIC_CONTROL        
        
        lda #$0f
        sta VIC_MEMORY_CONTROL  ; Memory bitmap at $E000-$FF40
        
        lda #$3b                ; Bitmap mode on
        sta VIC_CONTROL_MODE
        rts
;---------------------------------------------------- 
; 50/60Hz PAL/NTSC frame rates Check Routine
;---------------------------------------------------- 
!zone PalNtsc  
PalNtsc  
        ldy #$01
-       lda VIC_CONTROL_MODE
        bmi -
-       lda VIC_CONTROL_MODE
        bpl -
Check
        lda VIC_RASTER_POS
-       cmp VIC_RASTER_POS
        beq -
        cmp #$37
        beq set_palntsc        ; we are on PAL
-       lda VIC_CONTROL_MODE
        bmi Check
        dey                    ; we are on NTSC
set_palntsc
        sty $02a6 
        rts
;----------------------------------------------------
; Azzera la memoria bitmap
; da $E000-$FF40
; puntatori alla pagina zero ZEROPAGE_POINTER_1
;----------------------------------------------------
!zone ClearBitmap
ClearBitmap 
        lda #<SCREEN_BITMAP
        sta ZEROPAGE_POINTER_1 
        lda #>SCREEN_BITMAP
        sta ZEROPAGE_POINTER_1+1 
        ldy #$00
Clear_loop1  
        lda #$00
        sta (ZEROPAGE_POINTER_1),y 
        iny 
        bne Clear_loop1 
        inc ZEROPAGE_POINTER_1+1
        lda ZEROPAGE_POINTER_1+1 
        cmp #$ff
        bne Clear_loop1
Clear_loop2
        lda #$00
        sta (ZEROPAGE_POINTER_1),y 
        iny 
        cpy #$40
        bne Clear_loop2        
        ; clear screen and color ram
        +memset1K SCREEN_COLOR_ROM, 0
        +memset1K SCREEN_COLOR_RAM, 0
        rts 
;------------------------------------------------------
; Wait for keypress
; Wait until not pressed, then pressed, then released
; Uses  A
;------------------------------------------------------
!zone Wait_For_Joy2_Button
Wait_For_Joy2_Button
-       lda CIA1_DATAPORT_A
        and #$10
        beq -
-       lda CIA1_DATAPORT_A
        and #$10
        bne -
-       lda CIA1_DATAPORT_A
        and #$10
        beq -
        rts  
;---------------------- decode LZWVL data ---------------------
; Input Lzwvl_Get  Source address of data
; Input Lzwvl_Put  Destination address of data
; Uses  A,X,Y
; Decompressor v3, 31-5-2009
;------------------------------------------------------------
Lzwvl_Get  = $f8
Lzwvl_Put  = $fa
Lzwvl_Temp = $fc
!zone LZW_Decode
LZW_Decode
        ldy #0
        ldx #$30
        lda (Lzwvl_Get),y
        ;negative : long mode (bmi, $30)
        ;positive : short mode (bcc, $90)
        bmi *+4
        ldx #$90
        stx delzwvl_short_or_long
        and #$7f
        tax
        bpl delzwvl_start2
        ;----------------
delzwvl_derle
        and #$3f
        sta Lzwvl_Temp     ;number of bytes to de-rle
        iny
        lda (Lzwvl_Get),y  ;fetch rle byte
        ldy Lzwvl_Temp
delzwvl_derle_loop
        dey
        sta (Lzwvl_Put),y
        bne delzwvl_derle_loop
        ;update 0page
        lda Lzwvl_Temp
delzwvl_update
        ldx #2              ;update get with encoding byte + rle byte
        ;-------------
delzwvl_update_x_set
        clc
delzwvl_update_noclc
        adc Lzwvl_Put
        sta Lzwvl_Put
        bcc *+5
        inc Lzwvl_Put+1
        clc
        txa
        adc Lzwvl_Get
        sta Lzwvl_Get
        bcc *+4
        inc Lzwvl_Get+1
        ;--------------
delzwvl_start
        ldy #0
        lax (Lzwvl_Get),y
        ;if negative -> lz sequence
        bmi delzwvl_copystring
delzwvl_start2
        ;if 0 -> end of file
        beq delzwvl_end
        ;if $01-$3f -> literal
        ;if $40-$7f -> rle sequence
        cmp #$40
        bcs delzwvl_derle
        ;----------------
delzwvl_copybytes
        tay
delzwvl_copybytes_loop
        lda (Lzwvl_Get),y
        dey
        sta (Lzwvl_Put),y
        bne delzwvl_copybytes_loop
        ;update 0page, y=0, carry is clear
        txa                       ;update put with the number of bytes copied
        inx                       ;update get with the number of bytes copied + 1
        bne delzwvl_update_noclc
        ;-----------------------
delzwvl_copystring
        and #$7f            ;number of bytes to copy
        sta delzwvl_compare
        iny
        ;calculate adress of lz sequence
        lda (Lzwvl_Get),y
        clc
delzwvl_short_or_long
        bmi delzwvl_copystring_short   ;long mode : bmi ($30), short mode : bcc ($90)
delzwvl_copystring_long
        pha
        iny
        lda (Lzwvl_Get),y
        adc Lzwvl_Put
        sta deLzwvl_Put+1
        pla
        ora #$80
        adc Lzwvl_Put+1
        sta deLzwvl_Put+2
        ldx #3
        bne delzwvl_copystring_start
        ;--------
delzwvl_copystring_short
        adc Lzwvl_Put
        sta deLzwvl_Put+1
        lda #$ff
        adc Lzwvl_Put+1
        sta deLzwvl_Put+2
        ldx #2
delzwvl_copystring_start
        ldy #0
delzwvl_copystring_loop
deLzwvl_Put
        lda $dead,y
        sta (Lzwvl_Put),y
        iny
delzwvl_compare=*+1
        cpy #0
        bne delzwvl_copystring_loop
        ;update 0page
        tya
        bpl delzwvl_update_x_set
delzwvl_end
        rts
        