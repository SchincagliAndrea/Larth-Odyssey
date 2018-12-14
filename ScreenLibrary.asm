Temp        = ZEROPAGE_POINTER_1
Bitmap      = Temp
Screen      = Temp+2
Bitmap2     = Temp+4
BlockCount  = Temp+6
Block       = Temp+7
BlockCalc   = Temp+9
ColourScr1  = Temp+10
ColourScr2  = Temp+12
YCount      = Temp+14
OldTile     = Temp+15
;------------------------------------------------------------------
;
;   Name    :  DrawScreen
;   Function:  Draw the desired level
;
;------------------------------------------------------------------
!zone DrawSCreen
DrawScreen
        lda #<SCREEN_BITMAP         ; point to bitmap screen
        sta Bitmap
        lda #>SCREEN_BITMAP
        sta Bitmap+1
        lda #<ScreenData1            ;point to  level
        sta Screen                   ; as top+bottom line are
        lda #>ScreenData1 
        sta Screen+1       
        lda #<SCREEN_COLOR_RAM       ; point to colour screen 1 $C000
        sta ColourScr1
        lda #>SCREEN_COLOR_RAM
        sta ColourScr1+1
        lda #<SCREEN_COLOR_ROM       ; point to HARDWARE colour screen $D800
        sta ColourScr2
        lda #>SCREEN_COLOR_ROM
        sta ColourScr2+1
        lda #11
        sta YCount                   ; Number of rows to render       
        ldy #0
        sty OldTile
DrawScreenLoop
        sty BlockCount
        lda #0
        sta BlockCalc
;Read tile from buffer
        lda (Screen),y               ; Get tile
;Add 1 to the tile code (Tiled sbc #1 to the value of tile)        
        clc
        adc #0
GotTile        
NormalTile
        asl
        rol BlockCalc
        asl
        rol BlockCalc
        asl
        rol BlockCalc
        sta Block       ; Store *8 in Block
        lda BlockCalc
        sta Block+1
        lda Block       ; Now *4 more to make *32
        asl
        rol BlockCalc
        asl
        rol BlockCalc
        clc             ; Now add *8 + *32 together for *40
        adc Block       ; We now have the block address
        sta Block     
        lda BlockCalc
        adc Block+1
        sta Block+1        
        clc              ; Now add on base address of tile
        lda #<TileData   ; and we now have the tile to draw
        adc Block
        sta Block
        lda #>TileData
        adc Block+1
        sta Block+1         
        ldy #15         ; Copy 1st row (16x8 pixels)
CopyTopOfTile
        lda (Block),y
        sta (Bitmap),y
        dey
        bpl CopyTopOfTile
; Move down a character line on the bitmap screen

        clc
        lda Bitmap
        adc #<320
        sta Bitmap2
        lda Bitmap+1
        adc #>320
        sta Bitmap2+1
; Move onto second row...

        +add16im Block,16
         
        ldy #15         ; Copy 2nd row of 16x8 pixels
CopyTopOfTile2
        lda (Block),y
        sta (Bitmap2),y
        dey
        bpl CopyTopOfTile2
; Now move onto COLOURS

        +add16im Block, 16
        
        ldy #0
        lda (Block),y
        sta (ColourScr1),y
        iny
        lda (Block),y
        sta (ColourScr1),y
        iny
        lda (Block),y
        pha
        iny
        lda (Block),y
        ldy #41
        sta (ColourScr1),y
        pla
        dey
        sta (ColourScr1),y
; Now move onto Colour RAM colours...

        +add16im Block, 4
        
; Copy colour RAM colours
        ldy #0
        lda (Block),y
        sta (ColourScr2),y
        iny
        lda (Block),y
        sta (ColourScr2),y
        iny
        lda (Block),y
        pha
        iny
        lda (Block),y
        ldy #41
        sta (ColourScr2),y
        pla
        dey
        sta (ColourScr2),y
DoNextTile
        +add16im Bitmap, 16     ; Move bitmap location on   
        
        +add16im ColourScr1, <2 ; Move colour screen 1 on  
        
        +add16im ColourScr2, <2 ; Move colour screen 2 on        
SkipInc5
        ldy BlockCount
        iny
        cpy #COLWIDTH
        +jne DrawScreenLoop
        
        +add16im Bitmap, 320     ; Move bitmap location on
      
        +add16im ColourScr1, 40  ; Move colour screen 1 on 
SkipInc6
        +add16im ColourScr2, 40  ; Move colour screen 2 on
SkipInc7
        ldy #0 
        +add16im Screen, COLWIDTH  ; move to next row in level map  
        dec YCount
        +jne DrawScreenLoop
        rts    
;------------------------------------------------------
; Create a table to find posy on bitmap
; This table is only for printing text
;------------------------------------------------------
!zone Settbadr
Settbadr  
        ldx #$00
        lda #>SCREEN_BITMAP
        stx $fb
        sta $fc
settb2
        lda $fb
        sta tbadlo,x
        lda $fc
        sta tbadhi,x

        lda $fb
        clc
        adc #$40
        sta $fb

        lda $fc
        adc #$01
        sta $fc
        inx
        cpx #25
        bcc settb2        
        rts
;------------------------------------------------------
; Print font on bitmap at $E000
;------------------------------------------------------       
!zone Infoprint
Infoprint  
        ldy #$00

tx_vec = *+1
-       lda $0000,y
        and #$3f
        tax
        bne +
        jmp .color
+       tya
        pha
        txa
        jsr Font_print
        lda pozx
        clc
        adc #8
        sta pozx
        bcc +
        inc pozx+1
+       pla
        tay
        iny
        bne -
        rts  
.color        
        lda #$00
        sta PARAM1
        ldy PARAM2
.cont
        ldx PARAM1
tx_vec_color = *+1
        lda $0000,x 
        and #$3f 
        tax
        bne +
        rts
+       
        lda CHARSET_COLOR,x
        sta (ZEROPAGE_POINTER_1),y 
        iny
        inc PARAM1 
        jmp .cont
        
;------------------------------------------------------
; Plot font on bitmap at $E000
;------------------------------------------------------  
Font_print
        ldy #<CHARSET
        sty fvec1+1
        asl
        rol fvec1+1
        asl
        rol fvec1+1
        asl
        rol fvec1+1
        sta fvec1
        lda #>CHARSET
        clc
        adc fvec1+1
        sta fvec1+1
        lda pozy
        lsr
        lsr
        lsr
        tax
        lda pozx
        and #$f8
        clc
        adc tbadlo,x
        sta svec
        lda tbadhi,x
        adc pozx+1
        sta svec+1
        ldy #7         
-
fvec1 = *+1
        lda $1111,y
svec = *+1
        sta $1111,y
        dey
        bpl - 
        rts
calc_pozy
        sta PARAM1
        asl
        asl
        asl
        sta pozy
        lda #$00
        sta ZEROPAGE_POINTER_1
        sta ZEROPAGE_POINTER_1+1
-       clc 
        adc #$28
        sta ZEROPAGE_POINTER_1
        bcc +
        inc ZEROPAGE_POINTER_1+1
+       dec PARAM1
        bne -
        clc
        lda ZEROPAGE_POINTER_1+1
        adc #$c0 ;ora #>SCREEN_COLOR_RAM
        sta ZEROPAGE_POINTER_1+1
        rts
calc_pozx
        sta PARAM2
        ldx #0
        stx pozx+1
        ldx #3
-       asl
        rol pozx+1
        dex
        bne -
        sta pozx
        rts    



        