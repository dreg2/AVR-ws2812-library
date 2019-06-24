#include <avr/io.h>
#include <util/delay.h>

#include "ws2812.h"

// reset delay in microseconds
#define RST_US  10

//----------------------------------------------------------------------------------------------------
// initialize led string structure
//----------------------------------------------------------------------------------------------------
void ws2812_init(ws2812_string_t *string, uint8_t pin, uint8_t count)
	{
	// initialize structure fields
	pin_init_ard(&string->pin, pin);
	pin_state_set(&string->pin, PIN_OUT_LOW);
	string->count = count;

	// clear all led data
	for (uint8_t i = 0; i < string->count; i++)
		string->led[i][LED_COLOR_G] = string->led[i][LED_COLOR_R] = string->led[i][LED_COLOR_B] = 0;
	}

//----------------------------------------------------------------------------------------------------
// send data to led string
//----------------------------------------------------------------------------------------------------
void ws2812_send(ws2812_string_t *string)
	{
	// call assembly xmit function with structure fields
	ws2812_xmit(string->pin.port_reg, string->pin.pin_mask, &string->led[0][0], (uint8_t)(string->count * LED_COLORS));
	_delay_us(RST_US); // latch delay
	}
