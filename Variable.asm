VIC_SPRITE_X_POS        = $d000
VIC_SPRITE_Y_POS        = $d001
VIC_SPRITE_X_EXTEND     = $d010
VIC_CONTROL_MODE        = $d011
VIC_RASTER_POS          = $d012
VIC_SPRITE_ENABLE       = $d015
VIC_CONTROL             = $d016
VIC_SPRITE_EXPAND_Y     = $d017
VIC_MEMORY_CONTROL      = $d018
VIC_IRQ_REQUEST         = $d019
VIC_IRQ_MASK            = $d01a
VIC_SPRITE_MULTICOLOR   = $d01c
VIC_SPRITE_EXPAND_X     = $d01d
VIC_SPRITE_MULTICOLOR_1 = $d025
VIC_SPRITE_MULTICOLOR_2 = $d026
VIC_SPRITE_COLOR        = $d027

VIC_BORDER_COLOR        = $d020
VIC_BACKGROUND_COLOR    = $d021
VIC_CHARSET_MULTICOLOR_1= $d022
VIC_CHARSET_MULTICOLOR_2= $d023

CIA1_DATAPORT_A = $DC00
CIA1_DATAPORT_B = $DC01

;placeholder for various temp parameters
PARAM1                  = $03
PARAM2                  = $04
PARAM3                  = $05
PARAM4                  = $06
PARAM5                  = $07
PARAM6                  = $08
PARAM7                  = $09
PARAM8                  = $0A
PARAM9                  = $0B
PARAM10                 = $0C
PARAM11                 = $0D
PARAM12                 = $0E

LOCAL1                  = $10
LOCAL2                  = $11
LOCAL3                  = $12

;placeholder for zero page pointers
ZEROPAGE_POINTER_1      = $17
ZEROPAGE_POINTER_2      = $19
ZEROPAGE_POINTER_3      = $21
ZEROPAGE_POINTER_4      = $23

SCREEN_BITMAP           = $E000    ; $E000-$FF40
SCREEN_COLOR_RAM        = $C000    ; $C000-$C3E7
SCREEN_COLOR_ROM        = $D800
CHARSET                 = $0400
CHARSET_COLOR           = $0400+$201

SPRITE_LOCATION         = $C800   
 
;SPRITE NUMBER CONSTANT
SPRITE_BASE             = ( SPRITE_LOCATION % 16384 ) / 64

;address of sprite pointers
 
SPRITE_POINTER_BASE     = 3*$4000+1016 ; Bank(x)*$4000+1016
COLWIDTH                = 20        ; Width of collision map in bytes

