;;; constants

dash_page1_top_bar	= $22c0
dash_page2_top_bar	= $26c0

speed_addr		= $2706
life_bar_addr		= $2708
lives_addr		= $271d
phase_addr		= $2748
score_addr		= $274c
timer_addr		= $2756
tile_empty		= $05

dash_cache EQU $0100


dashboard_init: subroutine
        
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
	PPU_SETADDR dash_page1_top_bar
        lda #$04
        ldy #$20
.tile_dash_set_page1
        sta PPU_DATA
        dey
        bne .tile_dash_set_page1
        
        ; fill page 2 dashboard top row
	PPU_SETADDR dash_page2_top_bar
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
	hex 1da0a1a1a1a1a1a3
        hex a1a1a1a1a1a1a1a1
        hex a1a1a1a1a1a1a1a1
        hex a3a1a1a1a1a1a21d
        ; row 2 : health, meter, lives
	hex 1db0a5a6a7a8b1b3
	hex b1b1b1b1b1b1b1b1
        hex b1b1b1b1b1b1b1b1
        hex b318197830b1b21d
        ; row 3 : middle hud frames
	hex 1dd0d1d1d1d1d1c3
        hex d1d1a4d3d1d1d1d1
        hex d1d1d1d1a4d3d1d1
        hex c3d1d1d1d1d1d21d
        ; row 4 : wave, score, time
	hex 1db05048415345b1
	hex b1b1b2b0b1b1b1b1
	hex b1b1b1b2b2b0b1b1
	hex b1b1b1b1b1b1b21d
	; row 5 : bottom hud frames
        ; XXX should be better defined than solid tiles
	hex 1dc0c1c1c1c1c1c1
	hex c1c1c2c0c1c1c1c1
	hex c1c1c1c1c2c0c1c1
	hex c1c1c1c1c1c1c21d


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
        clc
        adc #$30
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


        
        
        
; GET DASH UPDATES READY TO RENDER
dashboard_update: subroutine

; player speed
        lda player_speed
        clc
        adc #$31
        sta $0100+6

; LIFEBARF
	; XXX gut / refactor how lifebar messaging works
	; check if end game
	lda phase_end_game
        cmp #$00
        beq .lifebarf_not_end_game
        ; "gg congration gg"
        ldy #$20
        jsr dashboard_message_set
        jmp .no_lifebar
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
        lda #$20 ; empty tile
        sta dash_cache+$08,y
        iny
        bne .find_top_tile
.top_tile_found
	lda temp01
        sec
        sbc temp00
        clc
        adc #$08
        sta dash_cache+$08,y
.fill_remaining_tiles
        iny
        cpy #$10
        beq .no_lifebar
	lda #$0b ; full tile
        sta dash_cache+$08,y
        bne .fill_remaining_tiles 
.no_lifebar


; PHASE
	lda phase_current
        clc
        adc #$30
	sta dash_cache+$28
	sta dash_cache+$29
       
       
; SCORE
        ldx #$07
        ldy #$00
.score_display_loop
	lda score_000000xx,y
        and #%00001111
        clc
        adc #$30
        sta dash_cache+$2c,x
        lda score_000000xx,y
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$30
        dex
        sta dash_cache+$2c,x
        dex
        iny
        cpy #$04
        bne .score_display_loop
        
        
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
        lda #$aa
        sta dash_cache+$38
        lda timer_seconds_10s
        sta dash_cache+$39
        lda timer_seconds_1s
        sta dash_cache+$3a
        ; period
        lda #$2e
        sta dash_cache+$3b
        lda timer_frames_10s
        sta dash_cache+$3c
        lda timer_frames_1s
        sta dash_cache+$3d
.timer_done

        rts
        