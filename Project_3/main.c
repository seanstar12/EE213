/*
  COMP_ENG 213: DIGITAL SYSTEMS DESIGN SP2014 -- Project 3
  Fun times with the 8051 Microcontroller.
  Originally supposed to display output via serial, but we're "pros".
  Creators of this monstrosity: 
    Sean Starnes
    Benjamin Miller

*/

#include <REG932.H>
/*
  Lcd.h obtained from electrosome. <-- awesome write up.
  http://electrosome.com/interfacing-lcd-with-8051-using-keil-c-at89c51/
*/
#include <lcd.h>

#ifndef NULL
 #define NULL ((void *) 0L)
#endif

extern float atof (char *s1);                     //Including external functions for ease of calculations
extern int sprintf  (char *, const char *, ...);

sbit RS = P1^4;                                   // LCD pin setup
sbit EN = P1^6;
sbit D0 = P2^0;
sbit D1 = P2^1;
sbit D2 = P2^2;
sbit D3 = P2^3;
sbit D4 = P2^4;
sbit D5 = P2^5;
sbit D6 = P2^6;
sbit D7 = P2^7;

sbit reset = P1^1;                                //Reset pin
 
sbit a0 = P0^0;                                   //Keypad pin setup
sbit a1 = P0^1;
sbit a2 = P0^2;
sbit a3 = P0^3;
sbit a4 = P0^4;
sbit a5 = P0^5;
sbit a6 = P0^6;
sbit a7 = P0^7;

code unsigned char values [4][4] =  {             //keypad layout as seen by controller
		'7', '4', '1', '0',
		'8', '5', '2', '.',
		'9', '6', '3', '-',
		'/', '*', '+', '='};
code unsigned char errMsg [5][15] =  {            //default error messages to display
		"",
		"No Implement!",
		"Too Big!",
		"Resetting...",
		"I Can't Math!" };

unsigned char scanTehThings();                    //scans keypad for button presses
void delay(int);                                  //simple delay function
void displayMsg(unsigned char *,unsigned char *,unsigned int); //displays a message to the LCD
bit operandCheck(char);                           //logic for if an operand was pressed (+,-,/,*)
void clrStr(char *);                              //clears a string so we can reuse it
void doMaths(unsigned char*,unsigned char*);      // not used
void itoa(int, char *);                           // not used

void main(void) {
	P0M1 = 0x00;
	P1M1 = 0x00;
	P2M1 = 0x00;

  Lcd_Init();

  while(1) {
		bit flag = 0;
		bit opSet = 0;
		bit done = 0;
		unsigned char currChar, lastChar, op;
		char buffer[24],msgStr[15];
		unsigned int err,bufferPos=0;	
		
		while(reset){                                     // when reset is pulled low, it resets
			unsigned int i,j;
			unsigned char temp[12];
			
			currChar = scanTehThings();
			
			if (currChar != ' ' && currChar != lastChar) {  // if new button is pressed
				if (bufferPos < 24) {  												// if within our buffer zone
					if (opSet && currChar == '=') {             // if it's an operator and we're trying to get the result
						Lcd_Clear();                              // clear display
						clrStr(msgStr);                           // clear secondary buffer

						for (i=0;buffer[i]!=NULL;i++){            // this pulls out our second variable from the
							if (buffer[i] == op){                   // main buffer and stores it into temp[x]
								buffer[i]= ' ';
								for(j=0;buffer[j+1+i]!=NULL;j++){
									temp[j] = buffer[j+1+i];
									buffer[j+1+i] = ' ';
								} 
								break;
							}
						}
						if (op == '+'){                           // does maths
							sprintf(buffer, "%.02f" ,atof(buffer)+atof(temp));
						} else if (op == '*'){
							sprintf(buffer, "%.02f" ,atof(buffer)*atof(temp));
						} else if (op == '/'){
							sprintf(buffer, "%.02f" ,atof(buffer)/atof(temp));
						} else if (op == '-'){
							sprintf(buffer, "%.02f" ,atof(buffer)-atof(temp));
						} else err = 1;
						clrStr(temp);
						clrStr(msgStr);
						flag = 1;
					} else if (opSet && operandCheck(currChar) && flag){  //used to count position of operand
						j=0;
						for (i=0;buffer[i]!=NULL;i++) j++;
						bufferPos=j;
						op = currChar;
						flag = 0;
					} else if (opSet && operandCheck(currChar) && !flag){  
						err = 1; 																	// if already an operand set 
					} else if (!opSet && operandCheck(currChar)) {	// no operand previously, but we has one now..
						if ( (currChar != '-'  || currChar != '+' || currChar != '.') && !bufferPos ) err = 4; 
						op = currChar; 
						opSet = 1;
					}
					if (currChar != '=') {                            // increment the buffer and add the new character
						buffer[bufferPos] = currChar;                   // to our buffer
						bufferPos++;
					} else if (done) {
						break;                                          // not used
					} else displayMsg(buffer,buffer,0);               // displays the message
				}
			}
			lastChar = currChar;                                  // used so we don't have false inputs to the buffer

			for (i=0;i<15;i++) 
				msgStr[i] = (bufferPos>=15) ? buffer[i+(bufferPos - 15)] : buffer[i];
			                                                      // creates a truncated buffer for the display
			if (err>0) {
				displayMsg(errMsg[err],buffer,5000);                // displays errors if they occur 
				err = 0;
				while(scanTehThings() == " ");                      // makes you hit a button to remove error
				break;
			}
				Lcd_Set_Cursor(1,0);						                    // lcd stuff. set cursor position and display 
				Lcd_Write_String(msgStr);
							
		}
		while(!reset) delay(300);                               // reset stuff here
		bufferPos = err = 0;
		clrStr(buffer);
		clrStr(msgStr);
		Lcd_Clear();
	}
}

unsigned char scanTehThings(){
	unsigned int i,row;
	unsigned char keyIn [8];
	for ( i=0; i < 2; i++){
		if (i < 1){
			P0 = 0x0F;
			delay(40);
			keyIn[0] = a0 ? '0' : '1';
			keyIn[1] = a1 ? '0' : '1';
			keyIn[2] = a2 ? '0' : '1';
			keyIn[3] = a3 ? '0' : '1';
		} else {
			P0 = 0xF0;
			delay(40);
			keyIn[4] = a4 ? '0' : '1';
			keyIn[5] = a5 ? '0' : '1';
			keyIn[6] = a6 ? '0' : '1';
			keyIn[7] = a7 ? '0' : '1';
		}
	}
	for (i=0;i<4;i++) {
		if ( keyIn[i] == '1' ){
			row = i;
			for (i=4;i<8;i++) if ( keyIn[i] == '1') return values[row][i-4];
		} 
	}
	return ' ';
}

void delay(int time) {
  unsigned int x,y;
	for(x=0;x<time;x++){
    for(y=0;y<100;y++);
  }
}

void displayMsg(char * str,char * msg,unsigned int delVar){
	unsigned int i;
	for(i=0;str[i]!=NULL;i++) msg[i] = str[i];
	
	Lcd_Set_Cursor(2,0);
	Lcd_Write_String(msg);
	if (delVar > 0){ 							// if there is no delay
		clrStr(msg); 								// clear the string and
		delay(delVar); 							// resend blank to the display
		Lcd_Set_Cursor(2,0);	
		Lcd_Write_String(msg);
	}
}

void clrStr(char *a) {
	unsigned int i;
	for(i=0;a[i]!=NULL;i++) a[i] = ' ';
}

bit operandCheck(char op){
	if (op == '/' || op == '*' || op == '+' || op == '-' || op == '='){
		return 1;
	} else return 0;
}
