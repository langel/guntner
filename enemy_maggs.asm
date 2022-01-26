

        
        
maggs_spawn: subroutine
	; x is set by enemy spawner
	lda #$03
        sta enemy_ram_type,x ; enemy type
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_ac,x ; animation counter
        lda rng0
        jsr NextRandom
        sta rng0
        sta enemy_ram_pc,x ; pattern counter
        tay
        lda game_height_scale,y
        sta enemy_ram_y,x ; y pos
        txa
        sec
        sbc #$80
        clc
        adc #$60
        sta enemy_ram_oam,x ; OAM ref
        
   	rts
        
        
        
        
;;;; HANDLING maggs
maggs_cycle: subroutine
	ldx enemy_handler_pos
	; sprite
        lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        lsr
        asl
        clc
        adc #$3c
	ldy enemy_temp_oam_x
        sta $0201+0,y
        adc #$01
        sta $0201+4,y
        
        ; x pos
        lda enemy_ram_x,x
        sta collision_0_x
        sta $0203+0,y
        clc
        adc #$08
        sta $0203+4,y
        
        ; y pos
	ldx enemy_handler_pos
        lda enemy_ram_pc,x
        lsr
        tay
        lda sine_15_max_128_length,y
        clc
        adc enemy_ram_y,x
        sta collision_0_y
	ldy enemy_temp_oam_x
        sta $0200+0,y
        sta $0200+4,y
        
        ; update pattern
        inc enemy_ram_pc,x
        inc enemy_ram_pc,x
        ; move forward
        inc enemy_ram_x,x
        ; update animation
        lda enemy_ram_ac,x
        cmp #$00
        bne .maggs_frame
        lda #$20
        sta enemy_ram_ac,x
.maggs_frame
        dec enemy_ram_ac,x
        
        lda #$10
        sta collision_0_w
        lda #$05
        sta collision_0_h
; get damage amount
        jsr enemy_get_damage_this_frame
        lda enemy_dmg_accumulator
        cmp #$00
        beq .not_hit
        lda enemy_ram_hp,x
        sec
        sbc enemy_dmg_accumulator
        bmi .dead
        sta enemy_ram_hp,x
        jmp .not_dead
.dead
        ; DEAD
        inc phase_kill_count
        jsr apu_trigger_enemy_death
	; give points
        lda #56
        jsr player_add_points_00
        ; change it into crossbones!
        lda #$01
        sta enemy_ram_type,x
        lda #$ff
        sta $0203+4,y
        lda $0203+0,y
        clc
        adc #$07
        sta $0203+0,y
        ;jsr enemy_death
.not_dead
	jsr apu_trigger_enemy_damage
        lda enemy_ram_att,x
        ora #ENEMY_HIT_PALETTE_FRAMES
        sta enemy_ram_att,x
        jmp .palette
.not_hit
        ; palette
	;ldx enemy_handler_pos
        ;lda ENEMY_RAM+7,x
        ;tax
        ;lda #$01
        ;sta $0202,x
.palette
        ; palette
        lda enemy_ram_att,x
        and #$07
        sta $400,y
        cmp #$00
        beq .normal_colors
.hit_colors
	dec enemy_ram_att,x
        lda #$00
        sta $0202,y
        sta $0206,y
        jmp .done
.normal_colors	
        lda #$02
        sta $0202,y
        sta $0206,y
.done
	jmp update_enemies_handler_next
        