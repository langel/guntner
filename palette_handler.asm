
palette_cache	EQU $0140


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