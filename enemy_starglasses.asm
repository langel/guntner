
                
starglasses_spawn: subroutine
	; x is set by enemy spawner
        jsr get_next_random
        sta enemy_ram_ac,x ; animation counter
        lda #$c0
        sta enemy_ram_pc,x ; pattern counter
        lda #$f8
        sta enemy_ram_x,x ; x pos
        jsr get_next_random
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
	lda #$7a
	bne .frame_done
.frame1
	lda #$7c
.frame_done
        jsr sprite_4_set_sprite
        lda #$03
        jsr sprite_4_set_palette
.done
	jmp update_enemies_handler_next
