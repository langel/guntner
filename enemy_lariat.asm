
lariat_spawn: subroutine
	; x is set by enemy spawner
	lda #$15
        sta enemy_ram_type,x ; enemy type
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_ac,x ; animation counter
        sta enemy_ram_pc,x ; pattern counter
        jsr get_oam_offset_from_slot_offset
        tya
        sta oam_ram_y,y ; y pos      
        clc
        adc #$08
        sta oam_ram_y+4,y
   	rts
        
    
        
;;;; HANDLING maggs
lariat_cycle: subroutine
        lda #$10
        sta collision_0_w
        lda #$05
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
        ; x pos
        lda wtf
        and #$01
        bne .dont_advance
        lda oam_ram_x,y
        clc
        adc #$01
        sta oam_ram_x,y
        sta oam_ram_x+4,y
.dont_advance
        
        lda #$58
        sta oam_ram_spr,y
        lda #$68
        sta oam_ram_spr+4,y
        
        lda #$02
        jsr enemy_set_palette
        sta oam_ram_att+4,y
.done
	jmp update_enemies_handler_next
