## This is a squeaker project witch delayed launch on MCU "attiny10"
![Circuit](/Pictures/sheme.png "Circuit")
###### This is my first relatively large project on the "asm lang"
----------------------------------------------------------------
###### Let's look at some important settings
```asm
    .equ maxTone    = 190
    .equ minTone    = 120
    .equ waitTime   = 10     
```
Here is the parameter "maxTone" is the maximum frequency of squeaker and "minTone" is the minimum frequency
Another important parameter is "waitTime" is the number ticks before the timer turns on
To convert "waitTime" into seconds, you can use the following formula
$$
time_{seconds} = {{maxTone-minTone \over 56} \bullet waitTime}
$$