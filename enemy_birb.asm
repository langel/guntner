


birb_spawn: subroutine
	; x is set by enemy spawner
	lda #$02
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        lda rng1
        jsr NextRandom
        sta rng1
        sta enemy_ram_pc,x ; pattern counter
        lda rng2
        jsr NextRandom
        sta rng2
        sta enemy_ram_ac,x ; animation counter
        lsr
        clc
        adc #$0c
        sta enemy_ram_y,x ; y pos
        clc
        txa
        lsr
        adc #$20
        sta enemy_ram_oam,x ; OAM ref  
   	rts
        
           
        
  
;;;; HANDLING BIRB
        
birb_cycle: subroutine
	ldx enemy_ram_offset
        ldy enemy_oam_offset
        lda oam_ram_x,y
        sta collision_0_x
        lda oam_ram_y,y
        sta collision_0_y
        lda #$08
        sta collision_0_w
        lda #$05
        sta collision_0_h
        jsr enemy_get_damage_this_frame_2
        cmp #$00
        bne .not_dead
.is_dead
	inc phase_kill_count
        lda enemy_ram_type,x
        jsr enemy_give_points    
        ; change it into crossbones!
        jsr apu_trigger_enemy_death
        lda #$01
	ldx enemy_ram_offset
        sta enemy_ram_type,x
        jmp .done
.not_dead
        ; update pattern
        inc enemy_ram_pc,x
        inc enemy_ram_pc,x
        
        ; set x position
        ; get x pattern position
        ; add it to base x position
        ; save that to OAM x position
        lda enemy_ram_pc,x
        tax
        lda sine_table,x
        lsr
        lsr
        lsr
	ldx enemy_ram_offset
        inc enemy_ram_x,x
        clc
        adc enemy_ram_x,x
        sta oam_ram_x,y
        
        ; set y position
        lda enemy_ram_pc,x
        clc 
        adc #$40
        tax
        lda sine_table,x
        lsr
        lsr
        lsr
	ldx enemy_ram_offset
        clc
        adc enemy_ram_y,x
        sta oam_ram_y,y
        
        ; current sprite
        lda enemy_ram_ac,x
        clc
        adc #$14
        sta enemy_ram_ac,x
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        clc 
        adc #$2c
        sta oam_ram_spr,y
.frame_done
        lda #$01
        jsr enemy_set_palette
        jmp .done
.done
	jmp update_enemies_handler_next
        
        