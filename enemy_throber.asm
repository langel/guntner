
throber_spawn: subroutine
	; x is set by enemy spawner
	lda #$12
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        jsr get_oam_offset_from_slot_offset
        lda #$42
        sta oam_ram_y,y   ; y pos
        lda #$00
        sta oam_ram_x,y   ; x pos
        sta enemy_ram_pc,x ; pattern counter
        sta enemy_ram_ac,x ; animation counter
        sta enemy_ram_ex,x
   	rts
        
        
throber_cycle: subroutine
        lda #$10
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
	inc enemy_ram_pc,x
        lda enemy_ram_pc,x
        lsr
        lsr
        lsr
        and #$07
        tax
        lda arctang_velocities_lo,x
        sta arctang_velocity_lo
        txa
        ldx enemy_ram_offset
        cmp #$05
        bcc .do_movement
        cmp #$05
        bne .dont_change_dir
        jsr enemy_get_direction_of_player
        sta enemy_ram_ex,x
.dont_change_dir
        inc enemy_ram_ac,x
.do_movement
	jsr enemy_update_arctang_path
.dont_advance
	lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        and #$03
        asl
        clc
	adc #$40
        jsr sprite_4_set_sprite
        lda oam_ram_x,y
        jsr sprite_4_set_x
        lda oam_ram_y,y
        jsr enemy_fix_y_visible
        sta oam_ram_y,y
.y_viewable
        jsr sprite_4_set_y
        lda #$03
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
	jmp update_enemies_handler_next
