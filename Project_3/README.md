We should call this thing the suck51. cuz of how much is sucks, eh? get it? suck51? ... i'll let myself out.


Things that sucked hard about this project:

Writing the LCD driver
======
Originally, i made my own driver, but I couldn't get it to work.
turns out, it was a timing issue inside Lcd_Init. I didn't have a
delay and the 8051 was simply toggling the pins too fast.
We fixed this by finding a post on the internet that had the timing.
And because our library was awful, (but worked), we just used thiers.

Memory.
======
the fucker has none of this. Seriously. I like to use arrays, but the 8051 was
all like, 
"hey sean, fuck you. AND your arrays. No, strike that, FUCK YOU, WITH THE ARRRAYS. HA HAaHAa!!1!one!!"
The 8051 really spit that out of the terminal. crazy rite?
We had our program loaded with arrays, arrays for all the things. But when it atcually came time
to start doing things with these arrays, we kept getting memory overlap errors when we would
try to compile. So we made our static arrays (the keypad, and error messages) into the 'code' type
which gave us a little breathing room. Next the optimized out all of the excess variables (i,j,this,that)
and started reusing all that we could. We abuse the shit out of the buffer to do our bidding.
also, We hacked in some external functions by ripping them out of the stdlib and stdio so we didn't have
to include the functions we didnt need.

limited IO
======
I've seen more inputs on a polynesian prostitute. It really sucked being limited on pins.
the simon board has lots of space, but they are reserved for serial and other operations.
probably could have freed up one or two more pins, but fuck it, we're done. So the pins... It
sucked because we are using 8 for the keypad, and 8 for the lcd. we cheated a little on the lcd
by tying the RW pin to ground. We don't need no stinking read. Although, it would have been nice to use
this because WE COULD HAVE USED IT TO STORE OUR DATA. Fuck me, rite? I swear, this controller is 10% give
and 90% fuck you. If we had perhaps 1 more pin free, we could have used the LCD's onboard memory and
made our life easier. But we didn't.

numpad keys
======
it was in a non-standard configuration. so we fixed it. 

computer problems
======
keil sucks and it hates lenovos. so we had to use the shitty lab computers. This was a major
problem because I hate wearing pants. And if im coding at home, the pants are the first thing to go.
