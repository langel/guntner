
muya_spawn_y	EQM $b4
        
muya_spawn: subroutine
	jsr get_oam_offset_from_slot_offset
        jsr get_next_random
        lsr
        adc #$5c
        sta enemy_ram_x,x
        lda #muya_spawn_y
        sta oam_ram_y,y
   	rts
        
    
        
;;;; HANDLING MUYA
muya_cycle: subroutine
        lda #$08
        sta collision_0_w
        lda #$10
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
	; sprite
        lda #$58
        sta oam_ram_spr,y
        lda #$68
        sta oam_ram_spr+4,y
        
        ; x pos
        lda enemy_ram_x,x
      	sta oam_ram_x,y
      	sta oam_ram_x+4,y
        
        ; y pos
        ; XXX could reuse crossbones movement code here
        inc enemy_ram_ac,x
        lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        sta temp00
        lda oam_ram_y,y
        sec
        sbc temp00
        cmp sprite_0_y
        bcs .reset_y_pos
        sta oam_ram_y,y
        clc
        adc #$08
        sta oam_ram_y+4,y
        bne .reset_skip
.reset_y_pos
        lda #$00
        sta enemy_ram_ac,x
        lda #muya_spawn_y
        sta oam_ram_y,y
.reset_skip
        
        ; palette
        lda #$01
        jsr enemy_set_palette
        sta oam_ram_att+4,y
              
	jmp update_enemies_handler_next
        
        
