
lasso_spawn: subroutine
	; x is set by enemy spawner
	lda #lasso_id
        sta enemy_ram_type,x ; enemy type
        tay
        lda enemy_hitpoints_table,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_ac,x ; animation counter
        sta enemy_ram_pc,x ; pattern counter
   	rts
        
lariat_sine_table:
	.byte #16, #35, #55, #73, #93, #113, #129, #148
        
;;;; HANDLING maggs
lasso_cycle: subroutine
        
        ; x pos
        lda wtf
        and #$01
        bne .dont_advance
        lda oam_ram_x,y
        clc
        adc #$01
        sta oam_ram_x,y
        sta oam_ram_x+4,y
        sta oam_ram_x+8,y
        sta oam_ram_x+$c,y
.dont_advance

	; y pos
        inc enemy_ram_pc,x
        lda enemy_ram_pc,x
        sta temp01
        tax
        lda #159
        jsr sine_of_scale
        sta oam_ram_y,y
        clc
        adc #$08
        sta oam_ram_y+4,y
        sta collision_0_h 
        ; middle sprite
        ;lda #105
        lda wtf
        and #$07
        tax
        lda lariat_sine_table,x
        ldx temp01
        jsr sine_of_scale
        and #$fe
        sta temp02
        sec
        sbc #$08
        sta oam_ram_y+8,y
        ; top sprite
        lda temp02
        sta oam_ram_y+$c,y    
        ldx enemy_ram_offset
        
        ; collision
        lda #$00
        sta collision_0_y
        lda #$07
        sta collision_0_w
        jsr enemy_handle_damage_and_death
        
        ; sprites
        lda #$59
        sta oam_ram_spr,y
        lda #$69
        sta oam_ram_spr+4,y
        lda #$6a
        sta oam_ram_spr+8,y
        sta oam_ram_spr+$c,y
        
        ; palette & attributes
        lda #$02
        jsr sprite_4_set_palette
        
.done
	jmp update_enemies_handler_next
        
        
