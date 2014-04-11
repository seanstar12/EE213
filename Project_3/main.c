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

//A simple delay function
void delay(int a) {
  for (int i=0; i < a; i++);
}

//Toggles rows and columns to read pins
//from the keypad
char read() {
  for(var i=0; i<2; i++) {
    P3 = byteSwap[i];
    for (var j=0; j<4; j++) {
      if (keys[i][j]){
        return values[i][j];
      } else {
        return 'X';
      }
    }
  }
} 

void main() {
  char keyVal,keyStore;

  

}
