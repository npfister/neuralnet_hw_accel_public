/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include "system.h"
#include "altera_avalon_performance_counter.h"

// Global variables
static volatile int *neunet_acc = (int *) NEURAL_NET_ACCELERATOR_0_BASE;//base address of neunet_accelerator

// Function declarations
void test_mmregs ( void );

/***************************************************/
/* WRITE & READ FROM MEMORY MAPPED REGS OF NEUNET  */
/***************************************************/
void test_mmregs ( void ){
 	int i,value;//loop counter
 	static int test[8]={0x73756868, 0x68686868, 0x68206475, 0x64652121, 0x21212120, 0x202d2d2d, 0x4e69636b, 0x20203b29};
 	volatile int * temp_neunet_acc;//for incrementing in for loop
 	char c0,c1,c2,c3;

 	//write test
 	for(i=0;i<8;i++){
 		temp_neunet_acc = neunet_acc + i;
  		*temp_neunet_acc = test[i];
	}

 	//read  test
 	printf("\nREAD MM_REG CONTENTS: ");
 	for(i=0;i<8;i++){
 		temp_neunet_acc = neunet_acc + i;
 		value = *temp_neunet_acc;
 		c3 = (char) ((value >> 24) & 0xFF);
 		c2 = (char) ((value >> 16) & 0xFF);
 		c1 = (char) ((value >>  8) & 0xFF);
 		c0 = (char) ( value        & 0xFF);
  		printf("%c%c%c%c",c3,c2,c1,c0);//*temp_neunet_acc to read value, %s expects pointer
	}
	printf("\n");
}
/*
int main()
{
  printf("Hello from Nios II!\n");
  
  test_mmregs();//test memory mapped registers function, write to 8 and reads back 8 ints

  return 0;
}*/
