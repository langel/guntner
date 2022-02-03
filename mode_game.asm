


game_time: subroutine
	; read user controls even in demo mode!
	jsr player_change_speed
        
        jsr player_pause
        ; test for paused
        lda player_paused
        cmp #$ff
        bne .player_check_for_dead
        jmp .done_and_paused
        
.player_check_for_dead
	; MOCKUP DEATH SEQUENCE
        lda player_health
        cmp #$00
        bne .player_not_dead
.player_dead
	jmp .player_dead_anim
        
.player_not_dead
	jsr apu_game_music_frame
	lda player_health
        cmp #$ff
        beq .no_heal
        inc player_heal_c
        inc player_heal_c
        inc player_heal_c
        lda player_heal_c
        cmp #$40
        bne .no_heal
        lda #$00
        sta player_heal_c
        inc player_health
.no_heal
	jsr player_move_position
        jsr player_bullets_check_controls
        ; spawn enemies
; PHASE HANDLER
        jsr phase_handler
.dont_shoot
        jsr set_player_sprite
        lda #$04
        sta player_damage
        
;; XXX FORCE QUICK DEATH
        ;jsr player_take_damage
        
        jmp .done
        
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
	cmp #120
        bne .still_dead
; next life      
        lda player_lives
        cmp #$00
        bne .next_life
        ; no lives left game over
        ; GO BACK TO TITLE SCREEN AFTER DEATH SEQUENCE
        jmp title_screen_init
        
.next_life
	; set star speed
        lda #$07
        sta scroll_speed
        asl
        asl
        asl
        sta scroll_speed_m
        ; reset health
	lda #$ff
        sta player_health
        ; reset death sequence timers
        lda #$00
        sta player_death_flag
        sta you_dead_counter
        ; reset player sprites
        ldx #$8f ; set tiles
        stx $205
        dex 
        stx $209
.still_dead
.done
        jsr update_enemies
.done_and_paused
	rts