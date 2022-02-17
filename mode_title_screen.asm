
      
        
        
title_screen_init: subroutine
	jsr menu_screens_draw
	lda #$00
        sta pal_fade_target
        sta game_mode
        sta scroll_x
        sta scroll_page
        sta title_screen_chord_played
        jsr timer_reset
        jsr title_screen_handler
        jmp palette_fade_in_init
	rts
        
        


title_screen_handler: subroutine
	;jsr apu_game_music_frame
	lda title_screen_chord_played
        cmp #$00
        bne .chord_played
	inc title_screen_chord_played
        jsr apu_trigger_title_screen_chord
.chord_played
	lda timer_seconds_1s
        ; number of seconds before demo
        ; add #$30 because timer based on numerical tiles
        cmp #$33
        ;cmp #$a3
        ;cmp #$30
        bne .sit_and_wait
.start_demo
        lda #$10
        sta pal_fade_target
        jmp palette_fade_out_init
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
        lda #$11
        sta game_mode
        jsr game_init
        jsr clear_all_enemies
        jmp .do_nothing
.goto_options
	lda #$0a
        sta game_mode
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
        tay
	PPU_SETADDR $3f01
        tya
        sta PPU_DATA
	PPU_SETADDR $3f09
        tya
        sta PPU_DATA
	rts
        
title_screen_set_rudy_y: subroutine
	lda title_rudy_pos
        asl
        asl
        asl
        asl
        clc
        adc #$87
        sta oam_ram_rudy
        sta oam_ram_rudy+4
        rts
  
        
        
