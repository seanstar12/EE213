#include <REG932.H>
#include <stdlib.h>

void SerTx(unsigned char);
int SerRx(unsigned char *);
int uart_init (void);
void delay(int);
void printString(unsigned char *, int, int);
void printChar(unsigned char);
int printWelcome();

void main(void) {
	char byteBuf;
	char num[2]= "";
	int numLen[2] = {0,0};

	int numSelect = 0;
	int t2=0;
	int welcomeVar = 0;
	int uartEn = uart_init();
	

	while(uartEn) {
		if (!welcomeVar) welcomeVar = printWelcome();
		
		if (SerRx(&byteBuf)){
			int temp = numLen[numSelect];
			if ( byteBuf == 0x0D) {
				printString("====================",20,1);
			  t2 = atoi (num[0]);
				printString((char)t2,20,1);
				
			} else if (byteBuf == "+" || byteBuf == 0x2B ) {
				if (numLen[numSelect] < 1) printString("Enter a Number Frist",21,1);
				else {
					printString("",1,1);
					printString("+",1,1);
					numSelect++;
				}
			} else if (numLen[numSelect] < 32 && numSelect == 0){
					num[0][temp] = byteBuf;
					numLen[numSelect]++;
			} else if (numLen[numSelect] < 32 && numSelect == 1){
					num[1][temp] = byteBuf;
					numLen[numSelect]++;
			}
		}		
		printString(num[numSelect],numLen[numSelect],0);

	}
}

int printWelcome(){
	printString("Welcome To Our Calculator",26,1);
	printString("Input the First Number...",26,1);
}

void printString(unsigned char * str,int length, int isStr) {
  int j;
	if (!length) length = 1;
	
	for (j=0;j<length;j++) SerTx(str[j]);
	if (isStr){
		printChar(0x0A);
	}
	printChar(0x0D);

}

void printChar(unsigned char character){
	SerTx(character);
}

void SerTx(unsigned char x) {
	SBUF = x; // put the char in SBUF register
	while(TI == 0); // wait until transmitted
	TI = 0;
}

int SerRx(unsigned char * pX){
  while(RI == 0); // wait until received
  RI = 0;
  *pX = SBUF; // copy the data in SBUF to (pX)
	return 1;
}

void delay(int time) {
  unsigned int x, y;
	for(x=0;x<1275;x++){
    for(y=0;y<time;y++);
  }
}

int uart_init (void) {
	P0M1 = 0x00;
  P0M2 = 0x00;
  P2M1 = 0x00;
  P2M2 = 0x00;
	
  // configure UART
  // clear SMOD0
  PCON &= ~0x40;
  SCON = 0x50;
  // set or clear SMOD1
  PCON &= 0x7f;
  PCON |= (0 << 8);
  SSTAT = 0x20;

  // enable break detect
  AUXR1 |= 0x40;

  // configure baud rate generator
  BRGCON = 0x00;
  BRGR0 = 0xF0;
  BRGR1 = 0x02;
  BRGCON = 0x03;

  // TxD = push-pull, RxD = input
  P1M1 &= ~0x01;
  P1M2 |= 0x01;
  P1M1 |= 0x02;
  P1M2 &= ~0x02;


  // set isr priority to 0
  IP0 &= 0xEF;
  IP0H &= 0xEF;
	
  // enable uart interrupt
	ESR = 0;
	EST = 0;
	EA = 1;

	return 1;
}