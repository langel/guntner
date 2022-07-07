

cut_scene_update_generic: subroutine
	lda player_start_d
        ora player_b_d
        ora player_a_d
        cmp #$00
        beq .do_nothing
        lda #2
        jsr palette_fade_out_init
        jsr song_stop
.do_nothing
	jmp state_update_done
        
        
cut_scene_intro_palette:
	hex 0f 0c 30 3c
	hex    04 1b 37
        
cut_scene_intro_init: subroutine
	; zerio everything out
        jsr render_disable
	jsr sprite_clear
        jsr nametables_clear
        ; colors
        ldy #6
.palette_loop:
	lda cut_scene_intro_palette,y
        sta pal_uni_bg,y
	dey
        bpl .palette_loop
        ; Distressed Alien
	PPU_SETADDR #$2086
        jsr cut_scene_alien_main_draw
        ; alien attributes
        ldx #%01010101
	PPU_SETADDR #$23c9
	stx PPU_DATA
	stx PPU_DATA
	stx PPU_DATA
	PPU_SETADDR #$23d1
	stx PPU_DATA
	stx PPU_DATA
	stx PPU_DATA
	; put text on screen
        NMTP_SETADDR cut_scene_intro_tile_data
        jsr nametable_tile_planter
        ; setup everything else
        lda #$00
        jsr state_render_set_addr
        lda #$08
        jsr state_update_set_addr
        jsr render_enable
        jsr palette_fade_in_init
        lda #1
        jsr song_start
	rts
        
        
cut_scene_alien_attributes: subroutine
        ldx #%01010101
	stx PPU_DATA
	stx PPU_DATA
	stx PPU_DATA
	PPU_SETADDR #$23d1
	stx PPU_DATA
	stx PPU_DATA
	stx PPU_DATA
        rts
        
cut_scene_alien_main_draw: subroutine
        lda #0
        sta temp00 ; pattern tile counter
        ldx #7
.alien_tile_loop
	ldy #7
.alien_tile_row_loop
	lda temp00
	sta PPU_DATA
        inc temp00
	dey
        bpl .alien_tile_row_loop
        ; setup empty tile fill
        ldy #23
        lda #tile_empty
.alien_row_filler_loop
	sta PPU_DATA
	dey
        bpl .alien_row_filler_loop
	dex
        bpl .alien_tile_loop
        rts
        
cut_scene_alien_end_draw_row: subroutine
	; x = start tile id
        ldy #$07
.row_loop
        stx PPU_DATA
        inx
        dey
        bpl .row_loop
	rts
        
        
        
cut_scene_outro_init: subroutine
        jsr render_disable
	jsr sprite_clear
        jsr nametables_clear
        
        ; draw original alien
	PPU_SETADDR #$208c
        jsr cut_scene_alien_main_draw
        ; update alien image
        ldx #$40
	PPU_SETADDR #$208c
        jsr cut_scene_alien_end_draw_row
	PPU_SETADDR #$20ac
        jsr cut_scene_alien_end_draw_row
	PPU_SETADDR #$20cc
        jsr cut_scene_alien_end_draw_row
	PPU_SETADDR #$212c
        jsr cut_scene_alien_end_draw_row
        
        ; alien attributes
        ldx #%01010101
	PPU_SETADDR #$23ca
	stx PPU_DATA
	stx PPU_DATA
	stx PPU_DATA
	PPU_SETADDR #$23d2
	stx PPU_DATA
	stx PPU_DATA
	stx PPU_DATA
        ; XXX final colors not picked yet
        ; alien colors
        lda #$0d
        sta pal_bg_1_1
        lda #$3c
        sta pal_bg_1_2
        lda #$24
        sta pal_bg_1_3
        ; alien colors
        lda #$3c
        sta pal_bg_1_1
        lda #$1c
        sta pal_bg_1_2
        lda #$24
        sta pal_bg_1_3
        
        ; XXX temp for debug purposes
        inc phase_end_game
        lda #$2+char_set_offset
        sta timer_minutes_1s
        lda #$1+char_set_offset
        sta timer_minutes_10s
        
        
        ; use timer to decide end screen?
        lda timer_minutes_10s
        cmp #$1+char_set_offset
        beq .ok
        bcc .good
.bad
        NMTP_SETADDR cut_scene_ending_bad_tile_data
        ; palette
        lda #$06
        sta pal_uni_bg
        lda #$0f
        sta pal_bg_0_1
        lda #$30
        sta pal_bg_0_2
        lda #$27
        sta pal_bg_0_3
        jmp .plot_screen
.ok
        NMTP_SETADDR cut_scene_ending_ok_tile_data
        ; palette
        lda #$07
        sta pal_uni_bg
        lda #$0f
        sta pal_bg_0_1
        lda #$10
        sta pal_bg_0_2
        lda #$30
        sta pal_bg_0_3
        jmp .plot_screen
.good
        NMTP_SETADDR cut_scene_ending_good_tile_data
        ; palette
        lda #$02
        sta pal_uni_bg
        lda #$1d
        sta pal_bg_0_1
        lda #$37
        sta pal_bg_0_2
        lda #$27
        sta pal_bg_0_3

        
.plot_screen    
        jsr nametable_tile_planter
        ; final time display
        NMTP_SETADDR cut_scene_ending_time_tile_data
        jsr nametable_tile_planter
        lda timer_minutes_10s
        sta PPU_DATA
        lda timer_minutes_1s
        sta PPU_DATA
        lda #char_set_colon
        sta PPU_DATA
        lda timer_seconds_10s
        sta PPU_DATA
        lda timer_seconds_1s
        sta PPU_DATA
        lda #char_set_period
        sta PPU_DATA
        lda timer_frames_10s
        sta PPU_DATA
        lda timer_frames_1s
        sta PPU_DATA
        
        lda #$00
        jsr state_render_set_addr
        lda #$08
        jsr state_update_set_addr
        jsr render_enable
        jsr palette_fade_in_init
	rts
        
        
