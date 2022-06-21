


sandbox_init: subroutine

        ;jsr game_init
        jsr game_init_generic
  ; SCROLL SPEED
  	;lda #$27
        lda #$07
        sta scroll_speed
        
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
        
 
        
        ldx #$80
        ;jsr chomps_spawn
        ldx #$88
        ;jsr chomps_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
        ;jsr uzi_spawn
	;jsr boss_vamp_spawn
        jsr boss_scarab_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
	;jsr starglasses_spawn
	jsr get_enemy_slot_4_sprite
        tax
	;jsr starglasses_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
        ;jsr ant_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
        ;jsr ant_spawn
        
	jsr get_enemy_slot_4_sprite
        tax
        ldx #$c8
        ;jsr throber_spawn
        
        ;lda #$40
        lda #$ff
        sta player_health
        ; XXX for vamp testing
        lda #$f0
        ;sta player_x_hi
        lda #$08
        ;sta player_y_hi
        
	;jsr get_enemy_slot_1_sprite
        ;tax
        ;jsr powerup_spawn
        jsr starfield_draw_dash_top_bar_nametable0
        jsr palette_fade_in_init
        jsr render_enable
        
        rts
        

        
        
sandbox_update: subroutine
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
	lda wtf
        bne .no_noose
	jsr get_enemy_slot_4_sprite
        cmp #$ff
        beq .no_noose
        ;jsr lasso_spawn
        
.no_noose
	; read user controls even in demo mode!
	;jsr apu_game_music_frame

        ;jsr update_enemies
	jsr game_update_generic
	jsr player_move_position
        jsr player_bullets_check_controls
        
        jmp state_update_done