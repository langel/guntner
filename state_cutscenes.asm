

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
        
        
        
cut_scene_intro_init: subroutine
        jsr render_disable
	jsr sprite_clear
        jsr nametables_clear
; various stuff on screen        
        NMTP_SETADDR cut_scene_intro_tile_data
        jsr nametable_tile_planter
        lda #$00
        jsr state_render_set_addr
        lda #$08
        jsr state_update_set_addr
        jsr render_enable
        jsr palette_fade_in_init
        lda #1
        jsr song_start
	rts
        
        
cut_scene_outro_init: subroutine
        jsr render_disable
	jsr sprite_clear
        jsr nametables_clear
        
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
        sta pal_bg_3_1
        lda #$30
        sta pal_bg_3_2
        lda #$27
        sta pal_bg_3_3
        ; XXX why doesn't setting this here work?
        ;lda MASK_TINT_RED | MASK_BG
        ;lda MASK_TINT_RED
        ;sta ppu_mask_cache
        ;sta $2001
        jmp .plot_screen
.ok
        NMTP_SETADDR cut_scene_ending_ok_tile_data
        ; palette
        lda #$00
        sta pal_uni_bg
        lda #$0f
        sta pal_bg_3_1
        lda #$10
        sta pal_bg_3_2
        lda #$30
        sta pal_bg_3_3
        jmp .plot_screen
.good
        NMTP_SETADDR cut_scene_ending_good_tile_data
        ; palette
        lda #$0c
        sta pal_uni_bg
        lda #$06
        sta pal_bg_3_1
        lda #$27
        sta pal_bg_3_2
        lda #$38
        sta pal_bg_3_3

        
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
        
        

cut_scene_intro_tile_data:
	; "" + 969720209697
	hex 20a6
	hex 969720209697
	byte #$00
	; "" + 20989b9b9920
	hex 20e6
	hex 20989b9b9920
	byte #$00
	; "MY DINGLE"
	hex 2110
	hex 606c6e575c615a5f58
	byte #$00
	; "is very sick and there are"
	hex 2142
	hex 424c6e4f3e4b526e4c423c446e3a473d6e4d413e4b3e6e3a4b3e
	byte #$00
	; "life saving drugs very far"
	hex 2182
	hex 45423f3e6e4c3a4f4247406e3d4b4e404c6e4f3e4b526e3f3a4b
	byte #$00
	; "away!  Please drive through"
	hex 21c2
	hex 3a503a52726e6e63453e3a4c3e6e3d4b424f3e6e4d414b484e4041
	byte #$00
	; "the 13th dimension quickly"
	hex 2202
	hex 4d413e6e31334d416e3d42463e474c4248476e4a4e423c444552
	byte #$00
	; "so my dingle is saved."
	hex 2242
	hex 4c486e46526e3d424740453e6e424c6e4c3a4f3e3d70
	byte #$00
	byte #$ff
        
        


cut_scene_ending_bad_tile_data:
	; "Why did you bring me "
	hex 21c2
	hex 6a41526e3d423d6e52484e6e3b4b4247406e463e6e
	byte #$00
	; "a dead dingle?"
	hex 2210
	hex 3a6e3d3e3a3d6e3d424740453e71
	byte #$00
	; "You took too long!"
	hex 2287
	hex 6c484e6e4d4848446e4d48486e4548474072
	byte #$00
	byte #$ff


cut_scene_ending_ok_tile_data:
	; "The dingle is now in a coma."
	hex 21c2
	hex 67413e6e3d424740453e6e424c6e4748506e42476e3a6e3c48463a70
	byte #$00
	; "It may recover."
	hex 2228
	hex 5c4d6e463a526e4b3e3c484f3e4b70
	byte #$00
	; "You could have been faster."
	hex 2282
	hex 6c484e6e3c484e453d6e413a4f3e6e3b3e3e476e3f3a4c4d3e4b70
	byte #$00
	byte #$ff


cut_scene_ending_good_tile_data:
	; "What a happy,healthy DINGLE!"
	hex 21c2
	hex 6a413a4d6e3a6e413a4949526f413e3a454d41526e575c615a5f5872
	byte #$00
	; "J O O D    J O R B!!"
	hex 2226
	hex 5d6e626e626e576e6e6e6e5d6e626e656e557272
	byte #$00
	; "You seem to be so expedient!"
	hex 2282
	hex 6c484e6e4c3e3e466e4d486e3b3e6e4c486e3e51493e3d423e474d72
	byte #$00
	byte #$ff


cut_scene_ending_time_tile_data:
	; "YOUR TIME : "
	hex 2306
	hex 6c6268656e675c60586e756e
	byte #$00
	byte #$ff