

sandbox2_init: subroutine
        ;jsr game_init
        jsr game_init_generic
  ; SCROLL SPEED
  	;lda #$27
        lda #$03
        sta scroll_speed
        
        jsr starfield_bg_init
        jsr dashboard_init
        
        lda #9
        jsr state_update_set_addr
        
        jsr render_enable
        
	jsr get_enemy_slot_4_sprite
        tax
	;jsr boss_vamp_spawn
        
        jsr sandbox2_phase_next
        
	rts
        
        
sandbox2_phase_next: subroutine
        ; enemy spawn decounter
        lda #16
        sta state_v5
        lda #0
        sta phase_kill_count
        sta phase_state
	rts
        
        
sandbox2_update: subroutine
	lda phase_state
        cmp #0
        bne .dont_spawn
	lda wtf
        and #$07
        cmp #$0
        bne .dont_spawn
        lda state_v5
        cmp #0
        beq .dont_spawn
        jsr get_enemy_slot_1_sprite
        cmp #$ff
        beq .dont_spawn
        jsr galger_spawn
        dec state_v5
.dont_spawn
        
	jsr game_update_generic
	jsr player_move_position
        jsr player_bullets_check_controls
        
	lda phase_kill_count
        cmp #16
        bne .dont_next_state
        lda phase_state
        cmp #0
        bne .dont_next_state
        inc phase_current
        inc phase_state
        jsr starfield_bg2spr_init
.dont_next_state
        
        jmp state_update_done