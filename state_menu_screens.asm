
menu_screens_init: subroutine

        jsr WaitSync	; wait for VSYNC
        jsr render_disable
	jsr sprite_clear
        jsr state_sprite0_disable
        
	lda #$01
        jsr state_render_set_addr
	lda #$01
        jsr state_update_set_addr
        lda #$00
        sta scroll_x
        sta scroll_page
        jsr timer_reset
        jsr title_screen_set_rudy_y
        
; set bg tile palette attributes / colors
; $23c0 and $27c0
        ; page 1 attributes
	PPU_SETADDR $23c0
	lda #%10101010
        ldx #$c0
.23c0_loop
        sta PPU_DATA
        inx
        bne .23c0_loop
        ; page 2 attributes
	PPU_SETADDR $27c0
	lda #%10101010
        ldx #$c0
.27c0_loop
        sta PPU_DATA
        inx
        bne .27c0_loop
        
        jsr dashboard_init
        jsr dashboard_update
        jsr dashboard_render
        
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

; set rudy color blocks' tile attributes
	PPU_SETADDR $27dc
        lda #%11111111
        sta PPU_DATA
        
; set rudy stuff
`	jsr menus_position_rudy
        jsr set_player_sprite
        
        jsr palette_fade_in_init
        jsr apu_trigger_title_screen_chord
        
; turn ppu back on
        jsr WaitSync	; wait for VSYNC
	jsr render_enable
	rts



; vBLANK RENDER HANDLER
        
menu_screens_render: 
	; pretty much just for options screen
; show song id
	PPU_SETADDR $2512
	lda #$30
        sta PPU_DATA
	lda options_song_id
	clc
        adc #$30
        sta PPU_DATA
; show sound id
	PPU_SETADDR $2552
	lda #$30
        sta PPU_DATA
	lda options_sound_id
	clc
        adc #$30
        sta PPU_DATA
        jmp state_render_done
        
        
        
        
        
; SCROLL HANDLERS

scrollto_options_update: subroutine
	lda scroll_to_counter
        clc
        adc #$04
        sta scroll_to_counter
        tax
        lda sine_table,x
        sta scroll_x
        cpx #$40
        bne .done
        ; setup options
        lda #3
        jsr state_update_set_addr
        lda #1
        sta scroll_page
        lda #$00
        sta scroll_x
        ;jmp options_screen_init
.done
	jsr menus_position_rudy
	jmp state_update_done
        
        
        
scrollto_titles_update: subroutine
	lda #$00
        sta scroll_page
	lda scroll_to_counter
        sec
        sbc #$04
        sta scroll_to_counter
        tax
        lda sine_table,x
        sta scroll_x
        cpx #$c0
        bne .done
        ; setup options
        lda #1
        jsr state_update_set_addr
        lda #$00
        sta scroll_page
        jsr timer_reset
.done
	jsr menus_position_rudy
	jmp state_update_done



menus_position_rudy: subroutine
	lda scroll_x
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
        sbc scroll_x
	jmp .plot_tiles
.coming_from_right
	jsr options_screen_set_rudy_y
	lda #$38
        sec
        sbc scroll_x
.plot_tiles
        sta oam_ram_rudy+3
        clc
        adc #$08
        sta oam_ram_rudy+7
	rts

        
title_screen_set_rudy_y: subroutine
	lda title_rudy_pos
        asl
        asl
        asl
        asl
        clc
        adc #$87
        sta player_y_hi
        jmp set_player_sprite
        
        
options_screen_set_rudy_y: subroutine
	lda options_rudy_pos
        asl
        asl
        asl
        asl
        clc
        adc #$48
        sta oam_ram_rudy
        sta oam_ram_rudy+4
        rts

        
        
        
; STRINGS AND NAMETABLES
                
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
	.byte " v2.17 "
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
  
  
  
  
  
; TITLE SCREEN UPDATES

title_screen_update: subroutine
	; set rudy x
        lda #$38
        sta player_x_hi
        
        ; number of seconds before demo
	lda timer_seconds_1s
        ; add #$30 because timer based on numerical tiles
        cmp #$33
        ;cmp #$a3
        ;cmp #$30
        bne .sit_and_wait
.start_demo
        lda #1
        jsr palette_fade_out_init
.sit_and_wait
	lda player_up_d
        ora player_down_d
        ora player_left_d
        ora player_right_d
        ora player_select_d
        cmp #$00
        beq .dont_change_pos
        inc title_rudy_pos
        lda #%00000001
        and title_rudy_pos
        sta title_rudy_pos
        jsr timer_reset
        bne .do_nothing
.dont_change_pos
	lda player_start_d
        ora player_b_d
        ora player_a_d
        cmp #$00
        beq .do_nothing
        lda title_rudy_pos
        cmp #$01
        beq .goto_options
.start_game
        ;; disable start_d so game doesn't instantly pause
        lda #$00
        sta player_start_d
        sta player_a_d
        sta player_b_d
        lda #2
        jsr palette_fade_out_init
        jsr clear_all_enemies
        jmp .do_nothing
.goto_options
	lda #2
        jsr state_update_set_addr
.do_nothing
	jsr title_screen_set_rudy_y
; except animate that color tho
        ; increase color
	inc title_screen_color
        lda title_screen_color
        lsr
        lsr
        lsr
        lsr
        lsr
        cmp #$0c
        bne .dont_reset_screen_color
        lda #$00
        sta title_screen_color
.dont_reset_screen_color
        adc #$01
        sta pal_bg_0_1
        sta pal_bg_2_1
	jmp state_update_done
        

  


  
; OPTION SCREEN UPDATES        

options_screen_update: subroutine
        
	jsr player_update_colors
	lda player_start_d
        beq .dont_start_game
        lda #$04 ; menu return pos
        cmp options_rudy_pos
        beq .dont_start_game
        lda #$00
        sta player_start_d
        jsr game_init
        lda #6
        jsr state_update_set_addr
        rts
        
.dont_start_game
	jsr options_screen_set_rudy_y
        ; XXX main NMI game loop should handle this?
	jsr apu_game_frame
; check if option changes
	lda player_down_d
        cmp #$00
        beq .dont_change_option_down
        inc options_rudy_pos
.dont_change_option_down
	lda player_up_d
        cmp #$00
        beq .dont_change_option_up
        dec options_rudy_pos
.dont_change_option_up
; check option pos is in range
	lda options_rudy_pos
        cmp #$ff ; min value - 1
        bne .dont_wrap_up
        lda #$04
.dont_wrap_up
	cmp #$05 ; max value + 1
        bne .dont_wrap_down
        lda #$00
.dont_wrap_down
	sta options_rudy_pos
; show song id
	lda options_song_id
        cmp #100
        bne .song_id_no_reset
        lda #$00
        sta options_song_id
.song_id_no_reset
; show sound id
; play music if on
; XXX NMI game loop should auto-handle this?
	lda options_music_on
        beq .no_music
        jsr apu_game_music_frame
.no_music
; which option handler?
.options_case
        lda options_rudy_pos
        cmp #$00
        beq options_screen_song_handler
        cmp #$01
	beq options_screen_sfx_handler
        cmp #$02
        bne .not_color1
        jmp options_screen_color1_handler
.not_color1
        cmp #$03
        bne .not_color2
        jmp options_screen_color2_handler
.not_color2
	cmp #$04
       	bne .not_menu_return
        jmp options_menu_return
.not_menu_return
	jmp state_update_done
        rts
        
        

        
options_screen_song_handler: subroutine
	lda player_b_d
        beq .no_b
        lda #$00
        sta options_music_on
.no_b
	lda player_a_d
        beq .no_a
        lda #$01
        sta options_music_on
.no_a
	jmp state_update_done
        
        
options_screen_sfx_handler: subroutine
        lda player_right_d
        cmp #$00
        beq .dont_up_sound
        inc options_sound_id
.dont_up_sound
	lda player_left_d
        cmp #$00
        beq .dont_down_sound
    	dec options_sound_id
.dont_down_sound
	lda options_sound_id
        cmp #$ff
        bne .sound_id_no_reset
        lda #$05
        sta options_sound_id
.sound_id_no_reset
	cmp #$06
        bne .sound_id_not_maxed
        lda #$00
        sta options_sound_id
.sound_id_not_maxed
; trigger sound with button
	lda player_a_d
        ora player_b_d
        cmp #$00
        bne .trigger_sound
	jmp state_update_done
.trigger_sound
	lda options_sound_id
        cmp #$00
        bne .not00
        jsr sfx_pewpew
.not00
 	cmp #$01
        bne .not01
        jsr sfx_player_damage
.not01
	cmp #$02
        bne .not02
        jsr sfx_player_death
.not02
	cmp #$03
        bne .not03
        jsr sfx_enemy_death
.not03
	cmp #$04
        bne .not04
        jsr sfx_battery_hit
.not04
	cmp #$05
        bne .not05
        jsr sfx_powerup_pickup
.not05
	cmp #$06
        bne .not06
        jsr sfx_player_death
.not06
	cmp #$07
        bne .not07
        jsr sfx_player_death
.not07
	jmp state_update_done
        

options_screen_color1_handler: subroutine
	; starts at 14
	lda player_right_d
        beq .dont_increase
        inc player_color0
        lda #$1d
        cmp player_color0
        bne .dont_increase
        lda #$11
        sta player_color0
.dont_increase
	lda player_left_d
        beq .dont_decrease
        dec player_color0
        lda #$10
        cmp player_color0
        bne .dont_decrease
        lda #$1c
        sta player_color0
.dont_decrease
	jmp state_update_done

options_screen_color2_handler: subroutine
	; starts at 21
	lda player_right_d
        beq .dont_increase
        inc player_color1
        lda #$2d
        cmp player_color1
        bne .dont_increase
        lda #$20
        sta player_color1
.dont_increase
	lda player_left_d
        beq .dont_decrease
        dec player_color1
        lda #$1f
        cmp player_color1
        bne .dont_decrease
        lda #$2c
        sta player_color1
.dont_decrease
	jmp state_update_done
        
        
options_menu_return: subroutine
	lda player_a_d
        ora player_b_d
        ora player_start_d
        cmp #$00
        beq .do_nothing
        lda #4
        jsr state_update_set_addr
.do_nothing
	jmp state_update_done