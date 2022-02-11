
spark_spawn: subroutine
	; x = slot in enemy ram
        ; y = boss slot in enemy ram
        ; stash boss slot in pattern counter
	lda #$0d
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        jsr get_next_random
        and #%01111111
        sta enemy_ram_x,x
        jsr get_next_random
        and #%01111111
        sta enemy_ram_y,x 
        lsr
        and #%00000011
        sta enemy_ram_ex,x
        lda #$00
        sta enemy_ram_ac,x
	rts

spark_cycle: subroutine
        lda #$08
        sta collision_0_w
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
	inc enemy_ram_ac,x
        lda #$07
        cmp enemy_ram_ac,x
        bne .dont_reset_dir
        lda #$00
        sta enemy_ram_ac,x
        jsr get_next_random
        lsr
        and #%00000011
        sta enemy_ram_ex,x
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
        jmp .dir_done
.go_right
	inc enemy_ram_x,x
        jmp .dir_done
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
        lsr
        lsr
        and #%00000011
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