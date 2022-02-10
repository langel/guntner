guntner_msg:
	.byte "G u n T n e R"
        .byte #$00
        
PleaseStart_msg:
	.byte "  Please  START "
        .byte #$00
        
MuchOptions_msg:
	.byte "  Much  Options "
        .byte #$00
        
copyright:
	.byte "(c)MMXXII puke7, LoBlast"
        .byte #$00
        
version:
	.byte " v2.09 "
        .byte #$00
        
guntner_title_name_table:
  hex b1b1e0a0a1c5b1d2e4c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1f1d0b1b1b1b1b1b1
  hex b1b1b2b0b1b1b1b1f4f5a1a1a1a1a1a2a0a1a1a1a1a1a1f2f3b1d2c1c1e2b1b1
  hex b1b1b2b0b1b1d2d0b1d5d2a0a1c5b1b2b0b1d2a0a1c5d2a0a1c5b2a0a1a3b1b1
  hex b1b1b2b0b1b1b2b0b1b3b2b0b1b3b1b2b0b1b2b0b1b3b1b0b1b1b2b0b1b3b1b1
  hex b1b1b2b0b1b1b2b0b1b3b2b0b1b3b1b2b0b1b2b0b1b3b1b0b1b1b2b0b1b3b1b1
  hex b1b1b2b0b1d5b2b0b1b3b2b0b1b3b1b2b0b1b2b0b1b3b1d0c5b1b2d0c1e3b1b1
  hex b1b1b2b0b1b3b2b0b1b3b2b0b1b3b1b2b0b1b2b0b1b3b1b0b1b1b2b0b1b2b1b1
  hex b1b1b2b0b1b3d2d0d1d4d2d0b5d5b5b2b0b1d2d0b5d5d2d0d1d5b2b0b1b2b1b1
  hex b1b1b2b0b1b3b1b1b1b1b1b1b1b1d2a0a2d0b1b1b1b1b1b1b1b1d2d0b5b2b1b1
  hex b1b1b2c0c1c2b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b2b1b1
  hex b1b1e1a1a1c5b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1d4b1b1



title_screen_handler: subroutine
	;jsr apu_game_music_frame
	lda title_screen_chord_played
        cmp #$00
        bne .chord_played
	inc title_screen_chord_played
        jsr apu_trigger_title_screen_chord
.chord_played
	lda timer_seconds_1s
        ; number of seconds before demo
        cmp #$03
        ;cmp #$a3
        bne .sit_and_wait
.start_demo
        lda #$10
        sta game_mode
        jsr game_init
.sit_and_wait
	lda player_up_d
        ora player_down_d
        ora player_left_d
        ora player_right_d
        ora player_select_d
        cmp #$00
        beq .dont_change_pos
        inc title_rudy_pos
        lda #%00000001
        and title_rudy_pos
        sta title_rudy_pos
        jsr timer_reset
        bne .do_nothing
.dont_change_pos
	lda player_start_d
        ora player_b_d
        ora player_a_d
        cmp #$00
        beq .do_nothing
        lda title_rudy_pos
        cmp #$01
        beq .goto_options
.start_game
        ;; disable start_d so game doesn't instantly pause
        lda #$00
        sta player_start_d
        lda #$11
        sta game_mode
        jsr game_init
        jsr clear_all_enemies
        jmp .do_nothing
.goto_options
	lda #$01
        sta game_mode
        jsr options_screen_init
.do_nothing
	lda title_rudy_pos
        asl
        asl
        asl
        asl
        clc
        adc #$87
        sta player_y_hi
	jsr set_player_sprite
; except animate that color tho
        ; increase color
	inc title_screen_color
        lda title_screen_color
        lsr
        lsr
        lsr
        lsr
        lsr
        cmp #$0c
        bne .dont_reset_screen_color
        lda #$00
        sta title_screen_color
.dont_reset_screen_color
        adc #$01
        tay
	PPU_SETADDR $3f01
        tya
        sta PPU_DATA
	PPU_SETADDR $3f09
        tya
        sta PPU_DATA
	rts
        
        
        
        
title_screen_init: subroutine
	lda #$00
        sta game_mode
        sta scroll_y
        sta scroll_page
        sta title_screen_chord_played
        jsr WaitSync	; wait for VSYNC
        
	; disable rendering
        lda #$00
        sta PPU_MASK	
; clear sprites
	jsr sprite_clear
        
        jsr scroll_pos_reset
        lda #$38
        sta player_x_hi
        jsr set_player_sprite
        
; G u n T n e R

; BIG TITLE
	PPU_SETADDR $2040
        ldy #$00
big_title_loop:
	lda guntner_title_name_table,y
	sta PPU_DATA
        iny
        bne big_title_loop
        ldy #$c0
big_title_loop2:
	lda guntner_title_name_table+#$40,y
        sta PPU_DATA
        iny
        bne big_title_loop2


; little title
	PPU_SETADDR $2189
	ldy #$00		; set Y counter to 0
.title_loop4:
	lda guntner_msg,y	; get next character
        beq .enda4	; is 0? exit loop
	sta PPU_DATA	; store+advance PPU
        iny		; next character
	bne .title_loop4	; loop
.enda4


; copyright
	PPU_SETADDR $2304
	ldy #$00		; set Y counter to 0
copyright_loop:
	lda copyright,y	; get next character
        beq .copyright_end	; is 0? exit loop
	sta PPU_DATA	; store+advance PPU
        iny		; next character
	bne copyright_loop	; loop
.copyright_end




; please start
	PPU_SETADDR $2208
	ldy #$0		; set Y counter to 0
.please_start_loop:
	lda PleaseStart_msg,y	; get next character
        beq .end	; is 0? exit loop
	sta PPU_DATA	; store+advance PPU
        iny		; next character
	bne .please_start_loop	; loop
.end

; much options
	PPU_SETADDR $2248
	ldy #$0		; set Y counter to 0
.much_options_loop:
	lda MuchOptions_msg,y	; get next character
        beq .options_end	; is 0? exit loop
	sta PPU_DATA	; store+advance PPU
        iny		; next character
	bne .much_options_loop	; loop
.options_end


; hud bar on title screen
	PPU_SETADDR $22c0
        lda #$1d
        ldy #$20
.set_top_bar
	sta PPU_DATA
        dey
        bne .set_top_bar
        
; version
	PPU_SETADDR $22d7
version_loop:
	lda version,y	; get next character
        beq .version_end	; is 0? exit loop
	sta PPU_DATA	; store+advance PPU
        iny		; next character
	bne version_loop	; loop
.version_end
        
        
	; enable rendering
        lda #MASK_BG|MASK_SPR
        sta PPU_MASK	
        
        jsr WaitSync	; wait for VSYNC
        
        jsr timer_reset
	rts
        
        
