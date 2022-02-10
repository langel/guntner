scrollto_options_handler: subroutine
	lda scroll_to_counter
        clc
        adc #$04
        sta scroll_to_counter
        tax
        lda sine_table,x
        sta scroll_y
        cpx #$40
        bne .done
        ; setup options
        lda #$01
        sta game_mode
        sta scroll_page
        lda #$00
        sta scroll_y
        ;jmp options_screen_init
.done
	jmp menus_position_rudy
	rts
        
scrollto_titles_handler: subroutine
	lda #$00
        sta scroll_page
	lda scroll_to_counter
        sec
        sbc #$04
        sta scroll_to_counter
        tax
        lda sine_table,x
        sta scroll_y
        cpx #$c0
        bne .done
        ; setup options
        lda #$00
        sta game_mode
        sta scroll_page
        jsr timer_reset
.done
	jmp menus_position_rudy
	rts

menus_position_rudy: subroutine
	lda scroll_y
        cmp #$00
        bne .do_eeet
        rts
.do_eeet
        cmp #$48
        bcs .coming_from_right
.going_to_the_left
	jsr title_screen_set_rudy_y
	lda #$3a
	sec
        sbc scroll_y
	jmp .plot_tiles
.coming_from_right
	jsr options_screen_set_rudy_y
	lda #$38
        sec
        sbc scroll_y
.plot_tiles
        sta oam_ram_rudy+3
        clc
        adc #$08
        sta oam_ram_rudy+7
	rts


menu_screen_tile_planter:
	ldx #$00
        lda menu_screen_tile_data,x	; upper byte
.tileset_loop
        sta PPU_ADDR
        inx
        lda menu_screen_tile_data,x	; lower byte
        sta PPU_ADDR
        inx
.string_loop
        lda menu_screen_tile_data,x	; read string
        inx
        cmp #$00
        beq .terminate_string
        sta PPU_DATA
        bne .string_loop
.terminate_string
	lda menu_screen_tile_data,x	; look for ff
        cmp #$ff
        bne .tileset_loop
        rts
        
        
menu_screens_draw: subroutine

        jsr WaitSync	; wait for VSYNC
        
	; disable rendering
        lda #$00
        sta PPU_MASK	
        
; clear sprites
	jsr sprite_clear
        
        lda #$38
        sta player_x_hi
        jsr set_player_sprite
        
; G u n T n e R

; BIG TITLE
	PPU_SETADDR $2040
        ldy #$00
big_title_loop:
	lda guntner_title_name_table,y
	sta PPU_DATA
        iny
        bne big_title_loop
        ldy #$c0
big_title_loop2:
	lda guntner_title_name_table+#$40,y
        sta PPU_DATA
        iny
        bne big_title_loop2

; hud bar on title screen
	PPU_SETADDR $22c0
        lda #$1d
        ldy #$20
.set_top_bar
	sta PPU_DATA
        dey
        bne .set_top_bar
        
        jsr menu_screen_tile_planter
        
        lda #$38
        sta player_x_hi
        jsr set_player_sprite
        
        
        jsr menu_screen_tile_planter
        

; set rudy color blocks' tile attributes
	PPU_SETADDR $27dc
        lda #%11111111
        sta PPU_DATA
        
; turn ppu back on
        jsr WaitSync	; wait for VSYNC
	; enable rendering
        lda #MASK_BG|MASK_SPR
        sta PPU_MASK	
	rts
        
        
                
menu_screen_tile_data:
	.hex 2189
	.byte "G u n T n e R"
        .byte #$00
        .hex 2208
	.byte "  Please  START "
        .byte #$00
        .hex 2248
        .byte "  Much  Options "
        .byte #$00
        .hex 22d7
	.byte " v2.09 "
        .byte #$00
        .hex 2304
	.byte "(c)MMXXII puke7, LoBlast"
        .byte #$00
	.hex 2448
	.byte "Options Screeen"
        .byte #$00
        .hex 250a
	.byte "song"
        .byte #$00
        .hex 254a
	.byte "sound"
        .byte #$00
        .hex 258a
	.byte "color1  "
        .hex 1d1d
        .byte #$00
        .hex 25ca
	.byte "color2  "
        .hex 1e1e
        .byte #$00
        .hex 260a
	.byte "Menu Return"
        .byte #$00
        .byte #$ff
        
                
guntner_title_name_table:
  hex b1b1e0a0a1c5b1d2e4c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1f1d0b1b1b1b1b1b1
  hex b1b1b2b0b1b1b1b1f4f5a1a1a1a1a1a2a0a1a1a1a1a1a1f2f3b1d2c1c1e2b1b1
  hex b1b1b2b0b1b1d2d0b1d5d2a0a1c5b1b2b0b1d2a0a1c5d2a0a1c5b2a0a1a3b1b1
  hex b1b1b2b0b1b1b2b0b1b3b2b0b1b3b1b2b0b1b2b0b1b3b1b0b1b1b2b0b1b3b1b1
  hex b1b1b2b0b1b1b2b0b1b3b2b0b1b3b1b2b0b1b2b0b1b3b1b0b1b1b2b0b1b3b1b1
  hex b1b1b2b0b1d5b2b0b1b3b2b0b1b3b1b2b0b1b2b0b1b3b1d0c5b1b2d0c1e3b1b1
  hex b1b1b2b0b1b3b2b0b1b3b2b0b1b3b1b2b0b1b2b0b1b3b1b0b1b1b2b0b1b2b1b1
  hex b1b1b2b0b1b3d2d0d1d4d2d0b5d5b5b2b0b1d2d0b5d5d2d0d1d5b2b0b1b2b1b1
  hex b1b1b2b0b1b3b1b1b1b1b1b1b1b1d2a0a2d0b1b1b1b1b1b1b1b1d2d0b5b2b1b1
  hex b1b1b2c0c1c2b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b2b1b1
  hex b1b1e1a1a1c5b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1d4b1b1

