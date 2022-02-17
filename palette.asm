
palette_cache	EQU $da


Palette00:		; 25 bytes

	hex 0f		;screen color
	hex 022830	;background 0
        hex 071624	;background 1
        hex 02113c	;background 2
        hex 0b1a3b	;background 3
        hex 192939	;sprite 0
        hex 132130	;sprite 1
        hex 071727	;sprite 2
        hex 013530	;sprite 3
        
        
; bg 0 - stars 1
; bg 1 - stars 2
; bg 2 - menu screens / bg enemies
; bg 3 - dashboard
; spr 0 - player
; spr 1 - enemy
; spr 2 - enemy
; spr 3 - enemy


	; XXX need a way to load certain palettes
        ; at certain times for certain enemies


        
palette_init: subroutine
	ldy #$00
.loop
	lda Palette00,y
        sta pal_uni_bg,y
        iny
        cpy #25
        bne .loop
        rts
       
        
        
palette_next_rainbow_color: subroutine
	; a = current and return color
        sta temp00
        inc temp00
        lda temp00
        and #$0f
        cmp #$0d
        beq .wrap
        lda temp00
        rts
.wrap
        lda temp00
        sec
        sbc #$0c
        rts
     
     
palette_update: subroutine
	lda #$00
        cmp state_fade_in
        beq .dont_fade_in
        jmp palette_fade_in_update
.dont_fade_in
	cmp state_fade_out
        beq .dont_fade_out
        jmp palette_fade_out_update
.dont_fade_out
	; do normal
        ldy #$00
.loop
        lda pal_uni_bg,y
        sta palette_cache,y
        iny
        cpy #25
        bne .loop
	rts


palette_fade_in_init: subroutine
        lda #$20
        sta game_mode
        lda #$40
        sta pal_fade_c ; frame counter
palette_fade_in_update: subroutine
	lda pal_fade_c
        and #%11110000
        sta pal_fade_offset
	ldx #$00
.loop
	lda pal_uni_bg,x
        sec
        sbc pal_fade_offset
        bcs .no_reset
        lda #$0f
.no_reset
	sta palette_cache,x
        inx
        cpx #25
        bne .loop
        lda pal_fade_c
        sec
        sbc #$03
        cmp #$10
        bne .fade_mode_not_done
        lda pal_fade_target
        sta game_mode
.fade_mode_not_done
	sta pal_fade_c
	rts
        
palette_fade_out_init: subroutine
        lda #$21
        sta game_mode
        lda #$10
        sta pal_fade_c ; frame counter
palette_fade_out_update: subroutine
	lda pal_fade_c
        and #%11110000
        sta pal_fade_offset
	ldx #$00
.loop
	lda pal_uni_bg,x
        sec
        sbc pal_fade_offset
        bcs .no_reset
        lda #$0f
.no_reset
	sta palette_cache,x
        inx
        cpx #25
        bne .loop
        lda pal_fade_c
        clc
        adc #$03
        cmp #$5e
        bne .fade_mode_not_done
        lda pal_fade_target
        sta game_mode
        jmp game_init
.fade_mode_not_done
	sta pal_fade_c
	rts

	; 12 + 32 x 7 = 236 cycles
palette_render: subroutine
	PPU_SETADDR $3f00
	lda palette_cache
        sta PPU_DATA
        lda palette_cache+1
        sta PPU_DATA
        lda palette_cache+2
        sta PPU_DATA
        lda palette_cache+3
        sta PPU_DATA
	lda palette_cache
        sta PPU_DATA
        lda palette_cache+4
        sta PPU_DATA
        lda palette_cache+5
        sta PPU_DATA
        lda palette_cache+6
        sta PPU_DATA
	lda palette_cache
        sta PPU_DATA
        lda palette_cache+7
        sta PPU_DATA
        lda palette_cache+8
        sta PPU_DATA
        lda palette_cache+9
        sta PPU_DATA
	lda palette_cache
        sta PPU_DATA
        lda palette_cache+10
        sta PPU_DATA
        lda palette_cache+11
        sta PPU_DATA
        lda palette_cache+12
        sta PPU_DATA
	lda palette_cache
        sta PPU_DATA
        lda palette_cache+13
        sta PPU_DATA
        lda palette_cache+14
        sta PPU_DATA
        lda palette_cache+15
        sta PPU_DATA
	lda palette_cache
        sta PPU_DATA
        lda palette_cache+16
        sta PPU_DATA
        lda palette_cache+17
        sta PPU_DATA
        lda palette_cache+18
        sta PPU_DATA
	lda palette_cache
        sta PPU_DATA
        lda palette_cache+19
        sta PPU_DATA
        lda palette_cache+20
        sta PPU_DATA
        lda palette_cache+21
        sta PPU_DATA
	lda palette_cache
        sta PPU_DATA
        lda palette_cache+22
        sta PPU_DATA
        lda palette_cache+23
        sta PPU_DATA
        lda palette_cache+24
        sta PPU_DATA
	rts