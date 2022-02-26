


sandbox_init: subroutine

        ;jsr game_init
        jsr game_init_generic
  ; SCROLL SPEED
  	;lda #$27
        lda #$07
        sta scroll_speed
        
        jsr starfield_spr_init
        jsr nametables_clear
        jsr dashboard_init
        
        lda #3
        jsr state_render_set_addr
        lda #7
        jsr state_update_set_addr
        
        ; XXX maybe boss vars should be state vars
        lda #$00
        sta boss_v0
        sta boss_v1
        
        
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
	jsr boss_vamp_spawn
        
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
        

        
sandbox_scroll_y3: subroutine
	lda boss_v1
        cmp #$00
        bne .not_init
        ; init
        lda #$88
        sta boss_v0
        bne .inc_state
.not_init
	cmp #$01
        bne .not_scroll_up
	; animate sine pos $90 to $40
        ldx boss_v0
        lda sine_table,x
        sec
        sbc #$10
        sta scroll_y
        ldx boss_v0
        dex
        dex
        cpx #$40
        beq .inc_state
        stx boss_v0
        rts
.not_scroll_up
	cmp #$02
        bne .not_pause
        ; hold 2 seconds?
        inc boss_v0
        lda #160
        cmp boss_v0
        beq .inc_state
        rts
.not_pause
	cmp #$03
        bne .not_init_scroll_off
        lda #$c0
        sta boss_v0
        bne .inc_state
.not_init_scroll_off
	cmp #$04
        bne .not_scroll_off
        ; animate sine pos $c0 to $90
        ldx boss_v0
        lda sine_table,x
        sta scroll_y
        dex
        dex
        dex
        cpx #$88
        bcc .inc_state
        stx boss_v0
        rts
.not_scroll_off
.inc_state
	inc boss_v1
        rts
        
        
sandbox_update: subroutine
	jsr sandbox_scroll_y3
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