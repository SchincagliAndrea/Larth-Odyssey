;!to "spritemap.prg", cbm 

SPRITEHEIGHT = 21 
SPRITEPOINTERS = $07f8 
TOP_RASTER = $27   ; So long as this is below $30 - 3 (to cover the top line) 
;10 bands of 8 sprites will cover the screen = 80 sprites on screen! 
NUMBER_OF_SPRITES = 80 ; A sprite is 21 pixels high so 10x21 will cover the screen. 

*= $0801 
!byte $0b,$08,$01,$00,$9e   ; Line 1 SYS2061 
!convtab pet 
!tx "2061" 
!byte $00,$00,$00 

   lda #$ff 
   sta $d015   ; Turn on all sprites. 
   sta $d01d   ; X expand all sprites. 

   lda $d020   ; Set all the sprite colours to the border colour. 
   ldy #7 
-   sta $d027,y 
   dey 
   bpl - 

   lda scrollspritesX      ; If you want to get fancy, each frame, you can change 
   sta $d000            ; the value in this location to scroll the sprite bitmap! 
   lda scrollspritesX+1   ; (You will also have update the X positions inside the IRQ) 
   sta $d002 
   lda scrollspritesX+2 
   sta $d004 
   lda scrollspritesX+3 
   sta $d006 
   lda scrollspritesX+4 
   sta $d008 
   lda scrollspritesX+5 
   sta $d00a 
   lda scrollspritesX+6 
   sta $d00c 
   lda scrollspritesX+7 
   sta $d00e 
   lda scrollspritesXMSB 
   sta $d010 

   ; The sprite bitmap is located at $2c00-$3fff. 
   ; So the first sprite data at $2c00 = a sprite pointer value of $b0. 
   ; The following code clears each spprite image to all 0s. 
   lda #0 
   tax 
   sta SpriteImageCounter 
   sta $fb      ; Use $fb/$fc as a pointer, with initial value of $2c00. 
   lda #$2c 
   sta $fc 
.NextSpriteImage 
   ldy #64      ; Do all 64 bytes of the sprite. 
.NextSpriteByte 
   lda #0 
   sta ($fb),y 
   dey 
   bne   .NextSpriteByte 
   clc 
   lda $fb 
   adc #64      ; Step out pointer to the next sprite. 
   sta $fb 
   bcc + 
   inc $fc 
+   inc SpriteImageCounter   ; Keep clearing sprites until they are all done. 
   ldx SpriteImageCounter 
   cpx #NUMBER_OF_SPRITES 
   bne .NextSpriteImage 

   lda #$ff   ; Set up SID voice 3 as a random number generator. 
   sta $d40e 
   sta $d40f 
   lda #$80   ; Noise waveform, gate bit off. 
   sta $d412 

   lda #TOP_RASTER ; Set up a raster IRQ to multiplex the sprites. 
   sta CurrentY 
   sei 
   lda #$7f 
   sta $dc0d 
   and $d011 
   sta $d011 
   lda CurrentY 
   sta $d012 
   lda $314 
   sta PrevIrq 
   lda $315 
   sta PrevIrq+1 
   lda #<Irq 
   sta $314 
   lda #>Irq 
   sta $315 
   lda #1 
   STA $d01a 
   cli 

loop         ; Infinite loop that randomly fills the sprite bitmap. 
   lda #0      ; The low byte of our pointer will always be 0 but 
            ; we will add a random Y index to it. 
   sta $fb      ; Pick a random byte between $2c00 and $3fff (ie our sprite bitmap). 
.RandomHighByte 
   lda $d41b 
   and #$1f   ; Keep within our 10 bands 
            ; (each band is 512 bytes due to 8 sprite images * 64 bytes).
   cmp #20      ; So keep the high byte between 0-20 = 0-$13 and 
            ; after we add bitmap base address of $2c it will be between $2c and $3f. 
   bcs .RandomHighByte   ; if out of range just go back and pick another.
   clc 
   adc #$2c   ; Add $2c as it is the start of the bitmap. 
   sta $fc 
   ldy $d41b   ; For the random low byte we generate a random Y offset. 
   lda ($fb),y ; Get what was there. 
   ora $d41b   ; And blend a new value. 
   sta ($fb),y 
   jmp loop 

; The single raster IRQ reused down the screen. (Note: due to bad lines you can get 
; some flicker to fix this make customised individual IRQ routines for each band) 
Irq 
   lda CurrentY 
   clc 
   adc #3      ; Set this band of sprites Y position to 3 
   sta $d001   ; raster lines below where the raster is now. 
   sta $d005   ; Why 3? This gives us some time to change 
   sta $d003   ; all the required sprite registers. 
   sta $d007 
   sta $d009 
   sta $d00b 
   sta $d00d 
   sta $d00f 

   ldy SpriteBandCounter 
   inc SpriteBandCounter 
   lda SpriteBandImagePtrs,y   ; Set the sprite pointers for this band. 
   tay 
   sty SPRITEPOINTERS 
   iny 
   sty SPRITEPOINTERS+1 
   iny 
   sty SPRITEPOINTERS+2 
   iny 
   sty SPRITEPOINTERS+3 
   iny 
   sty SPRITEPOINTERS+4 
   iny 
   sty SPRITEPOINTERS+5 
   iny 
   sty SPRITEPOINTERS+6 
   iny 
   sty SPRITEPOINTERS+7 

   lda CurrentY ; Set up the next raster IRQ position. 
   clc 
   adc #SPRITEHEIGHT 
   bcc .StillMoreRasters 
   lda #0   ; Reset ready for next frame. 
   sta SpriteBandCounter 
   lda #TOP_RASTER 
.StillMoreRasters 
   sta CurrentY 
   sta $d012 
   lda #1 
   sta $d019            ; Ack Raster interupt 
PrevIrq = *+1 
   jmp $ea31 

CurrentY 
   !by 0 
FadeIndex 
   !by 0 
scrollspritesX 
   !by $18, $48, $78, $a8, $d8, $08, $38, $68 
scrollspritesXMSB 
   !by $e0 
SpriteImageCounter 
   !by 0 
SpriteBandCounter 
   !by 0 
SpriteBandImagePtrs 
   !by $b0, $b8, $c0, $c8, $d0, $d8, $e0, $e8, $f0, $f8 
IndexToMask: 
   !by $1,$2,$4,$8,$10,$20,$40,$80 