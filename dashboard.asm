;;; constants

speed_addr		= $2706
life_bar_addr		= $2708
lives_addr		= $271d
phase_addr		= $2748
score_addr		= $274c
timer_addr		= $2756
tile_empty		= $05


dashboard_init: subroutine
        ; set hud y pos
        lda #182
        sta sprite_0_y
        
        ; COLOR SPLIT
        ; set split color attr for top row
	PPU_SETADDR $27e8
	lda #%11110001
        ldx #$f8
.27e8_loop
        sta PPU_DATA
        inx
        bne .27e8_loop
        
        ; COLOR FULL
        ; set full color attr for the rest
	PPU_SETADDR $27f0
	lda #%11111111
        ldx #$f0
.23f0_loop
        sta PPU_DATA
        inx
        bne .23f0_loop
        
        ; fill page 1 bar for sprite 0 collisions
	PPU_SETADDR $22c0
        lda #$04
        ldy #$20
.tile_dash_set_page1
        sta PPU_DATA
        dey
        bne .tile_dash_set_page1
        
        ; fill page 2 dashboard top row
	PPU_SETADDR $26c0
        lda #$04
        ldy #$20
.set_top_bar
	sta PPU_DATA
        dey
        bne .set_top_bar
        
	; fill page 2 dashboard tiles
        lda #$1d
        ldx #$00
.dashboard_fill_tiles
	lda dashboard_bg_tiles,x
        sta PPU_DATA
        inx
        bne .dashboard_fill_tiles
	rts
        
        
dashboard_bg_tiles:
	; top row 0
	hex 1da0a1a1a1a1a1a3
        hex a1a1a1a1a1a1a1a1
        hex a1a1a1a1a1a1a1a1
        hex a3a1a1a1a1a1a21d
        ; health row 1
	hex 1db0a5a6a7a8b1b3
	hex b1b1b1b1b1b1b1b1
        hex b1b1b1b1b1b1b1b1
        hex b310117830b1b21d
        ; middle row 2
	hex 1dd0d1d1d1d1d1c3
        hex d1d1a4d3d1d1d1d1
        hex d1d1d1d1a4d3d1d1
        hex c3d1d1d1d1d1d21d
        ; score row 3
	hex 1db05048415345b1
	hex b1b1b2b0b1b1b1b1
	hex b1b1b1b2b2b0b1b1
	hex b1b1b1b1b1b1b21d
	; bottom 4
	hex 1d1d1d1d1d1d1d1d
	hex 1d1d1d1d1d1d1d1d
	hex 1d1d1d1d1d1d1d1d
	hex 1d1d1d1d1d1d1d1d


; DASHBOARD messages
DASHBOARD_MESSAGES:
	byte " Y 0 u  D 3 A D " ; y = #$00
	byte " G A M E O V Er " ; y = #$10
	byte "gg ConGraTiON gg" ; y = #$20
	byte " please unpause " ; y = #$30
        
        
        
dashboard_message_set: subroutine
; set y for message start offset
	ldx #$00
.loop
        lda DASHBOARD_MESSAGES,y
        sta lifebar0,x
        iny
        inx
        cpx #$10
        bne .loop
        rts
        



; RENDER DASH STATS TO SCREEN
dashboard_draw: subroutine

.speed
	PPU_SETADDR speed_addr
        lda player_speed
        clc
        adc #$31
        sta PPU_DATA
        
.lives
	PPU_SETADDR lives_addr
        lda player_lives
        clc
        adc #$30
        sta PPU_DATA
        
.phase
	PPU_SETADDR phase_addr
        lda phase_current
        clc
        adc #$01
        asl
        tax
        lda decimal_table,x
        sta PPU_DATA
        inx
        lda decimal_table,x
        sta PPU_DATA

.lifebarf
	PPU_SETADDR life_bar_addr
        lda lifebar0
        sta PPU_DATA
        lda lifebar1
        sta PPU_DATA
        lda lifebar2
        sta PPU_DATA
        lda lifebar3
        sta PPU_DATA
        lda lifebar4
        sta PPU_DATA
        lda lifebar5
        sta PPU_DATA
        lda lifebar6
        sta PPU_DATA
        lda lifebar7
        sta PPU_DATA
        lda lifebar8
        sta PPU_DATA
        lda lifebar9
        sta PPU_DATA
        lda lifebara
        sta PPU_DATA
        lda lifebarb
        sta PPU_DATA
        lda lifebarc
        sta PPU_DATA
        lda lifebard
        sta PPU_DATA
        lda lifebare
        sta PPU_DATA
        lda lifebarf
        sta PPU_DATA

.timer 
	; make sure player has lives / not game over
	lda player_lives
        cmp #$00
        beq .timer_done
        ; make sure player hasn't finished the game
	lda phase_end_game
        cmp #$01
        beq .timer_done
; we good to update the visual timer
        PPU_SETADDR timer_addr
        lda timer_minutes_10s
        clc 
        adc #$30
        sta PPU_DATA
        lda timer_minutes_1s
        clc 
        adc #$30
        sta PPU_DATA
        lda #$3a
        sta PPU_DATA
        lda timer_seconds_10s
        clc 
        adc #$30
        sta PPU_DATA
        lda timer_seconds_1s
        clc 
        adc #$30
        sta PPU_DATA
        lda #$2e
        sta PPU_DATA
        lda timer_frames_10s
        clc 
        adc #$30
        sta PPU_DATA
        lda timer_frames_1s
        clc 
        adc #$30
        sta PPU_DATA
.timer_done

.score
	PPU_SETADDR score_addr
        lda #$30
        ;sta PPU_DATA
        lda score_10000000
        sta PPU_DATA
        lda score_1000000
        sta PPU_DATA
        lda score_100000
        sta PPU_DATA
        lda score_10000
        sta PPU_DATA
        lda score_1000
        sta PPU_DATA
        lda score_100
        sta PPU_DATA
        lda score_10
        sta PPU_DATA
        lda score_00000001
        sta PPU_DATA
        
	rts
        
        
        
; GET DASH UPDATES READY TO RENDER
dashboard_update: subroutine


; LIFEBARF
	; check if end game
	lda phase_end_game
        cmp #$00
        beq .lifebarf_not_end_game
        ; "gg congration gg"
        ldy #$20
        jsr dashboard_message_set
        jmp .super_done
.lifebarf_not_end_game
	; if paused then just say P A U S E D
        ; wait maybe it says PLEASE UNPAUSE
        lda player_paused
        cmp #$ff
        beq .lifebarf_not_live
        jmp .lifebarf_is_live
.lifebarf_not_live
        ; "please unpause"
        ldy #$30
        jsr dashboard_message_set
        jmp .super_done
        
.lifebarf_is_live
        ; 64 health lines on screen
        ; 16 tiles across
        ; 256 possible values
        ; displaying 1/4th the range
        
        ldy #$00
        
        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #60
        bcc .tile_0_no
        sta lifebar0
        ;sta $80
        jmp .fill_remaining_bars
.tile_0_no
	lda #tile_empty
        sta lifebar0
.tile_0_done
	iny
        
        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #56
        bcc .tile_1_no
        sta lifebar1
        ;sta $80
        jmp .fill_remaining_bars
.tile_1_no
	lda #tile_empty
        sta lifebar1
.tile_1_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #52
        bcc .tile_2_no
        sta lifebar2
        jmp .fill_remaining_bars
.tile_2_no
	lda #tile_empty
        sta lifebar2
.tile_2_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #48
        bcc .tile_3_no
        sta lifebar3
        ;sta $80
        jmp .fill_remaining_bars
.tile_3_no
	lda #tile_empty
        sta lifebar3
.tile_3_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #44
        bcc .tile_4_no
        sta lifebar4
        ;sta $80
        jmp .fill_remaining_bars
.tile_4_no
	lda #tile_empty
        sta lifebar4
.tile_4_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #40
        bcc .tile_5_no
        sta lifebar5
        ;sta $80
        jmp .fill_remaining_bars
.tile_5_no
	lda #tile_empty
        sta lifebar5
.tile_5_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #36
        bcc .tile_6_no
        sta lifebar6
        ;sta $80
        jmp .fill_remaining_bars
.tile_6_no
	lda #tile_empty
        sta lifebar6
.tile_6_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #32
        bcc .tile_7_no
        sta lifebar7
        ;sta $80
        jmp .fill_remaining_bars
.tile_7_no
	lda #tile_empty
        sta lifebar7
.tile_7_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #28
        bcc .tile_8_no
        sta lifebar8
        ;sta $80
        jmp .fill_remaining_bars
.tile_8_no
	lda #tile_empty
        sta lifebar8
.tile_8_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #24
        bcc .tile_9_no
        sta lifebar9
        ;sta $80
        jmp .fill_remaining_bars
.tile_9_no
	lda #tile_empty
        sta lifebar9
.tile_9_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #20
        bcc .tile_a_no
        sta lifebara
        ;sta $80
        jmp .fill_remaining_bars
.tile_a_no
	lda #tile_empty
        sta lifebara
.tile_a_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #16
        bcc .tile_b_no
        sta lifebarb
        ;sta $80
        jmp .fill_remaining_bars
.tile_b_no
	lda #tile_empty
        sta lifebarb
.tile_b_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #12
        bcc .tile_c_no
        sta lifebarc
        ;sta $80
        jmp .fill_remaining_bars
.tile_c_no
	lda #tile_empty
        sta lifebarc
.tile_c_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #8
        bcc .tile_d_no
        sta lifebard
        ;sta $80
        jmp .fill_remaining_bars
.tile_d_no
	lda #tile_empty
        sta lifebard
.tile_d_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sec
        sbc #4
        bcc .tile_e_no
        sta lifebare
        ;sta $80
        jmp .fill_remaining_bars
.tile_e_no
	lda #tile_empty
        sta lifebare
.tile_e_done
	iny

        lda player_health
        lsr
        lsr
        ;sta $81
        ; player_health at 64 range
        sta lifebarf
        ;sta $80
        jmp .fill_remaining_bars
.tile_f_no
	lda #tile_empty
        sta lifebarf
.tile_f_done
	iny

.fill_remaining_bars
        lda #$03
.draw_health_bar
        iny
        cpy #16
        beq .super_done
	;sta PPU_DATA
        sta lifebar0,y
        jmp .draw_health_bar
.super_done


; SCORE
; XXX this is not translating correctly to the screen
        
        ldx #$00
        ldy #$00
.score_display_loop
	lda score_000000xx,y
        and #%00001111
        clc
        adc #$30
        sta score_00000001,x
        lda score_000000xx,y
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$30
        inx
        sta score_00000001,x
        inx
        iny
        cpy #$04
        bne .score_display_loop

        rts
        