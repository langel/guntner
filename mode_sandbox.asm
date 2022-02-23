
phase_msg_tile_data:
        .hex 2107
        .byte "PHASE x1 COMPLETED"
        .byte #$00
        .byte #$ff


sandbox_init: subroutine

        ;jsr game_init
        jsr game_init_generic
  ; SCROLL SPEED
  	;lda #$27
        lda #$03
        sta scroll_speed
        
        jsr starfield_spr_init
        jsr nametables_clear
        jsr dashboard_init
        
        lda #3
        jsr state_render_set_addr
        lda #7
        jsr state_update_set_addr
        
        
        
        PPU_SETADDR $2001
        ; update column
        lda #CTRL_INC_32
        sta PPU_CTRL
        lda #$0d
        ldx #$20
.col_loop
        sta PPU_DATA
        dex
        bne .col_loop
        
       	; put that shit back to sequential order
        lda #0
        sta PPU_CTRL
        
        jsr get_enemy_slot_1_sprite
        tax
        jsr chomps_spawn
        jsr get_enemy_slot_1_sprite
        tax
        ;jsr spark_spawn
        jsr get_enemy_slot_1_sprite
        tax
        ;jsr spark_spawn
        jsr get_enemy_slot_1_sprite
        tax
        ;jsr spark_spawn
        jsr get_enemy_slot_1_sprite
        tax
        jsr spark_spawn
        jsr get_enemy_slot_1_sprite
        tax
        jsr zigzag_spawn
        
	jsr get_enemy_slot_1_sprite
        tax
        ;jsr bat_spawn
        
	jsr get_enemy_slot_1_sprite
        tax
        ;jsr skeet_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
	;jsr boss_vamp_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
	;jsr starglasses_spawn
	jsr get_enemy_slot_4_sprite
        tax
	;jsr starglasses_spawn
        
	;jsr get_enemy_slot_1_sprite
        ;tax
        ;jsr birb_spawn
        
	;jsr get_enemy_slot_2_sprite
        ;tax
        ;jsr maggs_spawn
        
        ;lda #$40
        lda #$ff
        sta player_health
        
	;jsr get_enemy_slot_1_sprite
        ;tax
        ;jsr powerup_spawn
        jsr render_enable
        jsr palette_fade_in_init
        
        rts
        
        
sandbox_scroll_y: subroutine
	inc scroll_y
        lda scroll_y
        cmp #240
        bcc .dont_reset_y
        lda #$00
        sta scroll_y
.dont_reset_y
	rts
        
        
sandbox_update: subroutine
	;jsr sandbox_scroll_y
	jsr get_enemy_slot_1_sprite
        cmp #$ff
        ;mp #$40
        beq .no_enemy_spawn
        tax
        lda rng0
        lsr
        and #%00000010
        cmp #$00
        bne .zigzag
        ;jsr skeet_spawn
        ;jsr spark_spawn
        jmp .no_enemy_spawn
.zigzag
        ;jsr zigzag_spawn
.no_enemy_spawn
	; read user controls even in demo mode!
	;jsr apu_game_music_frame

        ;jsr update_enemies
	jsr game_update_generic
	jsr player_move_position
        jsr player_bullets_check_controls
        
        jmp state_update_done