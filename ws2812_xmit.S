;
; ws2812_xmit - transmit bytes to ws2812 string
;    r24:r25   volatile uint8_t *port_reg
;    r22       uint8_t pin_mask
;    r20:r21   uint8_t *data
;    r18       uint8_t len

; delay times for data line states in nanoseconds
#define T0H_NS  350
#define T1H_NS  650
#define T0L_NS  800
#define T1L_NS  500

; macro to delay for count nanoseconds
.macro	DELAY_NSEC nsec=0
        .rept  ((\nsec) /  (1000000000 / F_CPU))
        nop
        .endr
.endm

	.text
	.global	ws2812_xmit
	.type	ws2812_xmit, @function

ws2812_xmit:
	; prologue
	push   r16
	push   r17
	push   r28
	push   r29
	clr    r1            ; clear zero-register

	; set X register to point to port_reg
	movw   X,   r24      ; load X register (r26:r27) with port_reg pointer

	; set r24 to port_0 (data line low) and r25 to port_1 (data line high)
	ld     r25, X        ; load *port_reg into r25
	mov    r24, r22      ; copy pin_mask into r24
	com    r24           ; invert pin_mask in r24
	and    r24, r25      ; and *port_reg with ~pin_mask (port_0)
	or     r22, r25      ; or *port_reg with pin_mask (port_1)

	; bring data line low
	st     X,   r24      ; store port_0 to port_reg

	; set up data loop
        movw   Z,   r20      ; copy data pointer to Z (current)
        movw   Y,   r20      ; copy data pointer to Y (limit)
        add    r28, r18      ; add len  to Y (lsb)
        adc    r29, r1       ; add zero to Y (msb)

BYTE_LOOP: ; loop through data bytes
	ld     r25, Z        ; load r25 with data byte
        ldi    r16, 0x80     ; load initial bitmask

BIT_LOOP: ; loop through byte bits
	cli                  ; turn off interrups

	mov    r17, r25      ; copy data byte into r17
        and    r17, r16      ; and data byte with bitmask
        brne   BIT_ONE       ; handle one-bit

BIT_ZERO: ; send 0-bit
        st     X,   r22      ; bring data line high
	DELAY_NSEC T0H_NS    ; zero-bit high delay
	st     X,   r24      ; bring data line low
	DELAY_NSEC T0L_NS    ; zero-bit low delay
	rjmp   BIT_CONTINUE  ; continue

BIT_ONE: ; send 1-bit
        st     X,   r22      ; bring data line high
	DELAY_NSEC T1H_NS    ; one-bit high delay
	st     X,   r24      ; bring data line low
	DELAY_NSEC T1L_NS    ; one-bit low delay

BIT_CONTINUE:
	sei                  ; turn on interrupts
	lsr    r16           ; right shift bitmask
        brcc   BIT_LOOP      ; loop if carry clear (1 still in bitmask)

        adiw   Z,   1        ; increment data pointer (Z)
	cp     r30, r28      ; compare Z and Y (msb)
	cpc    r31, r29      ; compare Z and Y (lsb)
	brlo   BYTE_LOOP     ; loop if Z less than Y

	; epilogue
	pop    r29
        pop    r28
        pop    r17
        pop    r16
        ret
        .size   ws2812_xmit, .-ws2812_xmit

