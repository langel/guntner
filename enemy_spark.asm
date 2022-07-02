
spark_spawn: subroutine
	; x = slot in enemy ram
        ; y = boss slot in enemy ram
        ; stash boss slot in pattern counter
	lda #spark_id
        sta enemy_ram_type,x
        tay
        lda enemy_hitpoints_table,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_ac,x
        jsr get_next_random
        sta enemy_ram_x,x
        lda wtf
        and #$01
        bne .y_top
.y_bottom
	lda #4
        sta enemy_ram_y
        rts
.y_top
	lda #178
        sta enemy_ram_y
	rts


spark_cycle: subroutine
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
	inc enemy_ram_ac,x
        lda enemy_ram_ac,x
        and #$07
        bne .dont_reset_dir
        jsr get_next_random
        lsr
        and #%00000011
        sta enemy_ram_ex,x
        cmp #$03
        bne .reset_done
        lda rng2
        bpl .reset_done
        lda #$01
        sta enemy_ram_ex,x
.reset_done
.dont_reset_dir
        ; work out the direction
        lda enemy_ram_ex,x
        cmp #$00
        beq .go_up
        cmp #$01
        beq .go_right
        cmp #$02
        beq .go_down
.go_left
	dec enemy_ram_x,x
        bne .dir_done
.go_up
	dec enemy_ram_y,x
        bne .dir_done
        lda sprite_0_y
        sta enemy_ram_y,x
        bne .dir_done
.go_right
	inc enemy_ram_x,x
        bne .dir_done
.go_down
	inc enemy_ram_y,x
	lda enemy_ram_y,x
        cmp sprite_0_y
        bcc .dir_done
        lda #$00
        sta enemy_ram_y,x
.dir_done
	; attributes
        jsr get_next_random
        sta oam_ram_att,y
        ; sprite
        jsr get_next_random
        and #$03
        clc
        adc #$6c
        sta oam_ram_spr,y
        ; x and y pos
	lda enemy_ram_x,x
        sta oam_ram_x,y
        lda enemy_ram_y,x
        sta oam_ram_y,y
.done
	jmp update_enemies_handler_next