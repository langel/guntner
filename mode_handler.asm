
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
	cmp #$01
        bne .done
        jsr options_screen_handler
.done
	rts
        
        
mode_handler_post_vblank: subroutine
	; if game_mode < #$10 get outtta here
        lda game_mode
        cmp #$10
        bcs .game_logic
        rts
.game_logic
        lda game_mode
        cmp #$10
        bne .not_demo_time
        jsr demo_time
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
	; wait for Sprite 0; SPRITE 0 WAIT TIME!!!
.wait0	bit PPU_STATUS
        bvs .wait0
        lda #$c0
.wait1	bit PPU_STATUS
        beq .wait1
	; HUD POSITIONING
        bit PPU_STATUS
        lda #$00
        sta PPU_SCROLL
        sta PPU_SCROLL
	; set bg pos to page 2
	lda #$01
        ora #CTRL_NMI|CTRL_BG_1000
        sta PPU_CTRL
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
	; XXX if we remove sprite 0 from title/options
        ; XXX sfx by frame will not work here
        jsr apu_game_frame
	lda game_mode
        cmp #$10
        bne .playable_mode
.demo_mode
        jsr demo_enemy_spawn
	jsr player_demo_controls
	jsr player_bullets_demo_update
	rts
.playable_mode
	jsr player_bullets_update
.no_dashboard
	rts