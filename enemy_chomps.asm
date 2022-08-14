

chomps_spawn: subroutine
	; x is set by enemy spawner
        lda #$c1
        sta enemy_ram_ac,x
        jsr get_oam_offset_from_slot_offset
        lda #$00
        sta oam_ram_x,y
   	rts
        
     
chomps_cycle: subroutine
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
        lda oam_ram_x,y
        cmp #$01
        bcs .dont_reset_y
        ; y
        jsr enemy_spawn_random_y_pos
        sta oam_ram_y,y
        sta oam_ram_y+4,y
.dont_reset_y
        
        ; x movement
        inc enemy_ram_pc,x ; actual x origin position
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
        ; x
        sta oam_ram_x,y
        clc
        adc #$01
        sta oam_ram_x+4,y
        
        ; winder sprite
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
	lda #$58
        bne .sprite_done
.not_closed
        cmp #$a0
        bcs .half_open
	lda #$68
        bne .sprite_done
.half_open
	lda #$78
.sprite_done
        sta oam_ram_spr+4,y
        
.frame_done
        lda #$01
        jsr enemy_set_palette
        sta oam_ram_att+4,y
.done
	jmp update_enemies_handler_next