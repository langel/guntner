

        
        
maggs_spawn: subroutine
	; x is set by enemy spawner
	lda #$03
        sta enemy_ram_type,x ; enemy type
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_ac,x ; animation counter
        lda rng0
        jsr NextRandom
        sta rng0
        sta enemy_ram_pc,x ; pattern counter
        tay
        lda game_height_scale,y
        sta enemy_ram_y,x ; y pos      
   	rts
        
    
        
;;;; HANDLING maggs
maggs_cycle: subroutine
        lda #$10
        sta collision_0_w
        lda #$05
        sta collision_0_h
        jsr enemy_get_damage_this_frame
        cmp #$00
        bne .not_dead
.is_dead
	lda #$f0
        ldy enemy_oam_offset
        sta oam_ram_y+4,y
	inc phase_kill_count
        lda enemy_ram_type,x
        jsr enemy_give_points    
        ; change it into crossbones!
        jsr sfx_enemy_death
        lda #$01
	ldx enemy_ram_offset
        sta enemy_ram_type,x
        jmp .done
.not_dead
	; sprite
        lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        lsr
        asl
        clc
        adc #$3c
	ldy enemy_oam_offset
        sta oam_ram_spr,y
        adc #$01
        sta oam_ram_spr+4,y
        
        ; x pos
        lda enemy_ram_x,x
        sta oam_ram_x,y
        clc
        adc #$08
        sta oam_ram_x+4,y
        
        ; y pos
	ldx enemy_ram_offset
        lda enemy_ram_pc,x
        lsr
        tay
        lda sine_4bit,y
        clc
        adc enemy_ram_y,x
	ldy enemy_oam_offset
        sta oam_ram_y,y
        sta oam_ram_y+4,y
        
        ; update pattern
        inc enemy_ram_pc,x
        inc enemy_ram_pc,x
        ; move forward
        inc enemy_ram_x,x
        ; update animation
        lda enemy_ram_ac,x
        cmp #$00
        bne .maggs_frame
        lda #$20
        sta enemy_ram_ac,x
.maggs_frame
        dec enemy_ram_ac,x
        
        lda #$02
        jsr enemy_set_palette
        sta oam_ram_att+4,y
.done
	jmp update_enemies_handler_next
        