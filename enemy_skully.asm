
                    
skully_spawn: subroutine
	; x is set by enemy spawner
	lda #$05
        sta $0300,x ; enemy type
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda rng0
        sta $0304,x ; animation counter
        lda #$00
        sta $0301,x ; x pos
        sta $0303,x ; pattern counter
        lda rng0
        jsr NextRandom
        sta rng0
        tay
        lda game_height_scale,y
        sta $0302,x ; y pos
        lsr
        clc
        adc #$10
        sta $0302,x ; y pos
        txa
        sec
        sbc #$a0
        asl
        clc
        adc #$80
        sta $0307,x ; OAM ref   
   	rts



;;;; HANDLING SKULLY
skully_cycle: subroutine
	; store palette in temp palette register
        ; so we can apply flip horizontal if needed
        lda #$03
        sta enemy_temp_palette
        ; stash OAM ADDR in y register
        ldy enemy_temp_oam_x
        ; stash enemy addr in x register
        ldx enemy_handler_pos
        ; let's find what frame we're on
        lda ENEMY_RAM+4,x
        lsr
        lsr
        lsr
        lsr
        lsr
        asl
        ; accumulator is now in 0..7 range except x2
        cmp #$0a
        beq .skully_sprite_5
        cmp #$0c
        beq .skully_sprite_6
        cmp #$0e
        beq .skully_sprite_7
.skully_normal_frames
	jsr sprite_4_set_sprite
        jmp .skully_sprites_done
.skully_sprite_5
	lda #$06
        clc
        ; stash them sprites
        sta $0205,y
        adc #$01
        sta $0201,y
        adc #$0f
        sta $020d,y
        adc #$01
        sta $0209,y
        ; palette
        lda enemy_temp_palette
        ora #$40
	sta enemy_temp_palette
	jmp .skully_sprites_done
.skully_sprite_6
	lda #$04
        clc
        ; stash them sprites
        sta $0205,y
        adc #$01
        sta $0201,y
        adc #$0f
        sta $020d,y
        adc #$01
        sta $0209,y
        ; palette
        lda enemy_temp_palette
        ora #$40
	sta enemy_temp_palette
	jmp .skully_sprites_done
.skully_sprite_7
	lda #$02
        clc
        ; stash them sprites
        sta $0205,y
        adc #$01
        sta $0201,y
        adc #$0f
        sta $020d,y
        adc #$01
        sta $0209,y
        ; palette
        lda enemy_temp_palette
        ora #$40
	sta enemy_temp_palette
	jmp .skully_sprites_done
.skully_sprites_done
        ; x pos
        lda enemy_ram_x,x
        sta collision_0_x
        jsr sprite_4_set_x
        ; y pos
        lda enemy_ram_y,x
        sta collision_0_y
        jsr sprite_4_set_y
.skully_frame
	; update spinning counter
	lda #$07
        clc
        adc ENEMY_RAM+4,x
        sta ENEMY_RAM+4,x
        
        ; move skully
        jsr skully_handle_movement
        
        ; stash it in collision detector
        lda #$10
        sta collision_0_w
        sta collision_0_h
; get damage amount
        jsr enemy_get_damage_this_frame
        lda enemy_dmg_accumulator
        cmp #$00
        beq .normal_palette
        lda enemy_ram_hp,x
        sec
        sbc enemy_dmg_accumulator
        bcc .skully_dead
        sta enemy_ram_hp,x
        jmp .skully_not_dead
        
.skully_dead
	inc phase_kill_count
        jsr apu_trigger_enemy_death
	; give points
        lda #99
        jsr player_add_points_00
        lda #99
        jsr player_add_points_00__
        ; spawn crossbones
	lda #$01
        sta enemy_ram_type,x
	ldy enemy_temp_oam_x
        jmp sprite_4_cleanup_for_next
.skully_not_dead
        ; setup hit palette counter
	lda #ENEMY_HIT_PALETTE_FRAMES
        sta enemy_ram_att,x
	jsr apu_trigger_enemy_damage
.decide_palette
	lda enemy_ram_att,x
        cmp #$00
        bne .hit_palette
.normal_palette
        ; palette
        lda enemy_temp_palette 
        sta $0202,y
        sta $0206,y
        sta $020a,y
        sta $020e,y
        jmp .skully_done
.hit_palette
	dec enemy_ram_att,x
	dec ENEMY_RAM+6,x
        ; palette
        dec enemy_temp_palette
        dec enemy_temp_palette
        dec enemy_temp_palette
        lda enemy_temp_palette
        sta $0202,y
        sta $0206,y
        sta $020a,y
        sta $020e,y
        jmp .skully_done
.skully_done
	jmp update_enemies_handler_next
        
        
skully_handle_movement: subroutine
	lda phase_current
        cmp #$00
        beq .demoshit
        lda #$69
        sta $f9
        lda ENEMY_RAM+3,x
        cmp #$40
        bne .not_chasing
        dec ENEMY_RAM+1,x
        
        rts
.not_chasing
        ; but we are zooming
        lda #$20
        sta ENEMY_RAM+3,x
        lda #$04
        clc
        adc ENEMY_RAM+1,x
        sta ENEMY_RAM+1,x
        sta $f8
        cmp #240
        bcc .demoshit
        lda #$40
        sta ENEMY_RAM+3,x
	rts
.demoshit
        ; move skully to the right
        inc ENEMY_RAM+1,x
	rts
   