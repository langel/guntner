

ikes_mom_spawn:
	jsr get_oam_offset_from_ram_offset
        lda #$fa
        sta oam_ram_x,y
        lda #$80
        sta oam_ram_y,y
        lda #$05
        sta enemy_ram_ex,x
        ; reset spawn counter
        lda #$00
        sta ftw
	rts
        
        
ikes_mom_cycle:
        lda #$10
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death

	lda wtf
        and #$0f
        bne .dir_update_done
        ; next direction
        jsr enemy_get_direction_of_player
        sta temp00
        ; current direction
        lda enemy_ram_ex,x
        sta temp01 
        
        ; diff 1
        sec
        sbc temp00
        bpl .diff_1_set
        clc
        adc #24
.diff_1_set
        sta temp02
        ; diff 2
        lda temp00
        sec
        sbc temp01
        bpl .diff_2_set
        clc
        adc #24
.diff_2_set
        sta temp03
        ; which dir faster
        cmp temp02
        beq .dir_set
        bcs .counterclockwise
.clockwise
	lda #$01
        sta enemy_ram_pc,x
        bne .dir_set
.counterclockwise
	lda #$ff
        sta enemy_ram_pc,x
.dir_set
	lda enemy_ram_ex,x
        clc
        adc enemy_ram_pc,x
        bpl .skip_neg_fix
        clc
        adc #24
.skip_neg_fix
	cmp #24
        bne .skip_over_fix
        lda #0
.skip_over_fix
        sta enemy_ram_ex,x
.dir_update_done

	lda arctang_velocities_lo+2
        sta arctang_velocity_lo
	jsr arctang_enemy_update
        
        ; shake?
        lda wtf
        cmp #$c0
        bcc .dont_banshee
        ; x shake
        jsr shake_8
        adc oam_ram_x,y
        sta oam_ram_x,y
        ; y shake
        jsr shake_8
        adc oam_ram_y,y
        sta oam_ram_y,y
        ; sfx (pu1)
        lda #$3f
        sta APU_PULSE1_VOL
        lda #$08
        sta APU_PULSE1_SWEEP
        lda wtf
        and #$3f
        eor #$3f
        lsr
        adc #$a0
        sta APU_PULSE1_TIMER_LO
        lda #$08
        sta APU_PULSE1_TIMER_HI
        inc apu_pu1_counter
.dont_banshee
        
	; x
	lda oam_ram_x,y
        jsr sprite_4_set_x
        ; y
	lda oam_ram_y,y
        jsr sprite_4_set_y
        ; sprite
        lda player_x_hi
        sbc #$07
        cmp oam_ram_x,y
        bcc .face_left
.face_right
	lda #$22
        bne .set_face
.face_left
	lda #$20
.set_face
        jsr sprite_4_set_sprite
        ; palette
        lda #$02
        jsr sprite_4_set_palette
        
	jmp update_enemies_handler_next