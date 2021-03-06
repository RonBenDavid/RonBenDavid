#include  <msp430xG46x.h>
/*Group #7                                                                */
/*Ron ben david,                                                          */
/*Yohav itzhak,                                                           */
/*Ben Reuven,                                                             */
;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-----------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupFLL    bis.b   #XCAP14PF,&FLL_CTL0     ; Configure load caps

OFIFGcheck  bic.b   #OFIFG,&IFG1            ; Clear OFIFG
            mov.w   #047FFh,R15             
OFIFGwait   dec.w   R15                     ; Wait for OFIFG to set again if
            jnz     OFIFGwait				; not stable yet
            bit.b   #OFIFG,&IFG1            ; Has it set again?
            jnz     OFIFGcheck              ; If so, wait some more

SetupBT     mov.b #027h,&BTCTL   ; Basic Timer1 Control Register. 2seconds
            mov.b #BTIE,&IE2              ; Enable Basic Timer interrupt
SetupPx     bis.b #0ffh,&P6DIR      ; P6.x output
            bic.b #0ffh,&P6OUT              ; clear PORT6
            bis.b #0ffh,&P5DIR              ; P5.x output
            bic.b #0ffh,&P5OUT              ; clear PORT5
            bis.b #0ffh,&P4OUT              ; P4.x output
            bic.b #0ffh,&P4OUT              ; clear PORT4
            bis.b #0ffh,&P3OUT              ; P3.x output
            bic.b #0ffh,&P3OUT              ; clear PORT3
            bis.b #0ffh,&P2OUT              ; P2.x output
            bic.b #0ffh,&P2OUT              ; clear PORT2
    	    bis.b #0ffh,&P1OUT              ; P1.x output
            bic.b #0ffh,&P1OUT              ; clear PORT1                                        				          							
Mainloop   
            bis.b #GIE+LPM3,SR              ; Enter LPM3, enable interrupts
            bis.b   #02h,&P5OUT              ; Set P5.1
            PUSH.w #2000          ; Push Delay 2000 to TOS
Pulse       
            dec.w SP              ; Decrement Value at TOS
            jnz Pulse              ; Delay done?
            incd.w SP              ; Increment destination twice
            bic.b #02h,&P5OUT              ; Reset P5.1
            jmp     Mainloop                ;
                                            ;
;------------------------------------------------------------------------------
BT_ISR;     Exit LPM3 on reti
;------------------------------------------------------------------------------
            bic.w   #LPM3,0(SP)             ;
            reti                            ;		
                                            ;
;-----------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-----------------------------------------------------------------------------
            ORG     RESET_VECTOR            ; RESET Vector
            DW      RESET                   ;
            ORG     BASICTIMER_VECTOR       ; Basic Timer Vector
            DW      BT_ISR                  ;
            END
