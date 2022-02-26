

sandbox2_init: subroutine
        ;jsr game_init
        jsr game_init_generic
  ; SCROLL SPEED
  	;lda #$27
        lda #$03
        sta scroll_speed
        
        
        jsr starfield_bg_init
        lda #200
        sta scroll_x
        jsr starfield_bg2psr_init
        ;jsr starfield_spr_init
        ;jsr nametables_clear
        jsr dashboard_init
        
        ;lda #2
        ;jsr state_render_set_addr
        lda #9
        jsr state_update_set_addr
        
        jsr render_enable
        
        ;jsr get_enemy_slot_1_sprite
        ;jsr galger_spawn
        ;jsr get_enemy_slot_1_sprite
        ;jsr galger2_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
	;jsr boss_vamp_spawn
        
	rts
        
        
        
sandbox2_update: subroutine


	lda wtf
        and #$07
        cmp #$0
        bne .dont_spawn
        jsr get_enemy_slot_1_sprite
        cmp #$ff
        beq .dont_spawn
        ;jsr galger_spawn
.dont_spawn

	jsr game_update_generic
	jsr player_move_position
        jsr player_bullets_check_controls
        
        jmp state_update_done