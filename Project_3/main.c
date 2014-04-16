#include <REG932.H>

//Define Pins to usable names
sbit R0=P3^0;
sbit R1=P3^1;
sbit R2=P3^2;
sbit R3=P3^3;
sbit C0=P3^4;
sbit C1=P3^5;
sbit C2=P3^6;
sbit C3=P3^7;

int keys[2][4] = {  R0,R1,R2,R3,
                    C0,C1,C2,C3 };

int byteSwap[2] = {0xF0,0x0F}; 

char values[4][4] = { 'F','3','2','1',
								'E','6','5','4',

								'D','9','8','7',
								'C','B','0','A' };
					  
void SerTx(unsigned char);
void SerRx(unsigned char *);
void uart_init (void);
void delay(int);
void printString(unsigned char *);

//Toggles rows and columns to read pins
//from the keypad
char read() {
  for(var i=0; i<2; i++) {
    P3 = byteSwap[i];
    for (var j=0; j<4; j++) {
      if (keys[i][j]) return values[i][j];
      else return 'X';
    }
  }
} 

void main() {
	char byteBuf;
	char stuff[17] = "Allo";
	int position = 0;

	uart_init();
	
	while(1) {
	//	SerRx(&byteBuf); // read byte from serial port
	//	SerTx(byteBuf); // send byte back to serial port
	  SerTx('p');
	//  printString(&stuff);
	//	delay(3000);
	}
}

// don't think this will work because of interrupts
// they are lame and i hate them.
void printString(unsigned char * str) {
  int j;
	for (j=0;j<sizeof(str);j++){
	 // SerTx(str[j]);
		SerTx('g');
	}
}

void SerTx(unsigned char x) {
	SBUF = x; // put the char in SBUF register
	while(TI == 0); // wait until transmitted
	TI = 0;
}

void delay(int time) {
  unsigned int x, y;
	for(x=0;x<1275;x++){
    for(y=0;y<time;y++);
  }
}

void uart_init (void) {
  
  P0M1 = 0x00;
  P0M2 = 0x00;
  P1M1 = 0x00;
  P1M2 = 0x00;
  P2M1 = 0x00;
  P2M2 = 0x00;
  P3M1 = 0x00;
  P3M2 = 0x00;
	
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
  ESR = 1;
  EST =1 ;
  EA =1;
}
