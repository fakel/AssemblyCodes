Using SWI you open the file, then store a complete string on the char array we define at the top of the code:

FileHandle: .word 0
CharArray: .skip 100

After that we start to process char by char, we need to know if its a minus, a coma, a null or a number.

At the loop we get a char, compare first for a minus, then for a comma if not, its assumed that the char is a number so we not compare, we subtract 0x30 (hex) as the chars are in ascii we get this for number characters:
0 = 0x30
1 = 0x31 
2 = 0x32
...

Each of the routines for the numbers only get the multiplier and put the corresponding number for the "letter number" in a register.

After that we process the number because, for example, if its 100, we get only 1, then 0, then 0.
The numbers are stored each one in one of the lowers bytes of the register r3, to do this we use an OR shifting first the number by the multiplier (i ssume that you wont get an age more than 999). Visually

Multiplier is 0
#1 = 0 0 0 1<== rotate 0
#1 = 0 0 0 1
OR
R3 = 0 0 0 0
------------------
R3= 0 0 0 1

Multiplier is 2
#2= 0 0 0 2 <=rotate 2
#2= 0 2 0 0
OR
R3= 0 0 0 1
------------------
R3= 0 2 0 1

This way we store number apart one each other on the register.

Next, when a comma appear it means that the number is complete in the register so we go to comma2 to process it.

In comma2 we need to see the multiplier, but its 1 more than the reality so me sub 1 to multiplier and check it. If its 2, we got a centennial, if it 1, a decennial, if its 0 its simply a unit number.

For process a centennial for example, we see the register r3:

R3= 0 2 0 3, its in reverse order, the number is 302, we get the 3, multiply by 100, the 0, multiply by 10, and doo nothing to the 2, on the way we sum it all to get, in hex, 0x12E.

The last of all things are the comparators to classify ages.

If you look at the code you can view some operations like addgt, addpl, addmi. Those all are ADD function, but before them are cmp's, comparators. So for example, if compare a number bigger than other, gt(greater) will execute the add, pl(greater o equal) and mi(less than) no.

This way we fill register for each age.