

sandbox2_init: subroutine
        ;jsr game_init
        jsr game_init_generic
  ; SCROLL SPEED
  	;lda #$27
        lda #$07
        sta scroll_speed
        
        jsr starfield_bg_init
        ;jsr nametables_clear
        jsr dashboard_init
        
        lda #2
        jsr state_render_set_addr
        lda #9
        jsr state_update_set_addr
        
        jsr render_enable
        
	rts
        
        
        
sandbox2_update: subroutine
	jsr game_update_generic
	jsr player_move_position
        jsr player_bullets_check_controls
        
        jmp state_update_done