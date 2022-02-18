

cut_scene_update_generic: subroutine
	lda player_start_d
        ora player_b_d
        ora player_a_d
        cmp #$00
        beq .do_nothing
        lda #2
        jsr palette_fade_out_init
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
	rts
        

cut_scene_00_tile_data:
        .hex 20a6
        .hex 969720209697
        .byte #$00
        .hex 20e6
        .hex 20989b9b9920
        .byte #$00
        .hex 2110
        .byte "MY DINGLE"
        .byte #$00
        
        .hex 2142
        .byte "is very sick and there are"
        .byte #$00
        
        .hex 2182
        .byte "life saving drugs very far"
        .byte #$00
        .hex 21c2
        .byte "away!  Please drive through"
        .byte #$00
        .hex 2202
        .byte "the 13th dimension quickly"
        .byte #$00
        .hex 2242
        .byte "so my dingle is saved."
        .byte #$00
        .byte #$ff


	