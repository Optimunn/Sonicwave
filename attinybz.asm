    .include "tn10def.inc"

    .def ledon = r17                ;led timer control
    .def timer = r18                ;delay to turn on speaker
    .def oper  = r19                ;second default register
    .def sys   = r21                ;dafault register in SYCLES
    .def temp  = r20                ;using in initialisation and in interrupt
    .def regst = r22                ;second interrupt register
    .def tone  = r23                ;sound tone counter
    .def count = r24                ;this register used in PWM count
    .def flag  = r25                ;bit flag

    .equ maxTone    = 190
    .equ minTone    = 120
    .equ waitTime   = 5             ;if 20 ~= 25 sec

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

    ldi tone, 170                   ; set start tone to 170
    sei                             ; resolving interrupts
CYCLES:
    sbis PINB0, 0                   ; if pin0 == 1 skip the following command
    sbr flag, 0b1 

    cpi count, 150                  ; if count == 150 jump 
    brsh branch
    cpi ledon, 15
    brlo CYCLES
    clr ledon
    sbrs flag, 0
    rjmp CYCLES
    rcall RED
    rjmp CYCLES
branch: 
    inc ledon
    clr count
    sbrc flag, 1                    ; if bit1 in flag == low jump to vaeup
    breq vaveup                     
    sbrs flag, 1                    ; fi bit1 in flag == hight jump to vavedn
    breq vavedn
vaveup:
    inc tone                        ; tone++
    cpi tone, maxTone
    breq rvave
    rjmp CYCLES
vavedn:
    dec tone                        ; tone--
    cpi tone, minTone
    breq rvave
    rjmp CYCLES
rvave:
    ldi sys, 0b10
    eor flag, sys
    sbrs flag, 0
    rcall RED
    sbrc flag, 2
    rjmp CYCLES
    sbrs flag, 0
    rjmp CYCLES
    inc timer
    cpi timer, waitTime
    brlo CYCLES
    sbr flag, 4
    rjmp CYCLES
TIM0_OVF:                           ; interrupt vector
    cli
    inc count
    sbrc flag, 2                    ; if bit0 in flag == 1 jump to PIN
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
    in oper, PORTB
    eor oper, sys
    out PORTB, oper 
    ret
    