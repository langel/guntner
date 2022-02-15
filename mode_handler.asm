
; MODE DEFINITIONS

; #$00 = title screen
; #$01 = options
; #$02 = about ( XXX not implemented )
; #$0a = scroll to options
; #$0b = scroll to titles
; #$10 = demo
; #$11 = game : normal playing
; #$12 = game : "phase world" display
; #$1f = game : sandbox mode

; #$20 = palette fade out
; #$21 = palette fade in




; runs at top of NMI
mode_handler_vblank: subroutine
	lda game_mode
        and #$10
        cmp #$10
        bne .not_game_time
        jsr dashboard_draw
	jsr starfield_update
        jmp .done
.not_game_time
	lda game_mode
        cmp #$00
        bne .not_title_screen
        jmp title_screen_handler
.not_title_screen
	cmp #$01
        bne .not_options_screen
        jmp options_screen_handler
.not_options_screen
	cmp #$0a
        bne .not_scrollto_options
        jmp scrollto_options_handler
.not_scrollto_options
	cmp #$0b
        bne .done
        jmp scrollto_titles_handler
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
        
        jsr apu_game_frame
	jsr player_bullets_update
        ; HUD prepare for next draw
        ; stop updating HUD if game over
        lda player_death_flag
        cmp #$00
        bne .skip_stuff
	jsr dashboard_update
.skip_dashboard_update
	lda game_mode
        cmp #$10
        bne .skip_stuff
.demo_mode
        jsr demo_enemy_spawn
	jsr player_demo_controls
.skip_stuff
	rts