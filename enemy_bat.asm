

bat_spawn: subroutine
	; x = slot in enemy ram
        ; y = boss slot in enemy ram
        ; stash boss slot in pattern counter
	lda #$07
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$20
        sta enemy_ram_x,x
        sta enemy_ram_y,x 
        lda #$00
        sta enemy_ram_pc,x
        txa
        lsr
        clc
        adc #$20
        sta enemy_ram_oam,x
	rts
     
     
bat_cycle:
	ldx enemy_handler_pos
        ldy enemy_temp_oam_x
        ; update x pos
        ldy enemy_ram_pc,x
        lda enemy_ram_ac,x
        tax
        tya
        lsr
        lsr
        jsr sine_of_scale
        clc
	ldx enemy_handler_pos
        adc enemy_ram_x,x
        ldy enemy_temp_oam_x
        sta $0203,y
        sta collision_0_x
        ; update y pos
        ldy enemy_ram_pc,x
        lda enemy_ram_ac,x
        clc
        adc #$40
        tax
        tya
        lsr
        lsr
        jsr sine_of_scale
        clc
	ldx enemy_handler_pos
        adc enemy_ram_y,x
        ldy enemy_temp_oam_x
        sta $0200,y
        sta collision_0_y
        ; update animation
        lda enemy_ram_ac,x
        cmp #$80
        bcs .pattern_inc
        dec enemy_ram_pc,x
        jmp .pattern_done
.pattern_inc
	inc enemy_ram_pc,x
.pattern_done
        inc enemy_ram_ac,x
        lda enemy_ram_ac,x
        lsr
        lsr
        and #%00000011
        cmp #$00
        bne .not_frame0
        lda #$39
        jmp .frame_done
.not_frame0
        cmp #$02
        bne .not_frame2
        lda #$3b
        jmp .frame_done
.not_frame2
	lda #$3a        	
.frame_done
        sta $0201,y
        ; setup collision dimensions
        lda #$08
        sta collision_0_w
        sta collision_0_h
; get damage amount
        jsr enemy_get_damage_this_frame
        lda enemy_dmg_accumulator
        cmp #$00
        beq .not_hit
        lda enemy_ram_hp,x
        sec
        sbc enemy_dmg_accumulator
        bmi .is_dead
        sta enemy_ram_hp,x
        jmp .not_dead
.is_dead
	inc phase_kill_count
	; give points
        lda #05
        jsr player_add_points_00
        ; change it into crossbones!
        jsr apu_trigger_enemy_death
        lda #$01
        sta ENEMY_RAM+0,x
.not_dead
	jsr apu_trigger_enemy_damage
        ; palette
        lda #$00
        sta $0202,y
        jmp .done
.not_hit
        ; palette
        lda #$01
        sta $0202,y
.done
	jsr player_collision_detect
	jmp update_enemies_handler_next