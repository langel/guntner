
palette_cache	EQU $e7


;Palette00:		; 25 bytes

;	hex 0f		;screen color
;	hex 022830	;background 0
;        hex 071624	;background 1
;        hex 02113c	;background 2
;        hex 0b1a3b	;background 3
;        hex 192939	;sprite 0 ; rudy
;        hex 132130	;sprite 1; old birb palete
;       ;hex 051637	; chomps
        ;hex 122130	; vamp eyes & bats
        ;hex 071727	;sprite 2
;        hex 150037	; vamp head/face
;        hex 013530	;sprite 3 ; starglasses ; crossbones
        
        
; bg 0 - stars bg_tiles 1 / menu screens
; bg 1 - stars bg_tiles 2
; bg 2 - n/a  (bg enemies)
; bg 3 - dashboard
; spr 0 - player
; spr 1 - enemy
; spr 2 - enemy / stars sprites 1
; spr 3 - enemy / stars sprite 2


; level palettes
;	spr 1, 2 and 3
; boss palettes
;	spr 1 and 2


palette_table:
	; #00 end bad
	byte #$0f, #$30, #$27
	; #03 end ok
	byte #$0f, #$10, #$30
	; #06 end good
	byte #$1d, #$37, #$27
	; #09 end alien
        ; XXX final colors not picked yet
	;byte #$0d, #$3c, #$24
        byte #$3c, #$1c, #$24
	; #12 intro bg
	byte #$0c, #$30, #$3c
	; #15 intro alien
        byte #$04, #$1b, #$37
        ; #18 title screen
        byte #$02, #$27, #$34
        ; #21 level 0 palettes
        hex 13 21 30
        hex 07 17 27
        hex 01 35 30
        ; #30 level 1 palettes
        ; #39 level 2 palettes
        ; #48 level 3 palettes
        ; #57 boss 0 palettes
        ; #63 boss 1 palettes
        ; #69 boss 2 palettes
        ; #72 boss 3 palettes
        
palette_level_offset_table:
	byte #21, #30, #39, #48
palette_boss_offset_table:
	byte #57, #63, #69, #72
        
palette_load:
	; x = pal rom offset 
        ; y = pal ram offset
        ; not used to write to main bg color
        lda #$02
        sta temp00
.loader_loop
	lda palette_table,x
        sta pal_uni_bg+1,y
        inx
        iny
	dec temp00
        bpl .loader_loop
        rts
        
palette_level_load:
	ldy phase_level
        ldx palette_level_offset_table,y
	ldy #15
        jsr palette_load
        jsr palette_load
        jsr palette_load
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
     
bomb_bg_animation_table: 
	.byte $0f,$07,$06,$05,$16,$26,$27,$28,$37,$38,$30
     
palette_update: subroutine
; shroom
	lda shroom_counter
        beq .no_shroom_effect
        lda wtf
        and #$03
        bne .no_shroom_effect
        ldy #$0e
.shroom_loop
	lda pal_bg_3_1,y
        jsr palette_next_rainbow_color
        sta pal_bg_3_1,y
        dey
        bpl .shroom_loop
        
.no_shroom_effect
; fade in
        lda state_fade_in
        beq .dont_fade_in
        jmp palette_fade_in_update
.dont_fade_in
; fade out
	cmp state_fade_out
        beq .dont_fade_out
        jmp palette_fade_out_update
.dont_fade_out
; bomb
        lda bomb_counter
        beq .normal_bg
        lsr
        lsr
        tax
        lda bomb_bg_animation_table,x
        sta pal_uni_bg
.normal_bg
	; do normal
        ldy #25
.loop
        lda pal_uni_bg,y
        sta palette_cache,y
        dey
        bpl .loop
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
	ldx #25
.loop
	lda pal_uni_bg,x
        sec
        sbc pal_fade_offset
        bcs .no_reset
        lda #$0f
.no_reset
	sta palette_cache,x
        dex
        bpl .loop
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