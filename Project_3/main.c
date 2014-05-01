/*
  COMP_ENG 213: DIGITAL SYSTEMS DESIGN SP2014 -- Project 3
  Fun times with the 8051 Microcontroller.
  Originally supposed to display output via serial, but we're "pro's".
  Creators of this monstrosity: 
    Sean Starnes
    Benjamin [redacted](for his protection)

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

extern float atof (char *s1);
extern int sprintf  (char *, const char *, ...);

sbit RS = P1^4;
sbit EN = P1^6;
sbit D0 = P2^0;
sbit D1 = P2^1;
sbit D2 = P2^2;
sbit D3 = P2^3;
sbit D4 = P2^4;
sbit D5 = P2^5;
sbit D6 = P2^6;
sbit D7 = P2^7;

sbit reset = P1^1;

sbit a0 = P0^0;
sbit a1 = P0^1;
sbit a2 = P0^2;
sbit a3 = P0^3;
sbit a4 = P0^4;
sbit a5 = P0^5;
sbit a6 = P0^6;
sbit a7 = P0^7;

code unsigned char values [4][4] =  { '7', '4', '1', '0',
																			'8', '5', '2', '.',
																			'9', '6', '3', '-',
																			'/', '*', '+', '='};
code unsigned char errMsg [5][15] =  {
																			"",
																			"No Implement!",
																			"Too Big!",
																			"Resetting...",
																			"I Can't Math!" };

unsigned char scanTehThings();
void delay(int);
void displayMsg(unsigned char *,unsigned char *,unsigned int);
bit operandCheck(char);
void clrStr(char *);
void doMaths(unsigned char*,unsigned char*);
void itoa(int, char *);

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
		
		while(reset){
			unsigned int i,j;
			unsigned char temp[12];
			
			currChar = scanTehThings();
			
			if (currChar != ' ' && currChar != lastChar) {  // if new button is pressed
				if (bufferPos < 24) {  												// if within our buffer zone
					if (opSet && currChar == '=') {
						Lcd_Clear();
						clrStr(msgStr);

						for (i=0;buffer[i]!=NULL;i++){
							if (buffer[i] == op){
								buffer[i]= ' ';
								for(j=0;buffer[j+1+i]!=NULL;j++){
									temp[j] = buffer[j+1+i];
									buffer[j+1+i] = ' ';
								} 
								break;
							}
						}
						if (op == '+'){
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
					} else if (opSet && operandCheck(currChar) && flag){
						j=0;
						for (i=0;buffer[i]!=NULL;i++) j++;
						bufferPos=j;
						op = currChar;
						flag = 0;
					} else if (opSet && operandCheck(currChar) && !flag){  
						err = 1; 																	// if already an operand set
					} else if (!opSet && operandCheck(currChar)) {	// no operand - good to go.
						if ( (currChar != '-'  || currChar != '+' || currChar != '.') && !bufferPos ) err = 4; 
						op = currChar;
						opSet = 1;
					}
					if (currChar != '=') {
						buffer[bufferPos] = currChar;
						bufferPos++;
					} else if (done) {
						break;
					} else displayMsg(buffer,buffer,0);
				}
			}
			lastChar = currChar;

			for (i=0;i<15;i++) 
				msgStr[i] = (bufferPos>=15) ? buffer[i+(bufferPos - 15)] : buffer[i];
			
			if (err>0) {
				displayMsg(errMsg[err],buffer,5000);
				err = 0;
				while(scanTehThings() == " ");
				break;
			}
				Lcd_Set_Cursor(1,0);						
				Lcd_Write_String(msgStr);
							
		}
		while(!reset) delay(300);
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
