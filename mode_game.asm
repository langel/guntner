

game_init_generic: subroutine

	jsr render_disable
        
        lda #2
        jsr state_render_set_addr
        
        ;jsr starfield_bg_init
        
        ; draw dashbar top bar on title screen page
	PPU_SETADDR $22c0
        lda #$04
        ldy #$24
.set_top_bar
	sta PPU_DATA
        dey
        bne .set_top_bar
        
        jsr timer_reset
	jsr player_game_reset
        jsr dashboard_init
        jsr dashboard_update
        jsr dashboard_render
        
        jsr state_sprite0_enable
        rts
        
        

game_init:
	jsr game_init_generic
        lda #6
        jsr state_update_set_addr
        lda #$00
        sta demo_true
        jsr starfield_bg_init
        jsr render_enable
        jsr palette_fade_in_init
        rts



game_update_generic: subroutine
	lda player_health
        cmp #$00
        bne .player_not_dead
        
.player_dead_anim
        jsr death_scroll_speed
        lda player_death_flag
        cmp #$00
        bne .death_already_set
        lda #$01
        sta player_death_flag
        jsr sfx_player_death
        dec player_lives
        lda player_lives
        cmp #$00
        bne .youdead
        ; demo mode has different behaviour
        lda demo_true
        cmp #$ff
        beq .youdead
        ; "GAME OVER"
        ldy #$10
        jsr dashboard_message_set
        jmp .done
.youdead
        ; "YOU DEAD"
        ldy #$00
        jsr dashboard_message_set
        jmp .done
.death_already_set
	inc you_dead_counter
        lda you_dead_counter
        cmp #80
        beq .trigger_fadeout
	cmp #120
        bne .done
; next life      
        lda player_lives
        cmp #$00
        bne .next_life
        ; no lives left game over
        ; GO BACK TO TITLE SCREEN AFTER DEATH SEQUENCE
        jmp .done
.trigger_fadeout
        lda player_lives
        cmp #$00
        bne .done
        ; GO BACK TO TITLE SCREEN 
        ; AFTER DEATH SEQUENCE
	lda #0
	jsr palette_fade_out_init
        jmp .done
.next_life
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

	; XXX maybe move this functions contents to here
        ; seems like speed gets reset when it shouldn't
	jsr player_change_speed
        ; XXX is this default damage from enemies?
        ; XXX actually seems like a testing mechanic
        lda #$04
        sta player_damage
;; XXX FORCE QUICK DEATH
        ;jsr player_take_damage
.done
        jsr update_enemies
        jsr set_player_sprite
	rts
        
        
game_update:
	jsr player_pause
        ; test for paused
        lda player_paused
        cmp #$ff
        ;bne .player_check_for_dead
        beq .done_and_paused
        jsr phase_handler
        jsr game_update_generic
        
	lda player_health
        cmp #$00
        beq .done_and_paused
		
	jsr player_move_position
        jsr player_bullets_check_controls
.done_and_paused
        jmp state_update_done
        
