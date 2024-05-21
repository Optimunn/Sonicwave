;buser in attiny10
;frequensy modulation
;3 - 6 kHz

    .include "tn10def.inc"

    .def tree  = r19 
    .def sys   = r21
    .def temp  = r20 
    .def regst = r22 
    .def tone  = r23                ;memory
    .def count = r24                ;memory
    .def flag  = r25                ;memory

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

    ldi temp, 0b110                 ; set ports 1 and 2 to out
    out DDRB, temp 
    ldi temp, 0b001                 ; set input pulup on pin 0
    out PUEB, temp

    ldi temp, 0b00000001            ; set clock to 1:1
    out TCCR0B, temp
    ldi temp, 0b1                   ; inisialize interrupts
    out TIMSK0, temp
    out TIFR0, temp 

    ldi tone, 140                   ; set start tone to 140
    sei                             ; resolving interrupts
LOOP:
    sbis PINB0, 0                   ; if pin0 == 1 skip the following command
    sbr flag, 1 

    cpi count, 150                  ; if count == 150 jump to Ps
    brsh Branch
    rjmp LOOP
Branch:  
    clr count
    sbrc flag, 1                    ; if bit1 in flag == low jump to vaeup
    breq vaveup                     ; SBRS - установлен
    sbrs flag, 1                    ; fi bit1 in flag == hight jump to vavedn
    breq vavedn
vaveup:
    inc tone                        ; tone++
    cpi tone, 180
    breq rvave
    rjmp LOOP
vavedn:
    dec tone                        ; tone--
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
    