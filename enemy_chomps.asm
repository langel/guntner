

chomps_spawn: subroutine
	; x is set by enemy spawner
	lda #$0c
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
   	rts
        
           
        
  
;;;; HANDLING BIRB
        
chomps_cycle: subroutine
        lda #$08
        sta collision_0_w
        lda #$05
        sta collision_0_h
        jsr enemy_get_damage_this_frame
        cmp #$00
        bne .not_dead
.is_dead
	inc phase_kill_count
        lda enemy_ram_type,x
        jsr enemy_give_points    
        ; change it into crossbones!
        jsr sfx_enemy_death
        lda #$01
        sta enemy_ram_type,x
        jmp .done
.not_dead
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
	ldx enemy_ram_offset
        inc enemy_ram_x,x
        clc
        adc enemy_ram_x,x
        sta oam_ram_x,y
        
        ; set y position
        lda enemy_ram_y,x
        sta oam_ram_y,y
        
        ; current sprite
        lda enemy_ram_ac,x
        clc
        adc #$02
        sta enemy_ram_ac,x
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        clc 
        adc #$4a
        sta oam_ram_spr,y
.frame_done
        lda #$02
        jsr enemy_set_palette
.done
	jmp update_enemies_handler_next