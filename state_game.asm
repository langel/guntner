

game_init_generic: subroutine

	jsr render_disable
        jsr nametables_clear
        
        lda #scroll_speed_lo_default
        sta scroll_speed_lo
        lda #scroll_speed_hi_default
        sta scroll_speed_hi
        
        lda #2
        jsr state_render_set_addr
        
        jsr timer_reset
	jsr player_game_reset
        jsr dashboard_init
        jsr starfield_init
        jsr starfield_twinkle_reset
 	jsr starfield_draw_dash_top_bar_nametable0
        lda #$ff
        sta dashboard_message
        jsr dashboard_update
        jsr dashboard_render
        
        jsr state_sprite0_enable
        rts
        
        

game_init:
	jsr game_init_generic
        lda #6
        jsr state_update_set_addr
        lda #$00
        sta attract_true
        jsr clear_all_enemies
        jsr render_enable
        jsr palette_fade_in_init
        lda #iframe_game_length
        sta state_iframe_length
        lda #2
        jsr song_start
        lda state_v1
        beq .no_super_secret_code
	lda #$20
        sta player_lives
.no_super_secret_code
        rts



game_update_generic: subroutine
	lda player_health
        bne .player_not_dead
.player_dead_anim
        lda player_death_flag
        bne .death_already_set
        inc player_death_flag
        jsr song_stop
        lda scroll_speed_hi
        sta scroll_cache_hi
        lda scroll_speed_lo
        sta scroll_cache_lo
        dec player_lives
        bne .youdead
        ; attract mode has different behaviour
        lda attract_true
        cmp #$ff
        beq .youdead
        ; set to grayscale
	lda #%00000001
        sta ppu_mask_emph
        ; cinematics
        sta scroll_speed_hi
        lda #song_game_over
        jsr song_start
        lda #121
        sta you_dead_counter
        ; "GAME OVER"
        ldy #$10
        jsr dashboard_message_set
        jmp .done
.youdead
        jsr sfx_player_death
        ; "YOU DEAD"
        ldy #$00
        jsr dashboard_message_set
        jmp .done
.death_already_set
        jsr death_scroll_speed
	inc you_dead_counter
        lda you_dead_counter
        cmp #80
        beq .trigger_fadeout
	cmp #120
        bne .done
; next life      
        lda player_lives
        bne .next_life
        ; no lives left game over
        ; GO BACK TO TITLE SCREEN AFTER DEATH SEQUENCE
        beq .done
.trigger_fadeout
        ; demo mode has different behaviour
        lda attract_true
        cmp #$ff
        beq .return_to_title_screen
     	; do not return to title if game is not over
        lda player_lives
        bne .done
.return_to_title_screen
        ; GO BACK TO TITLE SCREEN 
        ; AFTER DEATH SEQUENCE
	lda #0
	jsr palette_fade_out_init
        jmp .done
.next_life
	jsr song_unstop
        ; reset health
	lda #$ff
        sta player_health
        ; turn on iframes
        lda #120
        sta state_iframes
        ; reset death sequence timers
        lda #$00
        sta player_death_flag
        sta you_dead_counter
        ; revert scroll speed
        lda scroll_cache_hi
        sta scroll_speed_hi
        lda scroll_cache_lo
        sta scroll_speed_lo

.player_not_dead

.healing_with_time
	lda player_health
        cmp #$ff
        beq .no_heal
        lda player_heal_c
        clc
        adc #$23 ; speed of heal counter increment
        sta player_heal_c
        bcc .no_heal
.reset_heal_counter
        inc player_health
.no_heal

player_change_speed:
	lda player_select_d
        cmp #$00
        beq .read_select_done
        ; update speed
        inc player_speed
        lda player_speed
        cmp #$04
        bne .read_select_done
        lda #$00
        sta player_speed
.read_select_done
        
        
.done
	jsr player_collision_update
        jsr enemies_update_all
        jsr set_player_sprite
	rts
      
      
      
        
        
game_update: subroutine
	; check for (un)pausings
	lda phase_end_game
        cmp #$01
        beq .read_start_done
	lda player_start_d
        cmp #$00
        beq .read_start_done
        lda player_paused
        cmp #$00
        beq .pause
.unpause
	lda #$00
        sta player_paused
        lda #$ff
        sta dashboard_message
        jsr song_unstop
        jmp .read_start_done
.pause
	lda #$ff
        sta player_paused
        lda #$30
        sta dashboard_message
        jsr song_stop
        jsr sfx_rng_chord
.read_start_done
        ; test for paused
        lda player_paused
        bne .done_and_paused
        
        jsr phase_handler
        jsr game_update_generic
        
	lda player_health
        cmp #$00
        beq .done_and_paused
		
	jsr player_move_position
        jsr player_bullets_check_controls
.done_and_paused
        jmp state_update_done
        
