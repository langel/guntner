;;; constants

dash_page1_top_bar	= $22c0
dash_page2_top_bar	= $26c0

speed_addr		= $2706
life_bar_addr		= $2708
lives_addr		= $271c
phase_addr		= $2748
score_addr		= $274c
timer_addr		= $2756

dash_cache		= $0100

dash_top_bar_tile 	EQM $ad


dashboard_init: subroutine

	lda #$ff
        sta dashboard_message
        
        ; fill nametable 2 with HUB bg color
	PPU_SETADDR $27c0
	lda #%11111111
        ldx #$c0
.23f0_loop
        sta PPU_DATA
        inx
        bne .23f0_loop
        
        ; COLOR SPLIT
        ; set split color attr for top row
	PPU_SETADDR $27e8
	lda #%11110001
        ldx #$f8
.27e8_loop
        sta PPU_DATA
        inx
        bne .27e8_loop
        
        
        
        ; fill page 2 dashboard top row
	PPU_SETADDR dash_page2_top_bar
        lda #dash_top_bar_tile
        ldy #$20
.set_top_bar
	sta PPU_DATA
        dey
        bne .set_top_bar
        
	; fill page 2 dashboard tiles
        ldx #$00
.dashboard_fill_tiles
	lda dashboard_bg_tiles,x
        sta PPU_DATA
        inx
        cpx #$a0
        bne .dashboard_fill_tiles
	ldx #$00
.dash_cache_fill
	lda dashboard_bg_tiles+$20,x
        sta dash_cache,x
	lda dashboard_bg_tiles+$60,x
        sta dash_cache+$20,x
        inx
        cpx #$20
        bne .dash_cache_fill
	rts
        

        
dashboard_bg_tiles:
	; row 0 is top bar
	; row 1 : top hud frames	
        hex b4b4bcbcbcbcbcbe
        hex bcbcbcbcbcbcbcbc
        hex bcbcbcbcbcbcbcbc
        hex bebcbcbcbcbcbdb4
        ; row 2 : health, meter, lives
	hex b4b0
        byte #char_set_S
        hex a8a9aa
        hex ffb3
	hex ffffffffffffffff
	hex ffffffffffffffff
        hex b3aeaf
        byte #char_set_x
        hex 30b1b2b6
        ; row 3 : middle hud frames
        hex b4b8b9b9b9b9b9b7
        hex b9b9bfbbb9b9b9b9
        hex b9b9b9b9bfbbb9b9
        hex b7b9b9b9b9b9bab4
        ; row 4 : wave, score, time
	hex b4b0
        byte #char_set_P,#char_set_H,#char_set_A
        byte #char_set_S,#char_set_E,#tile_empty
	hex ffffb2b6ffffffff
	hex ffffffffb2b0ffff
	hex ffffffffffffb2b4
	; row 5 : bottom hud frames
        hex b4b4b5b5b5b5b5b5
	hex b5b5b6b4b5b5b5b5
	hex b5b5b5b5b6b4b5b5
        hex b5b5b5b5b5b5b6b6


        
        
dashboard_message_set: subroutine
; set y for message start offset
	ldx #$00
.loop
        lda dashboard_messages,y
        sta dash_cache+$08,x
        iny
        inx
        cpx #$10
        bne .loop
        rts
        



; RENDER DASH STATS TO SCREEN
dashboard_render: subroutine
	; top hud info row
	PPU_SETADDR $2706 	; PPU_SETADDR is 12 cycles
        ldx #$06
.top_row_loop
        lda dash_cache,x
        sta PPU_DATA
        inx
        cpx #$1e
        bne .top_row_loop
        
.lives
	PPU_SETADDR lives_addr
        lda player_lives
        jsr get_char_hi
        sta PPU_DATA
        lda player_lives
        jsr get_char_lo
        sta PPU_DATA
        
        ; bottom hud info row
        PPU_SETADDR $2748
        ldx #$08
.bottom_row_loop
        lda dash_cache+$20,x
        sta PPU_DATA
        inx
        cpx #$1e
        bne .bottom_row_loop
        rts



dashboard_gauges_table:
	byte phase_kill_counter
	byte player_frag_counter
	byte player_x_hi
	byte player_y_hi
        
        
; GET DASH UPDATES READY TO RENDER
dashboard_update: subroutine

; player speed
        lda player_speed
        clc
        adc #char_set_offset+1
        sta $0100+6

; LIFEBARF
	ldy dashboard_message
        bmi .lifebarf_is_live
        jsr dashboard_message_set
        jmp .no_lifebar
        
.lifebarf_is_live
        ; 64 health lines on screen
        ; 16 tiles across
        ; 256 possible values
        ; displaying 1/4th the range
        
        ldy #$00
        
        lda #$3c   ; #60 (4 less than max)
        sta temp00 ; life value floor for tile
        
        lda player_health
        lsr
        lsr
        sta temp01 ; life / 4 aka 0..63
.find_top_tile
        lda temp01
        cmp temp00
        bcs .top_tile_found ; life > tile floor value
        lda temp00
        sec
        sbc #$04
        sta temp00
        lda #tile_empty 
        sta dash_cache+$08,y
        iny
        bne .find_top_tile
.top_tile_found
	lda temp01
        sec
        sbc temp00
        clc
        adc #$a4
        sta dash_cache+$08,y
.fill_remaining_tiles
        iny
        cpy #$10
        beq .no_lifebar
	lda #$a7 ; full tile
        sta dash_cache+$08,y
        bne .fill_remaining_tiles 
.no_lifebar


; PHASE
	lda phase_current
        jsr get_char_hi
	sta dash_cache+$28
	lda phase_current
        jsr get_char_lo
	sta dash_cache+$29
       
       
; GAUGES
; used to be scoreboard

; phase_kill_counter
; player_frag_counter
; player_x_hi
; player_y_hi

        ldx #$07
        ldy #$03
.guages_display_loop
	stx temp00
	ldx dashboard_gauges_table,y
        lda $0000,x
        sta temp01
        ldx temp00
        jsr get_char_lo
        sta dash_cache+$2c,x
	lda temp01
        jsr get_char_hi
        dex
        sta dash_cache+$2c,x
        dex
        dey
        bpl .guages_display_loop
        
        
; TIMER	
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
        lda timer_minutes_10s
        sta dash_cache+$36
        lda timer_minutes_1s
        sta dash_cache+$37
        ; colon
        lda #char_set_colon
        sta dash_cache+$38
        lda timer_seconds_10s
        sta dash_cache+$39
        lda timer_seconds_1s
        sta dash_cache+$3a
        ; period
        lda #char_set_period
        sta dash_cache+$3b
        lda timer_frames_10s
        sta dash_cache+$3c
        lda timer_frames_1s
        sta dash_cache+$3d
.timer_done

        rts
        