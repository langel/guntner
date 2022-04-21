zigzag_spawn: subroutine
	; x is set by enemy spawner
	lda #$0b
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_pc,x ; pattern counter
        sta enemy_ram_ac,x ; animation counter
        jsr get_next_random
        lsr
        and #%00000011
        cmp #$00
        beq .spawn_left
        cmp #$01
        beq .spawn_top
        cmp #$02
        beq .spawn_right
.spawn_bottom
	lda rng0
        sta enemy_ram_x,x
        lda #$b0
        sta enemy_ram_y,x
        lda #$00
        sta enemy_ram_ex,x
        jmp .dir_picked
.spawn_left
        lda #$00
        sta enemy_ram_x,x
	lda rng0
        sta enemy_ram_y,x
        lda #$01
        sta enemy_ram_ex,x
        jmp .dir_picked
.spawn_top
	lda rng0
        sta enemy_ram_x,x
        lda #$00
        sta enemy_ram_y,x
        lda #$02
        sta enemy_ram_ex,x
        jmp .dir_picked
.spawn_right
        lda #$f0
        sta enemy_ram_x,x
	lda rng0
        sta enemy_ram_y,x
        lda #$03
        sta enemy_ram_ex,x
.dir_picked
	rts


zigzag_cycle: subroutine
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
	; animation
        inc enemy_ram_ac,x
        lda enemy_ram_ac,x
        cmp #$20
        bne .dont_reset_ac
        ; reset ac and pick new direction
        lda #$00
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
        inc enemy_ram_ex,x
        lda enemy_ram_ex,x
        cmp #$05
        bne .ac_reset_done
        lda #$00
        sta enemy_ram_ex,x
        jmp .ac_reset_done
.dir_sub
        dec enemy_ram_ex,x
        lda enemy_ram_ex,x
        cmp #$ff
        bne .ac_reset_done
        lda #$00
        sta enemy_ram_ex,x
.ac_reset_done
.dont_reset_ac
        lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        clc
        adc #$5c ; base sprite tile
	ldx enemy_ram_offset
        ldy enemy_oam_offset
        sta oam_ram_spr,y
        ; work out the direction
        lda enemy_ram_ex,x
        cmp #$00
        beq .go_right_up
        cmp #$01
        beq .go_right_down
        cmp #$02
        beq .go_left_down
.go_left_up
	dec enemy_ram_x,x
        dec enemy_ram_y,x
        lda #$d1
        jsr enemy_set_palette
        bcc .go_done
.go_right_up
	inc enemy_ram_x,x
        dec enemy_ram_y,x
        lda #$a1
        jsr enemy_set_palette
        bcc .go_done
.go_right_down
	inc enemy_ram_x,x
        inc enemy_ram_y,x
        lda #$21
        jsr enemy_set_palette
        bcc .go_done
.go_left_down
        dec enemy_ram_x,x
        inc enemy_ram_y,x
        lda #$61
        jsr enemy_set_palette
.go_done
        lda enemy_ram_x,x
        sta oam_ram_x,y
        lda enemy_ram_y,x
        jsr enemy_fix_y_visible
        sta enemy_ram_y,x
        sta oam_ram_y,y       
.done
	jmp update_enemies_handler_next