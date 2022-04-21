
throber_spawn: subroutine
	; x is set by enemy spawner
	lda #$12
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        jsr get_oam_offset_from_slot_offset
        lda #$40
        sta enemy_ram_x,x ; x pos
        sta oam_ram_x,y   ; x pos
        sta enemy_ram_pc,x ; pattern counter
        sta enemy_ram_ac,x ; animation counter
        sta enemy_ram_y,x ; y pos
        sta oam_ram_y,y   ; y pos
        lda #$00
        sta enemy_ram_ex,x
   	rts
        
throber_cycle: subroutine
	lda wtf
        lsr
        lsr
        and #$03
        asl
        clc
	adc #$40
        jsr sprite_4_set_sprite
        lda wtf
        lsr
        lsr
        lsr
        and #$07
        tax
        ;lda #<arctang_velocity_1.25
        lda arctang_velocities_lo,x
        sta arctang_velocity_lo
        ldx enemy_ram_offset
	jsr enemy_update_arctang_path
.dont_advance
        lda oam_ram_x,y
        jsr sprite_4_set_x
        lda oam_ram_y,y
        jsr sprite_4_set_y
        lda #$03
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
	jmp update_enemies_handler_next
