
throber_spawn: subroutine
	; x is set by enemy spawner
        jsr get_oam_offset_from_ram_offset
        jsr enemy_spawn_random_y_pos
        sta oam_ram_y,y   ; y pos
        lda #$00
        sta oam_ram_x,y   ; x pos
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
        bne .dont_change_dir
.update_direction
        jsr enemy_get_direction_of_player
        sta enemy_ram_ex,x
.dont_change_dir
        inc enemy_ram_ac,x
.do_movement
	jsr arctang_enemy_update
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
        jsr sprite_4_set_y
        lda #$03
        jsr sprite_4_set_palette
	jmp update_enemies_handler_next
