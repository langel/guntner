

sandbox2_init: subroutine

  ; SCROLL SPEED
  	;lda #$27
        lda #$03
        sta scroll_speed_cache
        
        jsr game_init_generic
        jsr starfield_bg_init
        jsr dashboard_init
        
        lda #9
        jsr state_update_set_addr
        
        jsr render_enable
        
	jsr get_enemy_slot_4_sprite
        tax
	;jsr boss_vamp_spawn
        ldx #$d0
        ;jsr ant_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
        ldx #$d8
       ; jsr ant_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
        ;jsr throber_spawn
        
        jsr sandbox2_phase_next
        
	rts
        
        
        ; XXX called from starfield message scroll done
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
        bne .dont_spawn
	lda wtf
        and #$07
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
        ; XXX test line here
        ;jmp .dont_next_state
        jsr get_enemy_slot_1_count
        bne .dont_next_state
        lda phase_state
        bne .dont_next_state
        inc phase_current
        inc phase_state
        jsr starfield_bg2spr_init
.dont_next_state
        
        jmp state_update_done