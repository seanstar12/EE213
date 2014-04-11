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

//int row[3] = {R0,R1,R2,R3};
//int row[3] = {P3^0,P3^1,P3^2,P3^3};
//int col[3] = {C0,C1,C2,C3};
int keys[7] = {R0,R1,R2,R3,C0,C1,C2,C3};
char values[15] = {'F','3','2','1','E','6','5','4','D','9','8','7','C','B','0','A'};

//A simple delay function
void delay(int a) {
  for (int i=0; i < a; i++);
}

//Toggles rows and columns to read pins
//from the keypad
char read(int keys[]) {
  int err = 0;
  int byteSwap[1] = {0x00,0xF0,0x0F}; 
  char data = '';

  for(var i=1; i<3; i++) {
    P3 = byteSwap[i];
    for (var j=0; j<4; j++) {
      if (keys[i][j]){
        data = values[];
      }
    }
  }
}  
