
                
starglasses_spawn: subroutine
	; x is set by enemy spawner
	lda #$04
        sta enemy_ram_type,x ; enemy type
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda rng0
        jsr NextRandom
        sta rng0
        sta enemy_ram_ac,x ; animation counter
        lda #$c0
        sta enemy_ram_pc,x ; pattern counter
        lda #$f8
        sta enemy_ram_x,x ; x pos
        lda rng0
        jsr NextRandom
        sta rng0
        lsr
        lsr
        clc
        adc #$18
        sta enemy_ram_y,x ; y pos
   	rts
        
           

;;; HANDLING STARGLASSES
starglasses_cycle: subroutine
        lda #$10
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
.x_decide_action
	; calc x
        lda enemy_ram_x,x
        cmp #$10
        beq .x_sine_pattern
        inc enemy_ram_x,x
        lda enemy_ram_x,x
        jsr sprite_4_set_x
        jmp .y_calc_pos
.x_sine_pattern
	; using pattern_counter for x sin
	inc enemy_ram_pc,x
	lda enemy_ram_pc,x
        tax
	lda sine_table,x
	lsr
	lsr
	ldx enemy_ram_offset
	clc
	adc enemy_ram_x,x
        jsr sprite_4_set_x
.y_calc_pos
	; using anim_counter for y sin
	inc enemy_ram_ac,x
	inc enemy_ram_ac,x
	; calc y
	ldx enemy_ram_offset
        lda enemy_ram_ac,x
        tax
	lda sine_table,x
	lsr
	lsr
	clc
	ldx enemy_ram_offset
	adc enemy_ram_y,x
        jsr sprite_4_set_y
	; tiles
	ldx enemy_ram_offset
	lda enemy_ram_ac,x
	and #$40
	beq .frame1
.frame0
	lda #$0c
        jsr sprite_4_set_sprite
	jmp .frame_done
.frame1
	lda #$0e
        jsr sprite_4_set_sprite
.frame_done
        lda #$03
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
.done
	jmp update_enemies_handler_next
