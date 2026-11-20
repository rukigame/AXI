/*
 * main.c
 *
 *  Created on: 2026. 11. 20.
 *      Author: kccistc
 */


#include <stdio.h>
#include <stdint.h>
#include "xil_printf.h"
#include "sleep.h"

typedef struct {
    volatile uint32_t CR;
    volatile uint32_t ODR;
    volatile uint32_t IDR;
}GPIO_TypeDef;

#define GPIOA_BASEADDR	0x44a00000
#define GPIOB_BASEADDR	0x44a10000
#define GPIOC_BASEADDR	0x44a20000
#define GPIOD_BASEADDR	0x44a30000
#define GPIOE_BASEADDR	0x44a40000
//#define GPIOA_CR		(*(volatile uint32_t *)(GPIOA_BASEADDR + 0x00))
//#define GPIOA_ODR		(*(volatile uint32_t *)(GPIOA_BASEADDR + 0x04))
//#define GPIOA_IDR		(*(volatile uint32_t *)(GPIOA_BASEADDR + 0x08))

#define GPIOA			((GPIO_TypeDef *)GPIOA_BASEADDR)
#define GPIOB			((GPIO_TypeDef *)GPIOB_BASEADDR)
#define GPIOC			((GPIO_TypeDef *)GPIOC_BASEADDR)
#define GPIOD			((GPIO_TypeDef *)GPIOD_BASEADDR)
#define GPIOE			((GPIO_TypeDef *)GPIOE_BASEADDR)

int main()
{
    //init_platform();

    print("Hello World\n\r");
    print("Successfully ran Hello World application\n");
    //cleanup_platform();

    //*(uint32_t *)(0x44a00000 + 0x00) = 0x0f;	//CR, 4bit output mode
    //GPIOA_CR = 0x0f;
    GPIOA->CR = 0x0f;
    GPIOB->CR = 0x0f;
    GPIOC->CR = 0x0f;
    GPIOD->CR = 0x0f;
    GPIOE->CR = 0x00;

    uint16_t led = 0x0001;
    int dir =0;
    while(1)
    {

    	if(GPIOE->IDR == 0x02){
    		dir =1;
    	}
    	else if(GPIOE->IDR == 0x04){
    		dir =2;
    	}
    	if(dir==1){
    		led = (led << 1) | (led >> 15);
    	}
    	else if(dir ==2){
    		led = (led >> 1) | (led << 15);
    	}
    	GPIOA->ODR =  led        & 0x0F;   // bit 3~0   ¡æ LD0~3
    	GPIOB->ODR = (led >> 4)  & 0x0F;   // bit 7~4   ¡æ LD4~7
    	GPIOC->ODR = (led >> 8)  & 0x0F;   // bit 11~8  ¡æ LD8~11
    	GPIOD->ODR = (led >> 12) & 0x0F;   // bit 15~12 ¡æ LD12~15
    	usleep(100000);

    }


    return 0;
}
