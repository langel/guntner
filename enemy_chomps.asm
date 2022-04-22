

chomps_spawn: subroutine
	; x is set by enemy spawner
	lda #$0c
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
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
        inc enemy_ram_pc,x
        inc enemy_ram_ac,x
        inc enemy_ram_ac,x
        lda enemy_ram_ac,x
        tax
        lda sine_table,x
        sta temp00
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
        adc #$cc
        sta oam_ram_spr,y
        
        ; mouth sprite
        lda enemy_ram_pc,x
        clc
        adc #$20
        asl
        tax
        lda sine_table,x
        ldx enemy_ram_offset
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$bc
        sta oam_ram_spr+4,y
        
        
        bne .frame_done
        
        
        clc 
        adc #$bc
        sta oam_ram_spr+4,y
        
.frame_done
        lda #$02
        jsr enemy_set_palette
        sta oam_ram_att+4,y
.done
	jmp update_enemies_handler_next