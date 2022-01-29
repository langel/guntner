
; MODE DEFINITIONS

; #$00 = title screen
; #$01 = options
; #$02 = about
; #$10 = demo
; #$11 = game : normal playing
; #$12 = game : "phase world" display
; #$1f = game : sandbox mode




; runs at top of NMI
mode_handler_vblank: subroutine
	;lda #$10
        ;sta game_mode
	lda game_mode
        and #$10
        cmp #$10
        bne .not_game_time
	jsr starfield_update
        jsr dashboard_draw
        jmp .done
.not_game_time
	lda game_mode
        cmp #$00
        bne .not_title_screen
        jsr title_screen_handler
.not_title_screen
.done
	rts
        
        
mode_handler_post_vblank: subroutine
        lda game_mode
        cmp #$10
        bne .not_demo_time
        jsr demo_time
        jmp .done
.not_demo_time
	lda game_mode
        cmp #$11
        bne .not_game_time
        jsr game_time
.not_game_time
	lda game_mode
        cmp #$1f
        bne .not_sandbox_time
        jsr sandbox_time
.not_sandbox_time
.not_title_screen
.done
	rts
        
        
; runs after screen split
; not needed for title screen / options / etc.....
; XXX seriously need to figure out if its worth
;     turning off and back on again
mode_handler_post_split: subroutine
	lda game_mode
        and #$10
        cmp #$10
        bne .no_dashboard
        ; HUD prepare for next draw
        ; stop updating HUD if game over
        lda player_death_flag
        cmp #$00
        bne .skip_dashboard_update
	jsr dashboard_update
.skip_dashboard_update
        jsr apu_game_frame
	lda game_mode
        cmp #$10
        bne .playable_mode
.demo_mode
        jsr demo_enemy_spawn
	jsr run_player_demo
	jsr player_bullets_demo_update
	rts
.playable_mode
	jsr player_bullets_update
.no_dashboard
	rts