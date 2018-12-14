
        *=$c000
        
        LDA #<INFO4_T
        STA TX_VEC          
        LDA #>INFO4_T
        STA TX_VEC+1 
        rts


TX_VEC = *+1
          LDA $0000,Y
          AND #$3F
          TAX     
          RTS
INFO4_T
          !TEXT "HOLD SPACE FOR CHECK TIME..."
          !BYTE 0                    
          