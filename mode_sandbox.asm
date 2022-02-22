
sandbox_init: subroutine

        ;jsr game_init
        jsr game_init_generic
  ; SCROLL SPEED
  	;lda #$27
        sta scroll_speed
        
        lda #2
        jsr state_render_set_addr
        lda #7
        jsr state_update_set_addr
        
	; XXX temp palette
        PPU_SETADDR $3F19
        lda #$15
        sta PPU_DATA
        lda #$00
        sta PPU_DATA
        lda #$37
        sta PPU_DATA
        
        
        jsr get_enemy_slot_1_sprite
        tax
        ;jsr chomps_spawn
        jsr get_enemy_slot_1_sprite
        tax
        ;jsr chomps_spawn
        jsr get_enemy_slot_1_sprite
        tax
        ;jsr chomps_spawn
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
        
        rts
        
        
sandbox_update: subroutine
	lda wtf
        cmp #$00
        bne .no_sfx
        ;jsr sfx_powerup_pickup
.no_sfx

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
        jsr spark_spawn
        jmp .no_enemy_spawn
.zigzag
        jsr zigzag_spawn
.no_enemy_spawn
	; read user controls even in demo mode!
	;jsr apu_game_music_frame

        ;jsr update_enemies
	jsr game_update_generic
	jsr player_move_position
        jsr player_bullets_check_controls
        
        jmp state_update_done