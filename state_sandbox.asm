


sandbox_init: subroutine

        ;jsr game_init
        jsr game_init_generic
        
        jsr nametables_clear
        jsr dashboard_init
        
        lda #2
        jsr state_render_set_addr
        lda #7
        jsr state_update_set_addr
        
        ; boss uses state vars
        lda #$00
        sta state_v0
        sta state_v1
        sta state_v6
        sta state_v7
        
        lda #$01
        sta phase_current
        
        lda #$03
        sta iframe_length
        
        ldx #$b8
        ;lda #boss_swordtner_id
        ;lda #boss_vamp_id
        ;lda #boss_scarab_id
        lda #boss_moufs_id
        jsr enemy_spawn_delegator
        
        ; for vamp testing
        lda #$f0
        ;sta player_x_hi
        lda #$08
        ;sta player_y_hi
        
        ldx #57 ; MOUFS palettes
        ;ldx #63 ; VAMP palettes
        ;ldx #69 ; scarab palette
        ;ldx #75 ; SWORDTNER palettes
        ldy #15
        jsr palette_load
        jsr palette_load
        
        ; eye pupil
        ;lda #$16 ; swordtner eyes
        ;lda #$07 ; vamp eyes
        ;sta pal_spr_3_1
        
        ;ldx #$80
        ;lda #chomps_id
        ;jsr enemy_spawn_delegator
        ;ldx #$88
        ;lda #chomps_id
        ;jsr enemy_spawn_delegator
        
        lda #$10
        sta dart_velocity
.skeet_loop
	jsr get_enemy_slot_1_sprite
        tax
        lda #skeet_id
        ;jsr enemy_spawn_delegator
        dec dart_velocity
        bpl .skeet_loop
        
        
        ldx #$05
        jsr arc_sequence_set
	jsr get_enemy_slot_1_sprite
        tax
        lda #galger_id
        ;jsr enemy_spawn_delegator
        
        
	jsr get_enemy_slot_2_sprite
        tax
        lda #muya_id
        ;jsr enemy_spawn_delegator
        
        
        
        
	jsr get_enemy_slot_4_sprite
        tax
        ;lda #dumbface_id
        lda #ant_id
        ;lda #skully_id
        lda #ikes_mom_id
        ;jsr enemy_spawn_delegator
        
        
        ;lda #$40
        lda #$ff
        sta player_health
        
        
	;jsr get_enemy_slot_1_sprite
        ;tax
        ;jsr powerup_spawn
        jsr starfield_draw_dash_top_bar_nametable0
        jsr palette_fade_in_init
        jsr render_enable
        
        rts
        

        
        
sandbox_update: subroutine

	; read user controls even in demo mode!
	;jsr apu_game_music_frame

        ;jsr update_enemies
	jsr game_update_generic
	jsr player_move_position
        jsr player_bullets_check_controls
        
        jmp state_update_done