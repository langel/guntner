

boss_moufs_spawn: subroutine
        lda #do_nothing_id
        sta $03c0
        sta $03c8
        lda #$40
        sta enemy_ram_x,x
        sta enemy_ram_y,x
	rts
        
sprite_3_set_sprite: subroutine
	; a = left tile id
        ; y = oam ram offset
	sta oam_ram_spr,y
        clc
        adc #$01
	sta oam_ram_spr+$04,y
        adc #$01
	sta oam_ram_spr+$08,y
        rts
        
sprite_3_set_x: subroutine
	; a = x pos
        ; y = oam ram offset
	sta oam_ram_x,y
	clc
	adc #$08
	sta oam_ram_x+$04,y
	adc #$08
	sta oam_ram_x+$08,y
	adc #$08
	sta oam_ram_x+$0c,y
	rts
        
sprite_3_set_y: subroutine
	; a = y pos
        ; y = oam ram offset
	sta oam_ram_y,y
	sta oam_ram_y+$04,y
	sta oam_ram_y+$08,y
	rts
  
  
boss_moufs_cycle: subroutine

	lda #$86
        jsr sprite_3_set_sprite
	lda #$40
        jsr sprite_3_set_x
	lda #$40
        jsr sprite_3_set_y
        lda #$01
        jsr sprite_4_set_palette
        
        tya
        clc
        adc #$10
        tay
        
	lda #$96
        jsr sprite_3_set_sprite
	lda #$40
        jsr sprite_3_set_x
	lda #$48
        jsr sprite_3_set_y
        lda #$01
        jsr sprite_4_set_palette
        
        tya
        clc
        adc #$10
        tay
        
	lda #$a6
        jsr sprite_3_set_sprite
	lda #$40
        jsr sprite_3_set_x
	lda #$50
        jsr sprite_3_set_y
        lda #$01
        jsr sprite_4_set_palette
        
        tya
        clc
        adc #$10
        tay
        
	lda #$b6
        jsr sprite_3_set_sprite
	lda #$40
        jsr sprite_3_set_x
	lda #$58
        jsr sprite_3_set_y
        lda #$01
        jsr sprite_4_set_palette
        
	
	jmp update_enemies_handler_next
