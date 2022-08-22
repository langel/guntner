

cut_scene_update_generic: subroutine
	lda player_start_d
        ora player_b_d
        ora player_a_d
        cmp #$00
        beq .do_nothing
        lda phase_end_game
        beq .start_game
        ; game complete go back to title screen
        lda #0
        beq .trigger_fadeout
.start_game
        lda #2
.trigger_fadeout
        jsr palette_fade_out_init
        jsr song_stop
.do_nothing
	jmp state_update_done
        
        
cut_scene_intro_init: subroutine
	; zerio everything out
        jsr render_disable
	jsr sprite_clear
        jsr nametables_clear
        ; colors
        ldx #12
        ldy #0
        jsr palette_load
        jsr palette_load
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
        sta scroll_page
        sta scroll_x_hi
        jsr state_render_set_addr
        lda #$08
        jsr state_update_set_addr
        jsr render_enable
        jsr palette_fade_in_init
        lda #1
        jsr song_start
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
        
        lda #$00
        sta state_sprite0
        sta scroll_page
        sta scroll_x_hi
        
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
        ; alien colors
        ldx #9
        ldy #3
        jsr palette_load
        
        inc phase_end_game    
        
        ; allow future plays to be boundless
        inc player_boundless
        
        ; use timer to decide end screen
        lda timer_minutes_10s
        cmp ##$0+char_set_offset
        beq .good
        lda timer_minutes_1s
        cmp #$5+char_set_offset
        bcc .ok
.bad
	; 15+ minutes
        NMTP_SETADDR cut_scene_ending_bad_tile_data
        ; palette
        lda #$06
        sta pal_uni_bg
        ldx #0
        ldy #0
        jsr palette_load
        lda #song_end_bad
        jsr song_start
        jmp .plot_screen
.ok
	; 10+ minutes
        NMTP_SETADDR cut_scene_ending_ok_tile_data
        ; palette
        lda #$07
        sta pal_uni_bg
        ldx #3
        ldy #0
        jsr palette_load
        lda #song_end_ok
        jsr song_start
        jmp .plot_screen
.good
	; under 10 minutes
        NMTP_SETADDR cut_scene_ending_good_tile_data
        ; palette
        lda #$01
        sta pal_uni_bg
        ldx #6
        ldy #0
        jsr palette_load
        lda #song_end_good
        jsr song_start

        
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
        
        
