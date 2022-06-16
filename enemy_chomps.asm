

chomps_spawn: subroutine
	; x is set by enemy spawner
	lda #chomps_id
        sta enemy_ram_type,x 
        tay
        lda enemy_hitpoints_table,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_pc,x ; pattern counter
        sta enemy_ram_ac,x ; animation counter
        jsr enemy_spawn_random_y_pos
        sta enemy_ram_y,x ; y pos
   	rts
        
        
        
chomps_cycle: subroutine
        lda #$08
        sta collision_0_w
        lda #$05
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
        ; x movement
        inc enemy_ram_pc,x ; actualy x origin position
        inc enemy_ram_ac,x
        inc enemy_ram_ac,x
        lda wtf
        and #$01
        bne .no_extra_inc
        inc enemy_ram_ac,x
.no_extra_inc
        lda enemy_ram_ac,x
        tax
        lda sine_table,x
        lsr
        lsr
        ldx enemy_ram_offset
        clc
        adc enemy_ram_pc,x
        sta enemy_ram_x,x
        
        ; winder sprite
        lda enemy_ram_x,x
        sta oam_ram_x,y
        clc
        adc #$01
        sta oam_ram_x+4,y
        lda enemy_ram_y,x
        sta oam_ram_y,y
        sta oam_ram_y+4,y
        lda wtf
        lsr
        lsr
        and #$03
        clc
        adc #$34
        sta oam_ram_spr,y
        
        ; mouth sprite
        lda enemy_ram_ac,x
        clc
        adc #$d0
        cmp #$80
        bcs .not_closed
	lda #$38
        bne .sprite_done
.not_closed
        cmp #$a0
        bcs .half_open
	lda #$48
        bne .sprite_done
.half_open
	lda #$49
        ;bne .sprite_done
.sprite_done
        sta oam_ram_spr+4,y
        
.frame_done
        lda #$02
        jsr enemy_set_palette
        sta oam_ram_att+4,y
.done
	jmp update_enemies_handler_next