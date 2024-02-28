;buser in attiny10
;frequensy modulation
;3 - 6 kHz

    .include "tn10def.inc"

    .def tree  = r19 
    .def sys   = r21
    .def temp  = r20 
    .def regst = r22 
    .def tone  = r23 ;memory
    .def count = r24 ;memory
    .def flag  = r25 ;memory

    .dseg
    .cseg
    .org 0x00
    rjmp RESET
    .org 0x004 
    rjmp TIM0_OVF
RESET:
    ldi temp, high(ramend); инициализация стека ->
    out sph, temp 
    ldi temp, low(ramend)
    out spl, temp ; <- *

    ldi temp, 0b110
    out DDRB, temp
    ldi temp, 0b001;<-this
    out PUEB, temp;<-this

    ldi temp, 0b00000001 ;clock
    out TCCR0B, temp
    ldi temp, 0b1
    out TIMSK0, temp
    out TIFR0, temp ;what?

    ldi tone, 140
    ;sbr flag, 2 ;(1<<1)
    sei
LOOP:
    sbis PINB0, 0 ;пропуск если pinb0 == 1
    sbr flag, 1 ;(1<<0)

    cpi count, 150 
    brsh Ps
    rjmp LOOP
Ps:  
    clr count
    sbrc flag, 1 ;SBRC - очищен
    breq vaeup   ;SBRS - установлен
    sbrs flag, 1
    breq vavedn
vaeup:
    inc tone
    cpi tone, 180
    breq rvave
    rjmp LOOP
vavedn:
    dec tone
    cpi tone, 130
    breq rvave
    rjmp LOOP
rvave:
    ldi sys, 0b10
    eor flag, sys

    ldi sys, 0b100
    in tree, PORTB
    eor tree, sys
    out PORTB, tree 
    rjmp LOOP
TIM0_OVF:
    cli
    inc count
    sbrc flag, 0 ; пропуск если bit0 in flag == 0
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
    