
muya_spawn_y	EQM $b4
        
muya_spawn: subroutine
	jsr get_oam_offset_from_slot_offset
        jsr get_next_random
        lsr
        adc #$70
      	sta oam_ram_x,y
      	sta oam_ram_x+4,y
        lda #muya_spawn_y
        sta oam_ram_y,y
   	rts
        
    
        
;;;; HANDLING MUYA
muya_cycle: subroutine
        lda #$08
        sta collision_0_w
        lda #$10
        sta collision_0_h
        ;jsr enemy_handle_damage_and_death
        
	; sprite
        lda #$58
        sta oam_ram_spr,y
        lda #$68
        sta oam_ram_spr+4,y
        
        ; reset check
        lda enemy_ram_ac,x
        cmp #$40
        bcc .dont_reset
        lda #$00
        sta enemy_ram_ac
        lda #muya_spawn_y
        sta oam_ram_y,y
.dont_reset
        
        ; y pos
        lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        sta temp00
        lda oam_ram_y,y
        sec
        sbc temp00
        sta oam_ram_y,y
        clc
        adc #$08
        sta oam_ram_y+4,y
        
        ; palette
        lda #$01
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        
        inc enemy_ram_ac,x
        
        
	jmp update_enemies_handler_next
        
