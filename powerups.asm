
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
        lda #$0
        sta enemy_ram_x,x
        lda rng0
        jsr NextRandom
        sta rng0
        tay
        lda game_height_scale,y
        lda #$20
        ldy enemy_ram_oam,x
        sta $0200,y
       
	rts
      
        
powerups_cycle: subroutine
        
	ldx enemy_handler_pos
        ldy enemy_temp_oam_x
        lda #$c8
        sta $0201,y
        lda $0200,y
	sta collision_0_y
        sta enemy_ram_y,x
        lda $0203,y
        sta enemy_ram_x,x
	inc enemy_ram_x,x
        lda enemy_ram_x,x
	sta collision_0_x
        sta $0203,y
        lda #$08
        sta collision_0_w
        sta collision_0_h
        ;jsr player_bullet_collision_handler
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
        
        

;crossbones_cycle: subroutine
	ldx enemy_handler_pos
        inc ENEMY_RAM+5,x
        lda ENEMY_RAM+5,x
        lsr
        lsr
        lsr
        sta ENEMY_RAM+3,x
        tay
        ldy enemy_temp_oam_x
        lda $0200,y
        sec
        sbc ENEMY_RAM+3,x
        bcc .crossbones_death
        sta $0200,y
        lda #$0b
        sta $0201,y
        lda #$03
        sta $0202,y
        jmp .crossbones_done
.crossbones_death
        jsr enemy_death
.crossbones_done
	jmp update_enemies_handler_next