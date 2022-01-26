
sandbox_init: subroutine
	lda #$1f
        sta game_mode
        jsr player_init
        
        
	jsr get_enemy_slot_1_sprite
        tax
        ;jsr powerup_spawn
        
	jsr get_enemy_slot_1_sprite
        tax
        jsr bat_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
	jsr boss_vamp_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
	;jsr starglasses_spawn
        
	;jsr get_enemy_slot_1_sprite
        ;tax
        ;jsr birb_spawn
        
	;jsr get_enemy_slot_2_sprite
        ;tax
        ;jsr maggs_spawn
        
        lda #$40
        sta player_health
        
	;jsr get_enemy_slot_1_sprite
        ;tax
        ;jsr powerup_spawn
        
        rts
        
sandbox_time: subroutine
	; read user controls even in demo mode!
	jsr apu_game_music_frame
	jsr player_change_speed
	jsr player_move_position
        jsr player_bullets_check_controls
        jsr set_player_sprite

        jsr update_enemies
	jsr player_bullets_update
        jsr apu_game_frame
        
	rts