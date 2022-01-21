
powerup_spawn:
        ; spawn powerup
	; x is set by enemy spawner
	lda #$06
        sta enemy_ram_type,x
        lda #$01
        sta enemy_ram_hp,x
        ; set OAM offset
        clc
        txa
        lsr
        adc #$20
        sta enemy_ram_oam,x ; OAM ref 
        ; x pos
        lda #$0
        sta enemy_ram_x,x
        ; y pos
        lda rng0
        jsr NextRandom
        sta rng0
        tay
        lda game_height_scale,y
        sta enemy_ram_y,x
        lda #$20
        ldy enemy_ram_oam,x
        sta $0200,y
        
powerup_init_velocity:
	lda #$7f
        sta enemy_ram_pc,x
        rts
        
powerup_from_starglasses:
	lda #$06
        sta enemy_ram_type,x
        ldy enemy_ram_oam,x
        lda $0203,y
        sta enemy_ram_x,x
        lda $0200,y
        sta enemy_ram_y,x
       	jsr powerup_init_velocity
	rts
      
        
powerups_cycle: subroutine
        
	ldx enemy_handler_pos
        ldy enemy_ram_oam,x
        ; sprite
        lda #$c8
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
        clc
.not1        
        adc enemy_ram_pc,x
        bcc .not2
        dec enemy_ram_x,x
        clc
.not2      
        adc enemy_ram_pc,x
        bcc .not3
        dec enemy_ram_x,x
        clc
.not3      
        sta enemy_ram_ac,x
        dec enemy_ram_pc,x
        jmp .move_done
.move_right
	inc enemy_ram_x,x
.move_done
        lda enemy_ram_x,x
	sta collision_0_x
        sta $0203,y
        ; y pos
        lda enemy_ram_y,x
	sta collision_0_y
        sta $0200,y
        ; dim for collision
        lda #$08
        sta collision_0_w
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
        
        