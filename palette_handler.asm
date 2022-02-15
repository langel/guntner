
palette_cache	EQU $0158


Palette00:

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
; bg 2 - menu screens
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
       
        
palette_cache_colors: subroutine
	ldy #$00
.loop
	lda pal_uni_bg,y
        sta palette_cache,y
        iny
        cpy #25
        bne .loop
	rts
        
palette_cache_restore: subroutine
	ldy #$00
.loop
        lda palette_cache,y
	sta pal_uni_bg,y
        iny
        cpy #25
        bne .loop
	rts


palette_fade_in_init: subroutine
        lda #$20
        sta game_mode
        jsr palette_cache_colors
        lda #$40
        sta pal_fade_c ; frame counter
palette_fade_in_frame: subroutine
	lda pal_fade_c
        and #%11110000
        sta pal_fade_offset
	ldx #$00
.loop
	lda palette_cache,x
        sec
        sbc pal_fade_offset
        bcs .no_reset
        lda #$0f
.no_reset
	sta pal_uni_bg,x
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
        jmp palette_cache_restore
.fade_mode_not_done
	sta pal_fade_c
	rts
        
palette_fade_out_init: subroutine
        lda #$21
        sta game_mode
        jsr palette_cache_colors
        lda #$10
        sta pal_fade_c ; frame counter
palette_fade_out_frame: subroutine
	lda pal_fade_c
        and #%11110000
        sta pal_fade_offset
	ldx #$00
.loop
	lda palette_cache,x
        sec
        sbc pal_fade_offset
        bcs .no_reset
        lda #$0f
.no_reset
	sta pal_uni_bg,x
        inx
        cpx #25
        bne .loop
        lda pal_fade_c
        clc
        adc #$03
        cmp #$40
        bne .fade_mode_not_done
        jsr palette_cache_restore
        lda pal_fade_target
        sta game_mode
        jmp game_init
.fade_mode_not_done
	sta pal_fade_c
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
        

	; 12 + 32 x 7 = 236 cycles
palette_frame_update: subroutine
	PPU_SETADDR $3f00
	lda pal_uni_bg
        sta PPU_DATA
        lda pal_bg_0_1
        sta PPU_DATA
        lda pal_bg_0_2
        sta PPU_DATA
        lda pal_bg_0_3
        sta PPU_DATA
	lda pal_uni_bg
        sta PPU_DATA
        lda pal_bg_1_1
        sta PPU_DATA
        lda pal_bg_1_2
        sta PPU_DATA
        lda pal_bg_1_3
        sta PPU_DATA
	lda pal_uni_bg
        sta PPU_DATA
        lda pal_bg_2_1
        sta PPU_DATA
        lda pal_bg_2_2
        sta PPU_DATA
        lda pal_bg_2_3
        sta PPU_DATA
	lda pal_uni_bg
        sta PPU_DATA
        lda pal_bg_3_1
        sta PPU_DATA
        lda pal_bg_3_2
        sta PPU_DATA
        lda pal_bg_3_3
        sta PPU_DATA
	lda pal_uni_bg
        sta PPU_DATA
        lda pal_spr_0_1
        sta PPU_DATA
        lda pal_spr_0_2
        sta PPU_DATA
        lda pal_spr_0_3
        sta PPU_DATA
	lda pal_uni_bg
        sta PPU_DATA
        lda pal_spr_1_1
        sta PPU_DATA
        lda pal_spr_1_2
        sta PPU_DATA
        lda pal_spr_1_3
        sta PPU_DATA
	lda pal_uni_bg
        sta PPU_DATA
        lda pal_spr_2_1
        sta PPU_DATA
        lda pal_spr_2_2
        sta PPU_DATA
        lda pal_spr_2_3
        sta PPU_DATA
	lda pal_uni_bg
        sta PPU_DATA
        lda pal_spr_3_1
        sta PPU_DATA
        lda pal_spr_3_2
        sta PPU_DATA
        lda pal_spr_3_3
        sta PPU_DATA
	rts