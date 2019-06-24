#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

#include "ws2812.h"
#include "common.h"
#include "uart.h"

#define WS2812_PIN   12
#define WS2812_COUNT 12

//----------------------------------------------------------------------------------------------------
// main
//----------------------------------------------------------------------------------------------------
int main(void)
	{
	ws2812_string_t string;

	uart_init_115200(); // initialize uart
printf("uart initialized\n");

	ws2812_init(&string, WS2812_PIN, WS2812_COUNT);
printf("string initialized\n");
getchar();

	string.led[0][LED_COLOR_G]  = 8;
	string.led[0][LED_COLOR_R]  = 0;
	string.led[0][LED_COLOR_B]  = 0;

	string.led[1][LED_COLOR_G]  = 8;
	string.led[1][LED_COLOR_R]  = 8;
	string.led[1][LED_COLOR_B]  = 0;

	string.led[2][LED_COLOR_G]  = 0;
	string.led[2][LED_COLOR_R]  = 8;
	string.led[2][LED_COLOR_B]  = 0;

	string.led[3][LED_COLOR_G]  = 0;
	string.led[3][LED_COLOR_R]  = 8;
	string.led[3][LED_COLOR_B]  = 8;

	string.led[4][LED_COLOR_G]  = 0;
	string.led[4][LED_COLOR_R]  = 0;
	string.led[4][LED_COLOR_B]  = 8;

	string.led[5][LED_COLOR_G]  = 8;
	string.led[5][LED_COLOR_R]  = 0;
	string.led[5][LED_COLOR_B]  = 8;

	string.led[6][LED_COLOR_G]  = 8;
	string.led[6][LED_COLOR_R]  = 2;
	string.led[6][LED_COLOR_B]  = 2;

	string.led[7][LED_COLOR_G]  = 8;
	string.led[7][LED_COLOR_R]  = 8;
	string.led[7][LED_COLOR_B]  = 2;

	string.led[8][LED_COLOR_G]  = 2;
	string.led[8][LED_COLOR_R]  = 8;
	string.led[8][LED_COLOR_B]  = 2;

	string.led[9][LED_COLOR_G]  = 2;
	string.led[9][LED_COLOR_R]  = 8;
	string.led[9][LED_COLOR_B]  = 8;

	string.led[10][LED_COLOR_G] = 2;
	string.led[10][LED_COLOR_R] = 2;
	string.led[10][LED_COLOR_B] = 8;

	string.led[11][LED_COLOR_G] = 8;
	string.led[11][LED_COLOR_R] = 2;
	string.led[11][LED_COLOR_B] = 8;

	ws2812_send(&string);
printf("string 1 displayed\n");
getchar();

	for (uint8_t i = 0; i < WS2812_COUNT; i++)
		{
		uint8_t factor = 1;
		string.led[i][0] = (uint8_t)((i+1)*factor);
		string.led[i][1] = (uint8_t)((i+1)*factor);
		string.led[i][2] = (uint8_t)((i+1)*factor);
		}
	ws2812_send(&string);
printf("string 2 displayed\n");
getchar();

	for (uint8_t i = 0; i < WS2812_COUNT; i++)
		for (uint8_t j = 0; j < 3; j++)
			string.led[i][j] = 0;

	ws2812_send(&string);
printf("string cleared\n");
printf("end program\n");
	}
