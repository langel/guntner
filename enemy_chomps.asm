

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
        
        ; update pattern
        inc enemy_ram_pc,x
        inc enemy_ram_pc,x
        
        ; set x position
        ; get x pattern position
        ; add it to base x position
        lda enemy_ram_pc,x
        tax
        lda sine_table,x
        lsr
        lsr
        lsr
        sta temp00
	ldx enemy_ram_offset
        inc enemy_ram_x,x
        clc
        adc enemy_ram_x,x
        sta oam_ram_x+4,y
        sec
        sbc #$01
        sta oam_ram_x,y
        
        ; set y position
        lda enemy_ram_y,x
        sta oam_ram_y,y
        sta oam_ram_y+4,y
        
        ; winder sprite
        lda wtf
        lsr
        lsr
        and #$03
        clc
        adc #$cc
        sta oam_ram_spr,y
        ; mouth sprite
        lda enemy_ram_ac,x
        clc
        adc #$02
        sta enemy_ram_ac,x
        lda temp00
        lsr
        lsr
        lsr
        clc 
        adc #$bc
        sta oam_ram_spr+4,y
.frame_done
        lda #$02
        jsr enemy_set_palette
        sta oam_ram_att+4,y
.done
	jmp update_enemies_handler_next