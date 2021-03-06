; Bacillus_c64
; Copyright (C) 2016-2017  Thorsten Jordan.
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

; Collection of handy/useful macros
; (C) 2016/17 Thorsten Jordan

; ***************************************************************************************
;
; Commonly used macros
;
; ***************************************************************************************

; add value to x register
!macro addx .value {
  txa
  sbx #(256 - .value)
}

; copy 8 bit value
!macro copy8 .dst, .src {
  lda .src
  sta .dst
}

; copy 16 bit value
!macro copy16 .dst, .src {
  lda .src
  sta .dst
  lda .src+1
  sta .dst+1
}

; set 8 bit value
!macro set8im .target, .val {
  lda #.val
  sta .target
}

; set 8 bit value indexed
!macro set8imx .target, .val {
  lda #.val
  sta .target,x
}

; store 16bit value (i.e. address)
!macro set16im .target, .val {
  lda #<.val
  sta .target
  lda #>.val
  sta .target+1
}

; add unsigned 8 bit value to 16 bit value (works only for unsigned values!)
!macro addu8to16 .result, .src {
  lda .src
  clc
  adc .result
  sta .result
  bcc +
  inc .result+1
+
}

; add signed 8 bit value to 16 bit value
!macro adds8to16 .result, .src {
  lda .src
  bpl +
  dec .result+1
+ clc
  adc .result
  sta .result
  bcc +
  inc .result+1
+
}

; add 16bit values
!macro add16 .result, .opA, .opB {
  lda .opA
  clc
  adc .opB
  sta .result
  lda .opA+1
  adc .opB+1
  sta .result+1
}

; add immediate 8bit value to memory
!macro add8im .dest, .val {
  lda #.val
  clc
  adc .dest
  sta .dest
}

; add immediate 8bit value to memory indexed
!macro add8imx .dest, .val {
  lda #.val
  clc
  adc .dest,x
  sta .dest,x
}

; add immediate 16bit value to memory
!macro add16im .dest, .val {
  lda #<.val
  clc
  adc .dest
  sta .dest
  lda #>.val
  adc .dest+1
  sta .dest+1
}

; add immediate 8bit value to 16bit memory
!macro add16im8 .dest, .val {
  lda #.val
  clc
  adc .dest
  sta .dest
  bcc +
  inc .dest+1
+
}

; add immediate 16bit value to operand and store to memory
!macro add16opim .dest, .src, .val {
  lda #<.val
  clc
  adc .src
  sta .dest
  lda #>.val
  adc .src+1
  sta .dest+1
}

; subtract immediate 16bit value to memory
!macro sub16im .dest, .val {
  lda .dest
  sec
  sbc #<.val
  sta .dest
  lda .dest+1
  sbc #>.val
  sta .dest+1
}

; subtract immediate 16bit value from operand to memory
!macro sub16opim .dest, .src, .val {
  lda .src
  sec
  sbc #<.val
  sta .dest
  lda .src+1
  sbc #>.val
  sta .dest+1
}

; subtract 16bit values
!macro sub16 .result, .opA, .opB {
  lda .opA
  sec
  sbc .opB
  sta .result
  lda .opA+1
  sbc .opB+1
  sta .result+1
}

; compute 16bit absolute value
!macro abs16 .adr {
  lda .adr+1
  bpl +
  eor #$FF  ; negate
  sta .adr+1
  lda .adr
  eor #$FF
  clc
  adc #1
  sta .adr
  lda .adr+1
  adc #0
  sta .adr+1
+
}

; compute 8bit absolute value
!macro abs8 .adr {
  lda .adr
  bpl +
  eor #$FF  ; negate
  clc
  adc #1
  sta .adr
+
}

; compute absolute difference of 16 bit values - code longer but maybe a bit faster than separate sub/abs.
!macro absdiff16 .result, .opA, .opB {
  lda .opA+1
  cmp .opB+1
  beq ++
  bcc +
  ; A > B
  +sub16 .result, .opA, .opB
  jmp +++
+ ; B > A
  +sub16 .result, .opB, .opA
  jmp +++
++  ; Hibyte equal, so check lowbyte
  lda #0
  sta .result+1
  lda .opA
  cmp .opB
  beq ++
  bcc +
  ; A > B, Alow already in Accu
  sec
  sbc .opB
  sta .result
  jmp +++
+ ; B > A
  lda .opB
  sec
  sbc .opA
  sta .result
  jmp +++
++  lda #0
  sta .result
+++
}

; clear 1K of memory
!macro memset1K .dstadr, .value {
  lda #.value
  ldx #$00
- sta .dstadr,x
  sta .dstadr+$100,x
  sta .dstadr+$200,x
  sta .dstadr+$300,x
  inx
  bne -
}

; copy a fix number of pages with 2x loop unrolling for performance
; Code is a bit longer, also because of unrolling, but isn't called to often.
; Uses  A, X, Y
!macro memcopy_pages .dstadr, .srcadr, .nrpages {
  ldy #.nrpages
  lda #<.srcadr
  sta .read0 + 1
  sta .read1 + 1
  lda #>.srcadr
  sta .read0 + 2
  sta .read1 + 2
  lda #<.dstadr
  sta .write0 + 1
  sta .write1 + 1
  lda #>.dstadr
  sta .write0 + 2
  sta .write1 + 2
  ldx #0
.read0  lda $DEAD,x
.write0 sta $BEEF,x
  inx
.read1  lda $DEAD,x
.write1 sta $BEEF,x
  inx
  bne .read0
  inc .read0 + 2
  inc .read1 + 2
  inc .write0 + 2
  inc .write1 + 2
  dey
  bne .read0
}

; Copy up to 256 bytes
; Uses  A, X
!macro memcopy_bytes .dstadr, .srcadr, .nrbytes {
  ldx #.nrbytes
- lda .srcadr-1,x
  sta .dstadr-1,x
  dex
  bne -
}

; decrement 16bit value by 1
!macro dec16 .adr {
  lda .adr
  bne +
  dec .adr+1
+ dec .adr
}

; increment 16bit value by 1
!macro inc16 .adr {
  inc .adr
  lda .adr
  bne +
  inc .adr+1
+
}

; Handy macros for LONG branches
!macro  jne .adr {   
  beq   +
  jmp   .adr
+
}

; Write text on bitmap MC
; X,Y,TEXT
!macro writetext .posx, .posy, .text {
  lda #.posx
  jsr calc_pozx
  lda #.posy
  jsr calc_pozy
  lda #<.text
  sta tx_vec  
  sta tx_vec_color  
  lda #>.text
  sta tx_vec+1
  sta tx_vec_color+1
  jsr Infoprint 
  
}

; Decode LZWVL data
; Use: memory to decompress/file to decompress
!macro decodelzw .memory, .fileLZWVL {
  lda #<.memory
  sta Lzwvl_Put
  lda #>.memory
  sta Lzwvl_Put+1
  lda #<.fileLZWVL 
  sta Lzwvl_Get
  lda #>.fileLZWVL 
  sta Lzwvl_Get+1
  jsr LZW_Decode  
}