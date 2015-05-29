
[![8051 Calculator Project](http://img.youtube.com/vi/Ecic768g3pA/0.jpg)](http://www.youtube.com/watch?v=Ecic768g3pA)

Things that were hard about this project:

###Writing the LCD driver
======
Originally, i made my own driver, but I couldn't get it to work.
turns out, it was a timing issue inside Lcd_Init. I didn't have a
delay and the 8051 was simply toggling the pins too fast.
We fixed this by finding a post on the internet that had the timing.
And because our library was awful, (but worked), we just used thiers.

###Memory.
======
We had our program loaded with arrays, arrays for all the things. But when it atcually came time
to start doing things with these arrays, we kept getting memory overlap errors when we would
try to compile. So we made our static arrays (the keypad, and error messages) into the 'code' type
which gave us a little breathing room. Next the optimized out all of the excess variables (i,j,this,that)
and started reusing all that we could. We abuse the shit out of the buffer to do our bidding.
also, We hacked in some external functions by ripping them out of the stdlib and stdio so we didn't have
to include the functions we didnt need.

###limited IO
======
It was limited on pins. The simon board has lots of space, but they are reserved for serial and other operations.
probably could have freed up one or two more pins. So the pins... It
was bad because we are using 8 for the keypad, and 10 for the lcd. we cheated a little on the lcd
by tying the RW pin to ground. Afterthought, we could have used the LCD buffer as extra memory.

###numpad keys
======
it was in a non-standard configuration. so we fixed it. 

