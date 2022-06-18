

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
        jsr ant_spawn
        ldx #$d0
        jsr ant_spawn
        ldx #$c8
        ;jsr uzi_spawn
        ;jsr skully_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
        ;jsr boss_scarab_spawn
        ;jsr throber_spawn
        
        jsr sandbox2_phase_next
        
        lda #<sandbox2_phase_next
        sta starfield_msg_return_lo
        lda #>sandbox2_phase_next
        sta starfield_msg_return_hi
        
        ldx #$0
        stx state_v1
        jsr arc_sequence_set
        
	rts
        
        
        ; XXX called from starfield message scroll done
sandbox2_phase_next: subroutine
        ; enemy spawn decounter
        lda #16
        sta state_v5
        ; sequence id
        lda phase_current
        and #$0f
        ;and #$00
        sta state_v6
        tax
        jsr arc_sequence_set
        ; reset kills
        lda #$00
        sta phase_kill_count
        sta phase_state
        lda #$0f
        sta state_v4
	rts
        
        
sandbox2_update: subroutine
	lda phase_state
        bne .dont_spawn
	lda wtf
        and #$07
        bne .dont_spawn
        lda state_v5
        beq .dont_spawn
        jsr get_enemy_slot_1_sprite
        cmp #$ff
        beq .dont_spawn
        jsr galger_spawn
        lda #$00
        sta enemy_ram_ac,x
        dec state_v5
.dont_spawn

	; starglasses
        lda starglasses_count
        bne .starglasses_done
        lda timer_seconds_1s
        and #$01
        bne .starglasses_done
        lda wtf
        bne .starglasses_done
        jsr get_enemy_slot_4_sprite
        ;jsr starglasses_spawn
        inc starglasses_count
.starglasses_done
        
	jsr game_update_generic
	jsr player_move_position
        jsr player_bullets_check_controls
        
        ;lda wtf
        ;beq .do_next_state
        
        lda wtf
        cmp #$25
        bne .dont_count
        inc state_v1
        lda #$02
        cmp state_v1
        bne .dont_count
.next_arc_seq
	lda #$0
        sta wtf
        sta state_v1
        sta enemy_ram_offset
        lda #$20
        sta enemy_oam_offset
.enemy_clear_loop
        jsr enemy_death
        clc
        lda #$08
        adc enemy_ram_offset
        cmp #$80
        beq .enemy_clear_done
        sta enemy_ram_offset
        lda #$04
        clc
        adc enemy_oam_offset
        sta enemy_oam_offset
        bne .enemy_clear_loop
.enemy_clear_done
	lda #0
        sta state_v1
	inc phase_current
        inc phase_state
        jsr sandbox2_phase_next
.dont_count
        
	lda phase_kill_count
        cmp #16
        lda state_v4
        cmp #$f7
        bcc .dont_next_state
        ; XXX test line here
        ;jmp .dont_next_state
        jsr get_enemy_slot_1_count
        bne .dont_next_state
        lda phase_state
        bne .dont_next_state
.do_next_state
        inc phase_current
        inc phase_state
        ; setup msg
        ldx state_v6
        lda starfield_msg_table_lo,x
        sta starfield_msg_pos_lo
        lda starfield_msg_table_hi,x
        sta starfield_msg_pos_hi
        jsr starfield_bg2spr_init
.dont_next_state
        
        jmp state_update_done