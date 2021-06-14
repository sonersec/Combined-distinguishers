/*
   Author: Soner Seckiner
*/

//#include "aes-independant.h"
#include "hal.h"
#include "simpleserial.h"
#include "cipher.h"
#include "constants.h"
#include <stdint.h>
#include <stdlib.h>

//#define RAM_DATA_BYTE uint8_t ALIGNED

const uint8_t expectedPlaintext[BLOCK_SIZE] = {0xef, 0xcd, 0x0ab, 0x89, 0x67, 0x45, 0x23, 0x01};
const uint8_t expectedKey[KEY_SIZE] = {0xff, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00};
const uint8_t expectedCiphertext[BLOCK_SIZE] = {0x29, 0xeb, 0xb5, 0x9f, 0xb1, 0xea, 0x67, 0xfc};


/*
uint8_t get_mask(uint8_t* m)
{
  aes_indep_mask(m);
  return 0x00;
}
*/
//May not fit chipwhisperer format
	RAM_DATA_BYTE state[BLOCK_SIZE];

    	RAM_DATA_BYTE key[KEY_SIZE];

    	RAM_DATA_BYTE roundKeys[ROUND_KEYS_SIZE];
//


void InitializeKey(uint8_t *k)
{
    uint8_t i;

    for(i = 0; i < KEY_SIZE; i++)
    {
        key[i] = k[i];
    }
}

uint8_t get_key(uint8_t* k)
{
	InitializeKey(k); //need to get from serial port
	//aes_indep_key(k);
	return 0x00;
	
	
}

void InitializeState(uint8_t *pt)
{
    uint8_t i;

    for(i = 0; i < BLOCK_SIZE; i++)
    {
        state[i] = pt[i];
    }
}

uint8_t get_pt(uint8_t* pt)
{
    InitializeState(pt); // state is plaintext and need to get from serialport
	//aes_indep_enc_pretrigger(pt);
    
	trigger_high();

  #ifdef ADD_JITTER
  for (volatile uint8_t k = 0; k < (*pt & 0x0F); k++);
  #endif

	//BEGIN_ENCRYPTION_KEY_SCHEDULE(); //this function is defined in common.h to start the cycle count
    RunEncryptionKeySchedule(key, roundKeys);
    //END_ENCRYPTION_KEY_SCHEDULE();
	
	
	//BEGIN_ENCRYPTION(); //This function is defined in common.h to start the cycle count
    Encrypt(state, roundKeys); //This is the function where real encrpytion starts
    //END_ENCRYPTION();
	
	//aes_indep_enc(pt); 
	trigger_low();
    
    //aes_indep_enc_posttrigger(pt);
    
	simpleserial_put('r', BLOCK_SIZE, state); //state should be updated to ciphertext but for now leave it plaintext
	return 0x00;
}


uint8_t reset(uint8_t* x)
{
    // Reset key here if needed
	return 0x00;
}


void InitializeDevice()
{
//#if defined(DEBUG) && (DEBUG_LOW == (DEBUG_LOW & DEBUG))
//    stdout = &mystdout;
//#endif
}

void StopDevice()
{
#if defined(DEBUG) && (DEBUG_LOW == (DEBUG_LOW & DEBUG))
    sleep_cpu();
#endif
}





int main(void)
{
	//uint8_t tmp[KEY_LENGTH] = {DEFAULT_KEY};
	
	

	//Chipwhisperer initialize
    platform_init(); //this is in the hall folder, find a way to describe the platform XMEGA
    init_uart();
    trigger_setup();
	//
	
	InitializeDevice(); //prints the terminal in debug mode, ineffective
	
	
	
	
	
	
	//aes_indep_init();
	//aes_indep_key(tmp);

    /* Uncomment this to get a HELLO message for debug */

    putch('h');
    putch('e');
    putch('l');
    putch('l');
    putch('o');
    putch('\n');

	simpleserial_init();
    simpleserial_addcmd('k', KEY_SIZE, get_key); //Key size is 16
    simpleserial_addcmd('p', BLOCK_SIZE,  get_pt); //Block size is 8
    simpleserial_addcmd('x',  0,   reset);
    //simpleserial_addcmd('m', 18, get_mask);
    while(1)
        simpleserial_get();
	
	DONE();
    StopDevice();
}
