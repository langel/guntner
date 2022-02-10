

        

     
options_screen_init: subroutine
	lda #$01
        sta game_mode
	lda #$00
        sta options_song_id	
        sta options_sound_id
        sta options_rudy_pos
        sta scroll_y
        sta scroll_page
        jsr WaitSync	
        
        jsr scroll_pos_reset
        lda #$38
        sta player_x_hi
        jsr set_player_sprite
        
; reset music?
	lda #$00
        sta options_music_on
        jsr apu_game_music_init
        
        lda #$01
        sta scroll_page
	rts

        
        
        
        
        
        
options_screen_handler: subroutine
        
	jsr player_update_colors
	lda player_start_d
        beq .dont_start_game
        lda #$04 ; menu return pos
        cmp options_rudy_pos
        beq .dont_start_game
        lda #$00
        sta player_start_d
        lda #$11
        sta game_mode
        jsr game_init
        rts
.dont_start_game
	jsr options_screen_set_rudy_y
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
	PPU_SETADDR $2512
        ;inc options_song_id	
	lda options_song_id
        cmp #100
        bne .song_id_no_reset
        lda #$00
        sta options_song_id
.song_id_no_reset
        asl
        tax
        lda decimal_table,x
        sta PPU_DATA
        inx
        lda decimal_table,x
        sta PPU_DATA
; show sound id
	PPU_SETADDR $2552
        lda options_sound_id
        asl
        tax
        lda decimal_table,x
        sta PPU_DATA
        inx
        lda decimal_table,x
        sta PPU_DATA
; play music if on
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
        rts
        
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
	rts
        
        
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
        rts
.trigger_sound
	lda options_sound_id
        cmp #$00
        bne .not00
        jmp sfx_pewpew
.not00
 	cmp #$01
        bne .not01
        jmp sfx_player_damage
.not01
	cmp #$02
        bne .not02
        jmp sfx_player_death
.not02
	cmp #$03
        bne .not03
        jmp sfx_enemy_death
.not03
	cmp #$04
        bne .not04
        jmp sfx_battery_hit
.not04
	cmp #$05
        bne .not05
        jmp sfx_powerup_pickup
.not05
	cmp #$06
        bne .not06
        jmp sfx_player_death
.not06
	cmp #$07
        bne .not07
        jmp sfx_player_death
.not07
	rts
        

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
	rts

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
	rts
        
        
options_menu_return: subroutine
	lda player_a_d
        ora player_b_d
        ora player_start_d
        cmp #$00
        beq .do_nothing
	lda #$0b
        sta game_mode
.do_nothing
	rts