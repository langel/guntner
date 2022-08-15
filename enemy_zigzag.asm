; pattern counter holds direction index 0..3
zigzag_dir_table:
	;     r/u   l/u   l/d   r/d
	byte #$03, #$09, #$0f, #$15
zigzag_att_table:
	;     r/u   l/u   l/d   r/d
        byte #$83, #$c3, #$43, #$03


zigzag_spawn: subroutine
        ; set direction
        jsr get_next_random
        lsr
        and #$03
        sta enemy_ram_pc,x
        tax
        lda zigzag_dir_table,x
        ldx enemy_ram_offset
        sta enemy_ram_ex,x
        ; set position
        jmp enemy_spawn_set_x_y_rng


zigzag_cycle: subroutine
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        lda wtf
        and #$03
        bne .dont_reset_ac
	; animation
        dec enemy_ram_ac,x
        bpl .dont_reset_ac
        ; reset ac and pick new direction
        lda #$05
        sta enemy_ram_ac,x
        ; get range 0..2 from 8bit value
        jsr get_next_random
        lsr
        clc
        adc rng0
        and #$80
        rol
        rol ; should have a value between 0 and 2 here
        cmp #$02
        beq .dir_sub
        cmp #$01
        beq .dir_add
.dir_same
	jmp .ac_reset_done
.dir_add
	inc enemy_ram_pc,x
        jmp .ac_reset_done
.dir_sub
	dec enemy_ram_pc,x
.ac_reset_done
	lda enemy_ram_pc,x
        and #$03
        tay
        lda zigzag_dir_table,y
        sta enemy_ram_ex,x
        ldy enemy_oam_offset
.dont_reset_ac
        ; set sprite
        lda enemy_ram_ac,x
        clc
        adc #$5a ; base sprite tile
        sta oam_ram_spr,y
        
        ; work out the direction
        lda #<arctang_velocity_1.25
        sta arctang_velocity_lo
	jsr arctang_enemy_update
        
        lda enemy_ram_pc,x
        and #$03
        tay
        lda zigzag_att_table,y
        ldy enemy_oam_offset
        jsr enemy_set_palette
        
	jmp update_enemies_handler_next