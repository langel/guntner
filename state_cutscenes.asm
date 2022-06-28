

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
        
        
        
cut_scene_00_init: subroutine
        jsr WaitSync	; wait for VSYNC
        jsr render_disable
	jsr sprite_clear
        jsr nametables_clear
; various stuff on screen        
        NMTP_SETADDR cut_scene_00_tile_data
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
        

cut_scene_00_tile_data:
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


	