    .include "tn10def.inc"

    .def timer = r18                ;delay to turn on speaker
    .def tree  = r19                ;second default register
    .def sys   = r21                ;dafault register in SYCLES
    .def temp  = r20                ;using in initialisation and in interrupt
    .def regst = r22                ;second interrupt register
    .def tone  = r23                ;sound tone counter
    .def count = r24                ;this register used in PWM count
    .def flag  = r25                ;bit flag

    .dseg
    .cseg
    .org 0x00
    rjmp RESET
    .org 0x004 
    rjmp TIM0_OVF
RESET:
    ldi temp, high(ramend)          ; stek init ->
    out sph, temp 
    ldi temp, low(ramend)
    out spl, temp                   ; <- *

    ldi temp, 0b110                 ; set ports 1 and 2 to output
    out DDRB, temp 
    ldi temp, 0b001                 ; set input pulup on pin 0
    out PUEB, temp

    ldi temp, 0b1           
    out TCCR0B, temp                ; set clock to 1:1      
    out TIMSK0, temp                ; inisialize interrupts
    out TIFR0, temp 

    ldi tone, 140                   ; set start tone to 140
    sei                             ; resolving interrupts
CYCLES:
    sbis PINB0, 0                   ; if pin0 == 1 skip the following command
    sbr flag, 1 

    cpi count, 150                  ; if count == 150 jump to Ps
    brsh Branch
    rjmp CYCLES
Branch:  
    clr count
    sbrc flag, 1                    ; if bit1 in flag == low jump to vaeup
    breq vaveup                     
    sbrs flag, 1                    ; fi bit1 in flag == hight jump to vavedn
    breq vavedn
vaveup:
    inc tone                        ; tone++
    cpi tone, 180
    breq rvave
    rjmp CYCLES
vavedn:
    dec tone                        ; tone--
    cpi tone, 130
    breq rvave
    rjmp CYCLES
rvave:
    ldi sys, 0b10
    eor flag, sys
    rcall RED

    rjmp CYCLES
TIM0_OVF:                           ; interrupt vector
    cli
    inc count
    sbrc flag, 0                    ; if bit0 in flag == 1 jump to PIN
    rcall PIN

    ldi temp, 255 
    out TCNT0H, temp 
    out TCNT0L, tone 
    sei 
    reti
PIN:
    ldi temp, 0b010
    in regst, PORTB
    eor regst, temp
    out PORTB, regst  
    ret
RED: 
    ldi sys, 0b100
    in tree, PORTB
    eor tree, sys
    out PORTB, tree 
    ret
    