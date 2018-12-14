; Stop interrupts, set up NMI and IRQ interrupt pointers
; Set the VIC-II up for a raster IRQ interrupt
StartIrq 
          sei
          lda #<nmi_int
          sta $fffa
          lda #>nmi_int
          sta $fffb
          lda #<irq1
          sta $fffe
          lda #>irq1
          sta $ffff
          lda #$7f
          sta $dc0d
          sta $dd0d
          lda $dc0d
          lda $dd0d
          lda #$01
          sta $d012
          lda #$1b
          sta $d011
          lda #$01
          sta $d019
          sta $d01a
          cli
          rts
nmi_int
          rti
irq1
          pha         
          txa
          pha        
          tya
          pha         
          inc $d019 
          jsr Display_Bottom_Game_Sprites  
          lda #$3b
          sta $d011
          lda #$31 ; $31=ntsc $2b=pal
          sta $d012                                       
          lda #<irq2_gamesprite       
          sta $fffe       
          lda #>irq2_gamesprite
          sta $ffff
          pla
          tay          
          pla
          tax         
          pla         
          rti 
irq2_gamesprite   
          pha         
          txa
          pha        
          tya
          pha         
          inc $d019
backgroundcolor   
          lda #$00
          sta $d021          
          jsr Display_Mid_Game_Sprites          
          lda #$f9
          sta $d012                                       
          lda #<irq3      
          sta $fffe       
          lda #>irq3
          sta $ffff
          pla
          tay          
          pla
          tax         
          pla         
          rti    
irq3
          pha         
          txa
          pha         
          tya
          pha        
          inc $d019     
          lda #$00
          sta $d011    
          jsr Display_Lower_Game_Sprites
          ldx #$00
          lda $02a6
          bne +         ; ntsc
          ldx #$0f       ; $0f for ntsc
+         stx $d012
          lda #<irq1         
          sta $fffe       
          lda #>irq1
          sta $ffff
          pla
          tay           
          pla
          tax         
          pla         
          rti 
;-----------------------------------------------------------          
; Set up and position the hardware sprites (bottom position)
;
;-----------------------------------------------------------
!zone Display_Bottom_Game_Sprites 
Display_Bottom_Game_Sprites
          lda #%00011111
          sta VIC_SPRITE_ENABLE
          sta VIC_SPRITE_MULTICOLOR   
          ldx #$00
          ldy #$00
.xploder_1 
          lda sprite_x_bottom,x
          clc 
          adc #20
          asl
          ror VIC_SPRITE_X_EXTEND
          sta VIC_SPRITE_X_POS,y         
          lda $02a6
          bne .Pal
          lda sprite_y_bottom,x
          clc
          adc #7
          bcc .Ntsc
.Pal
          lda sprite_y_bottom,x
.Ntsc
          sta VIC_SPRITE_Y_POS,y
          iny
          iny
          inx
          cpx #$08
          bne .xploder_1
          ldx #$00
.xploder_2 
          lda sprite_col_bottom,x
          sta VIC_SPRITE_COLOR,x
          lda sprite_dp_bottom,x
          sta SPRITE_POINTER_BASE,x
          inx
          cpx #$08
          bne .xploder_2
          lda #15
          sta VIC_SPRITE_MULTICOLOR_1
          lda #11
          sta VIC_SPRITE_MULTICOLOR_2  
          rts
;-----------------------------------------------------------          
; Set up and position the hardware sprites
; (mid position)
;-----------------------------------------------------------
!zone Display_Mid_Game_Sprites 
Display_Mid_Game_Sprites
          jsr SpriteEnableMulticolor
          ldx #$00
          ldy #$00
.xploder_1
          lda sprite_x_mid,x
          asl
          ror VIC_SPRITE_X_EXTEND
          sta VIC_SPRITE_X_POS,y
          lda sprite_y_mid,x
          sta VIC_SPRITE_Y_POS,y
          iny
          iny
          inx
          cpx #$08
          bne .xploder_1
          ldx #$00
.xploder_2
          lda sprite_col_mid,x
          sta VIC_SPRITE_COLOR,x
          lda sprite_dp_mid,x
          sta SPRITE_POINTER_BASE,x
          inx
          cpx #$08
          bne .xploder_2
          lda #$05
          sta VIC_SPRITE_MULTICOLOR_1
          lda #$02
          sta VIC_SPRITE_MULTICOLOR_2 
          rts     
;-----------------------------------------------------------          
; Set up and position the hardware sprites
; (lower position)
;-----------------------------------------------------------
!zone Display_Lower_Game_Sprites 
Display_Lower_Game_Sprites
          jsr SpriteEnableMulticolor
          ldx #$00
          ldy #$00
.xploder_1
          lda sprite_x_lower,x
          asl
          ror VIC_SPRITE_X_EXTEND
          sta VIC_SPRITE_X_POS,y
          lda sprite_y_lower,x
          sta VIC_SPRITE_Y_POS,y
          iny
          iny
          inx
          cpx #$08
          bne .xploder_1
          ldx #$00
.xploder_2
          lda sprite_col_lower,x
          sta VIC_SPRITE_COLOR,x
          lda sprite_dp_lower,x
          sta SPRITE_POINTER_BASE,x
          inx
          cpx #$08
          bne .xploder_2
          lda #$05
          sta VIC_SPRITE_MULTICOLOR_1
          lda #$02
          sta VIC_SPRITE_MULTICOLOR_2 
          rts   
SpriteEnableMulticolor          
          lda #$ff
          sta VIC_SPRITE_ENABLE
          sta VIC_SPRITE_MULTICOLOR   
          rts     
;--------------------------------------------------------
; Sprite positions, colours and definitions
;--------------------------------------------------------
; Bottom sprites
;
; Sprite X
;
sprite_x_bottom    !byte $20,$30,$40,$50,$60,$60,$70,$80
; Sprite Y
;
sprite_y_bottom    !byte $15,$15,$15,$15,$15,$15,$15,$15
; Sprite color
;
sprite_col_bottom  !byte $0c,$0c,$0c,$0c,$0c,$06,$07,$08
; Sprite pointer
;
sprite_dp_bottom   !byte SPRITE_BASE+$00,SPRITE_BASE+$01,SPRITE_BASE+$02,SPRITE_BASE+$03,SPRITE_BASE+$04,$05,$06,$00
;-------------------------------------------------------
; mid sprites
;-------------------------------------------------------
; Sprite X
;
sprite_x_mid    !byte $10,$20,$30,$40,$50,$60,$70,$80
; Sprite Y
;
sprite_y_mid    !byte $45,$55,$65,$75,$85,$95,$a0,$b5
; Sprite color
;
sprite_col_mid  !byte $01,$02,$03,$04,$05,$06,$07,$08
; Sprite pointer
;
sprite_dp_mid   !byte $00,$01,$02,$03,$04,$05,$06,$00    
;   
;-------------------------------------------------------
; Lower sprites    
;-------------------------------------------------------
; Sprite X
;
sprite_x_lower    !byte $10,$27,$3f,$55,$64,$7a,$90,$a0
; Sprite Y
;
sprite_y_lower    !fill $08,$fe 
; Sprite color
;
sprite_col_lower  !byte $01,$02,$03,$04,$05,$06,$07,$08
; Sprite pointer
;
sprite_dp_lower   !byte $00,$01,$02,$03,$04,$05,$06,$00      

