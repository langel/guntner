; powerups always spawn from starglasses
        
powerup_init_velocity_and_hp:
	lda #$7f
        sta enemy_ram_pc,x
        lda #$02
        sta enemy_ram_hp,x
        rts
        
powerup_from_starglasses:
	ldx enemy_ram_offset
        ldy enemy_oam_offset
	lda #$06
        sta enemy_ram_type,x
        lda oam_ram_x,y
        sta enemy_ram_x,x
        lda oam_ram_y,y
        sta enemy_ram_y,x
       	jsr powerup_init_velocity_and_hp
	rts
      
        
powerups_cycle: subroutine
        
	ldx enemy_ram_offset
        ldy enemy_oam_offset
        ; sprite
        lda #$2b
        sta $0201,y
        ; palette
	lda #$03
        sta $0202,y
        ; x pos
        lda enemy_ram_pc,x
        cmp #$80
        bcc .move_right
.move_left
	lda enemy_ram_ac,x
        clc
        adc enemy_ram_pc,x
        bcc .not1
        dec enemy_ram_x,x
        bne .no_hp1 ; don't increase hp
        inc enemy_ram_hp,x
.no_hp1
        clc
.not1        
        adc enemy_ram_pc,x
        bcc .not2
        dec enemy_ram_x,x
        bne .no_hp2 ; don't increase hp
        inc enemy_ram_hp,x
.no_hp2
        clc
.not2      
        adc enemy_ram_pc,x
        bcc .not3
        dec enemy_ram_x,x
        bne .no_hp3 ; don't increase hp
        inc enemy_ram_hp,x
.no_hp3
        clc
.not3      
        sta enemy_ram_ac,x
        dec enemy_ram_pc,x
        jmp .move_done
.move_right
	cmp #$00
        beq .right_max
        cmp #$72
        bcc .right_speed1
        dec enemy_ram_pc,x
        jmp .move_done
.right_speed1
	cmp #$62
        bcc .right_speed2
	inc enemy_ram_x,x
        bne .no_hp6
        dec enemy_ram_hp,x
.no_hp6
        dec enemy_ram_pc,x
        jmp .move_done
.right_speed2
	cmp #$50
        bcc .right_speed3
	inc enemy_ram_x,x
        bne .no_hp7
        dec enemy_ram_hp,x
.no_hp7
	inc enemy_ram_x,x
        bne .no_hp8
        dec enemy_ram_hp,x
.no_hp8
        dec enemy_ram_pc,x
        jmp .move_done
.right_speed3
	cmp #$3a
        bcc .right_set_max
	inc enemy_ram_x,x
        bne .no_hp9
        dec enemy_ram_hp,x
.no_hp9
	inc enemy_ram_x,x
        bne .no_hpa
        dec enemy_ram_hp,x
.no_hpa
	inc enemy_ram_x,x
        bne .no_hpb
        dec enemy_ram_hp,x
.no_hpb
        dec enemy_ram_pc,x
        jmp .move_done
.right_set_max
	lda #$00
        sta enemy_ram_pc,x
.right_max
	inc enemy_ram_x,x
	inc enemy_ram_x,x
	inc enemy_ram_x,x
	inc enemy_ram_x,x
	lda enemy_ram_x,x
        cmp #$fc
        bcc .move_done
        dec enemy_ram_hp,x
.move_done
.despawn_check
	lda enemy_ram_hp,x
        cmp #$00
        bne .update_oam_data
 	;; XXX needs its own sfx
        jsr apu_trigger_enemy_death
        jsr enemy_death
.update_oam_data
        lda enemy_ram_x,x
	sta collision_0_x
        sta $0203,y
        ; y pos
        lda enemy_ram_y,x
	sta collision_0_y
        sta $0200,y
        ; dim for collision
        lda #$06
        sta collision_0_w
        lda #$08
        sta collision_0_h
        jsr player_bullet_collision_handler
	cmp #$00
        beq .no_bullet_collision
        lda #$ff
        sta enemy_ram_pc,x
.no_bullet_collision
        ; XXX need to decouple player collision detection from damage
        ; put player info into collision detector
	lda player_x_hi
        sta collision_1_x
        lda player_y_hi
        clc
        adc #$02
        sta collision_1_y
        lda #$10
        sta collision_1_w
        lda #$06
        sta collision_1_h
        jsr detect_collision
        cmp #$00
        beq .done
.despawn_powerup
        jsr enemy_death
        lda player_health
        clc
        adc #$80
        sta player_health
        bcc .done
        lda #$ff
        sta player_health
.done   
	jmp update_enemies_handler_next
        
        