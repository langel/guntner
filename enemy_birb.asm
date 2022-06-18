


birb_spawn: subroutine
	; x is set by enemy spawner
	lda #birb_id
        sta enemy_ram_type,x 
        tay
        lda enemy_hitpoints_table,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        lda rng1
        sta enemy_ram_pc,x ; pattern counter
        lda rng2
        sta enemy_ram_ac,x ; animation counter
	jsr get_next_random
        lsr
        clc
        adc #$0c
        sta enemy_ram_y,x ; y pos
   	rts
        
           
        
  
;;;; HANDLING BIRB
        
birb_cycle: subroutine
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
.done
	jmp update_enemies_handler_next
        
        