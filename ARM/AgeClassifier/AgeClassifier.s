FileHandle: .word 0
CharArray: .skip 100
Num: .word 0
Mult: .word 0

ldr r0,=MyFile ;file to open on r0
mov r1,#0 ;open file for read, mode on r1
swi 0x66 ;swi function for open a file
bcs NoFile ;Check error, branch if
ldr r1,=FileHandle ;where to store the file handle
str r0,[r1] ;store file handler where r1 points

ldr r0,=FileHandle ;load file handle pinter on r0
ldr r0,[r0] ;load file handle content on r0
ldr r1,=CharArray ;load address to save array
mov r2,#100 ;set max char array size
swi 0x6a ;read string from file
bcs ReadError ;if read error branch

ldr r11,=CharArray ;load pointer to array
mov r8,#0
mov r9,#0
loop:
ldrb r12,[r11]
cmp r12,#0x2d ;cheqck for "-"
beq minus
cmp r12,#0x2c ;cheqck for ","
beq comma2
sub r12,r12,#0x30 ;then its a number
mov r13,#4 ;multiplier for jump
mul r14,r12,r13 ;multiply by 4 the number it gets sub at 0x30
sub r14,r14,#4 ;sub 4 from the jump
add r15,r15,r14 ;add jump to the pc and jump to the number string handler
b zero
b one
b two
b three
b four
b five
b six
b seven
b eight
b nine

;Since we are reading a string from the file, we need
;to check char by char if it is a "-" a "," a null terminator
;or a number, and if the number have more than the unit itself
;so we do a sub by 0x30 and then make a jump to
;an specific routine for the number we read
;then we store the number as a literal on register 2
;and jump to the routine process

zero:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#0 ; move literal 0 to r2
b process

one:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#1 ; move literal 1 to r2
b process

two:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#2 ; move literal 2 to r2
b process

three:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#3 ; move literal 3 to r2
b process

four:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#4 ; move literal 4 to r2
b process

five:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#5 ; move literal 5 to r2
b process

six:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#6 ; move literal 6 to r2
b process

seven:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#7 ; move literal 7 to r2
b process

eight:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#8 ; move literal 8 to r2
b process

nine:
ldr r1,=Mult ; load actual multiplier pointer
ldr r0,[r1] ; load the multiplier at r0
mov r2,#9 ; move literal 9 to r2
b process

;process is on duty to store the number in one of 4 bytes of
;register r3, using multipler we can know where the number
;will be placed for later use
process:
mov r0,r0, lsl #2 ; multiply by 4 (2^2)
mov r2,r2, lsl r0 ;shift the literal mult times to left
orr r3,r3,r2 ; store on r3 literal #number at byte "r2+r0" by and OR
mov r0,r0,lsr #2; divide by 4 (2^2)
add r0,r0,#1 ;increase multiplier
str r0,[r1] ;save multiplier
add r11,r11,#1 ;move the pointer byte
ldrb r1,[r11]
cmp r1,#0x00
beq comma2
mov r1,#0
b loop

minus:
add r10,r10,#1 ;add to invalids
comma:
add r11,r11,#1 ;move the pointer byte
ldrb r12,[r11] ;load next byte
cmp r12,#0x2c ;check for comma
addeq r11,r11,#1 ;move the pointer byte
beq loop
ldrb r1,[r11]
cmp r1,#0x00
beq end
b comma

comma2:
ldr r1,=Mult ; get the multiplier pointer
ldr r0,[r1] ; get the multiplier on r0
sub r0,r0,#1
cmp r0,#2
bne by1
mov r1,#0xf00 ;make a mask
and r2,r3,r1 ;apply the mask
mov r0,r0, lsl #2 ; multiply by 4 (2^2)
mov r2,r2,lsr r0 ;move the number, its the base
mov r14,r2 ;save the number
mov r0,r0,lsr #1; divide by 2 (2^1)
mov r1,#0xf0 ;make a mask
and r2,r3,r1 ;apply the mask
mov r2,r2,lsr r0 ;move the number, its the decade
mov r0,r2
mov r1,#10
mul r2,r0,r1 ;multiply by 10 and store on r2
add r14,r14,r2 ;sum it up
mov r1,#0xf ;make a mask
and r2,r3,r1 ;apply the mask
mov r0,r2
mov r1,#100
mul r2,r0,r1 ;multiply by 100 and store on r2
add r14,r14,r2 ;sum it up
b finish

by1:
cmp r0,#1
bne none
mov r1,#0xf0 ;make a mask
and r2,r3,r1 ;apply the mask
mov r0,r0, lsl #1 ; multiply by 2 (2^1)
mov r2,r2,lsr r0 ;move the number, its the base
mov r14,r2 ;save the number
mov r1,#0xf ;make a mask
and r2,r3,r1 ;apply the mask
mov r0,r2
mov r1,#10
mul r2,r0,r1 ;multiply by 10 and store on r2
add r14,r14,r2 ;sum it up
b finish

none:
mov r1,#0xf ;make a mask
and r2,r3,r1 ;apply the mask
mov r14,r2 ;save the number
b finish

finish:
mov r0,r14
b test
continue:
ldr r1,=Mult
mov r2,#0
str r2,[r1]
mov r1,#0
add r11,r11,#1 ;move the pointer byte
ldrb r3,[r11]
cmp r3,#0x00
beq end
mov r3,#0
b loop

test:
;lost
cmp r0,#102 ;>=102?
addpl r4,r4,#1
;great
cmp r0,#93 ;>=93?
addpl r5,r5,#1
cmp r0,#107 ;but >107
subgt r5,r5,#1
;baby
cmp r0,#53 ;>=53?
addpl r6,r6,#1
cmp r0,#71 ;but >71?
subgt r6,r6,#1
;X
cmp r0,#38 ;>=38?
addpl r7,r7,#1
cmp r0,#52 ;but >52?
subgt r7,r7,#1
;Y
cmp r0,#22 ;>=22?
addpl r8,r8,#1
cmp r0,#37 ;but >37?
subgt r8,r8,#1
;Z
cmp r0,#7 ;>=7
addpl r9,r9,#1
cmp r0,#21 ;but >21?
subgt r9,r9,#1
;others
cmp r0,#127 ;>127?
addgt r10,r10,#1

cmp r0,#71 ;>71
addgt r10,r10,#1
cmp r0,#93 ;but >=93?
subpl r10,r10,#1

cmp r0,#38 ;>38
addgt r10,r10,#1
cmp r0,#21 ;but >=71?
subpl r10,r10,#1

cmp r0,#7
addmi r10,r10,#1
b continue


NoFile:
ldr r0,=Err1 ;load error msg
swi 0x06 ;printout the msg

ReadError:
ldr r0,=Err2 ;load error msg
swi 0x06 ;printout the msg

end:
ldr r0,=lost
swi 0x02
mov r0,#1
mov r1,r4
swi 0x6b
ldr r0,=null
swi 0x02
ldr r0,=great
swi 0x02
mov r0,#1
mov r1,r5
swi 0x6b
ldr r0,=null
swi 0x02
ldr r0,=baby
swi 0x02
mov r0,#1
mov r1,r6
swi 0x6b
ldr r0,=null
swi 0x02
ldr r0,=genX
swi 0x02
mov r0,#1
mov r1,r7
swi 0x6b
ldr r0,=null
swi 0x02
ldr r0,=genY
swi 0x02
mov r0,#1
mov r1,r8
swi 0x6b
ldr r0,=null
swi 0x02
ldr r0,=genZ
swi 0x02
mov r0,#1
mov r1,r9
swi 0x6b
ldr r0,=null
swi 0x02
ldr r0,=notapp
swi 0x02
mov r0,#1
mov r1,r10
swi 0x6b
ldr r0,=null
swi 0x02
inf:
b inf

MyFile: .asciz "nums.txt"
Err1: .asciz "No file with that name\n"
Err2: .asciz "ReadError\n"
lost: .asciz "Lost generation "
great: .asciz "Greatest generation "
baby: .asciz "Baby boomer "
genX: .asciz "Generation X "
genY: .asciz "Generation Y "
genZ: .asciz "Generation Z "
notapp: .asciz "Not applicable "
null: .asciz "\n"