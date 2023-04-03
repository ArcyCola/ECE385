// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{

	volatile unsigned int *LED_PIO = (unsigned int*)0x40; //make a pointer to access the PIO block
	volatile unsigned int *SW_PIO = (unsigned int*)0x70;
	volatile unsigned int *KEY1_PIO = (unsigned int*)0x60;


//	int i = 0;
//	*LED_PIO = 0; //clear all LEDs
//	while ( (1+1) != 3) //infinite loop
//	{
//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO |= 0x1; //set LSB
//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO &= ~0x1; //clear LSB
//	}
//	return 1; //never gets here





	int count = 0;
 	*LED_PIO = 0; //clear all LEDs
 	//active high
 	while ( (1+1) != 3) { //infinite loop to always check
		if (!(*KEY1_PIO)) { //if key1 is pressed
			while (!(*KEY1_PIO)) { //to make sure to add only once
				//break;
			}
			count += *SW_PIO;
			if (count > 255) {
				count -= 256;
			}
		}
		*LED_PIO = count;
 	}
 	return 1;
}
