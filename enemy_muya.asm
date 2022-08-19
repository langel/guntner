
muya_spawn_y	EQM $b4
        
muya_spawn: subroutine
	jsr get_oam_offset_from_ram_offset
        lda #muya_spawn_y+$10
        sta oam_ram_y,y
   	rts
        
    
        
;;;; HANDLING MUYA
muya_cycle: subroutine
        lda #$08
        sta collision_0_w
        lda #$10
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
        ; x pos
        lda oam_ram_x,y
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
        cmp #sprite_0_y
        bcs .reset_x_and_y_pos
        sta oam_ram_y,y
        clc
        adc #$08
        sta oam_ram_y+4,y
        bne .reset_skip
.reset_x_and_y_pos
	; x
        jsr get_next_random
        lsr
        adc #$5c
        sta oam_ram_x,y
        ; y
        lda #muya_spawn_y
        sta oam_ram_y,y
        ; reset animation counter
        lda #$00
        sta enemy_ram_ac,x
.reset_skip
        
	; sprite
        lda #$64
        sta oam_ram_spr,y
        lda #$74
        sta oam_ram_spr+4,y
        
        ; palette
        lda #$02
        jsr enemy_set_palette
        sta oam_ram_att+4,y
              
	jmp update_enemies_handler_next
        
        
