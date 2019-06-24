#ifndef WS2812_H_
#define WS2812_H_

#include "pin.h"

#define LED_MAX    64
#define LED_COLORS 3

#define LED_COLOR_G 0
#define LED_COLOR_R 1
#define LED_COLOR_B 2

typedef struct ws2812_string
	{
	pin_t             pin;
	uint8_t           count;
	uint8_t           led[LED_MAX][LED_COLORS];
	} ws2812_string_t;

// functions
void ws2812_init(ws2812_string_t *string, uint8_t pin, uint8_t count);
void ws2812_send(ws2812_string_t *string);
void ws2812_xmit(volatile uint8_t *port_reg, uint8_t pin_mask, uint8_t *data, uint8_t len);

#endif // WS2812_H_
