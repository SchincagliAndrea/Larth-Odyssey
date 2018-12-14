;=================================
; Memory locations
; used as variables
;=================================

; Variable for print font
pozy      !byte 0
pozx      !word 0
pozychar  !byte 0
lastput   !byte 0
progress  !byte 0
;----------------------------------------------------
; Block of memory for Font_print
;------------------------------------------- ---------
tbadlo
         !fill 25,0         
tbadhi
         !fill 25,0
tbbit
         !byte %10000000,%01000000,%00100000,%00010000,%00001000,%00000100,%00000010,%00000001  
;----------------------------------------------------  

; Font bitmap compressed      
CharSetMC_lzw 
         !binary "Grafica/Charset/Charset.lzw" 
Sprite_Larth
         !binary "Grafica/Larth.lzw"         
;-----------------------------------------------------         
info2_t
         !text "FRANCESCO SCHINCAGLIA"
         !BYTE 0
info3_t
         !text "ALESSANDRO SCHINCAGLIA ABCDEFGHIJKL0123456789"
         !BYTE 0
info4_t
         !text "ABCDEFGHIJKL0123456789"
         !BYTE 0         

        
ScreenData1
    !byte  $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14
    !byte  $15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$24,$25,$26,$27,$28
    !byte  $29,$2a,$2b,$2c,$2d,$2e,$2f,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c
    !byte  $3d,$3e,$3f,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$50
    !byte  $51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5f,$60,$61,$62,$63,$64
    !byte  $65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f,$70,$71,$72,$73,$74,$75,$76,$77,$78
    !byte  $79,$7a,$7b,$7c,$7d,$7e,$7f,$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c
    !byte  $8d,$8e,$8f,$90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9a,$9b,$9c,$9d,$9e,$9f,$a0
    !byte  $a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9,$aa,$ab,$ac,$ad,$ae,$af,$b0,$b1,$b2,$b3,$b4
    !byte  $b5,$b6,$b7,$b8,$b9,$ba,$bb,$bc,$bd,$be,$bf,$c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7,$c8
    !byte  $5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$5a 
    !byte  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

TileData
    !byte  $00,$00,$00,$00,$00,$00,$00,$00   ; Blocks are 16x16
    !byte  $00,$00,$00,$00,$00,$00,$00,$00   ; Blocks are stored
    !byte  $00,$00,$00,$00,$00,$00,$00,$00   ; AB
    !byte  $00,$00,$00,$00,$00,$00,$00,$00   ; CD
    
    !byte  $11,$11,$11,$11   ; Colour screen  (2 cols)
    !byte  $01,$01,$01,$01   ; colour screen2 (1 col)

    ;
    ; Default "round" platform
    ;
    
    !binary "Grafica/Forest/TilesForest.bin"