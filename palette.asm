
palette_cache	EQU 231


Palette00:		; 25 bytes

	hex 0f		;screen color
	hex 022830	;background 0
        hex 071624	;background 1
        hex 02113c	;background 2
        hex 0b1a3b	;background 3
        hex 192939	;sprite 0
        ;hex 132130	;sprite 1; old birb palete
        ;hex 051637	; chomps
        hex 122130	; vamp eyes & bats
        ;hex 071727	;sprite 2
        hex 150037	; vamp head/face
        hex 013530	;sprite 3 
        
        
; bg 0 - stars bg_tiles 1
; bg 1 - stars bg_tiles 2
; bg 2 - menu screens / bg enemies
; bg 3 - dashboard
; spr 0 - player
; spr 1 - enemy
; spr 2 - enemy / stars sprites 1
; spr 3 - enemy / stars sprite 2


	; XXX need a way to load certain palettes
        ; at certain times for certain enemies

   

        
palette_init: subroutine
	ldy #$00
.loop
	lda Palette00,y
        sta pal_uni_bg,y
        lda #$00
        sta palette_cache,y
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
        
        
palette_state_reset:
	lda #$00
        sta state_fade_in
        sta state_fade_out
        rts


palette_fade_in_init: subroutine
	; a = init callback index
        sta pal_fade_target
        ; make sure we're not already fading out
	lda state_fade_out
        cmp #$00
        bne .init_skip
.init_fade
        lda #$00
        sta pal_fade_c ; frame counter
        lda #$ff
        sta state_fade_in
.init_skip
        rts
        
palette_fade_in_update: subroutine
	lda pal_fade_c
        ora #%00001111
        sta pal_fade_offset
	ldx #$00
.loop
	lda pal_uni_bg,x
        and pal_fade_offset
	sta palette_cache,x
        inx
        cpx #25
        bne .loop
        lda pal_fade_c
        clc
        adc #$03
        cmp #$40
        bcc .fade_mode_not_done
        jsr palette_state_reset
.fade_mode_not_done
	sta pal_fade_c
	rts
        
        
palette_fade_out_init: subroutine
	; a = init callback index
        sta pal_fade_target
        ; make sure we're not already fading out
	lda state_fade_out
        cmp #$00
        bne .init_skip
.init_fade
        lda #$10
        sta pal_fade_c ; frame counter
        lda #$ff
        sta state_fade_out
.init_skip
        rts
        
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
        cmp #$60
        bcc .fade_mode_not_done
        jsr palette_state_reset
	lda pal_fade_target
        jmp state_init_call
.fade_mode_not_done
	sta pal_fade_c
	rts
        

	; 12 + 32 x 7 = 236 cycles
palette_render: subroutine
	PPU_SETADDR $3f00
        ldx #0
        ldy #8
.loop
	lda palette_cache
        sta PPU_DATA
        inx
        lda palette_cache,x
        sta PPU_DATA
        inx
        lda palette_cache,x
        sta PPU_DATA
        inx
        lda palette_cache,x
        sta PPU_DATA
        dey
        bne .loop
	rts