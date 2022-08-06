
; boss_x : x origin of sine pattern
; boss_y : y origin of sine pattern
; state_v0 : bottom lip position
; state_v1 : bottom lip animation counter
; state_v2 : sprites y pos temp

boss_moufs_spawn: subroutine
        lda #do_nothing_id
        sta $03c0
        sta $03c8
        lda #$40
        sta enemy_ram_x,x
        sta enemy_ram_y,x
        lda #$04
        sta boss_x
        lda #$08
        sta boss_y
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

	lda #$40
        sta enemy_ram_x,x
        sta enemy_ram_y,x
        sta state_v2
        
        inc state_v1

	lda #$86
        jsr sprite_3_set_sprite
	lda enemy_ram_x,x
        jsr sprite_3_set_x
	lda state_v2
        jsr sprite_3_set_y
        lda #$01
        jsr sprite_4_set_palette
        
        ldy #$c0
        
        lda state_v2
        adc #$08
        sta state_v2
        
	lda #$96
        jsr sprite_3_set_sprite
	lda enemy_ram_x,x
        jsr sprite_3_set_x
	lda state_v2
        jsr sprite_3_set_y
        lda #$01
        jsr sprite_4_set_palette
        
        ldy #$e0
        
        lda state_v2
        adc #$08
        sta state_v2
        
	lda #$a6
        jsr sprite_3_set_sprite
	lda enemy_ram_x,x
        jsr sprite_3_set_x
	lda state_v2
        jsr sprite_3_set_y
        lda #$01
        jsr sprite_4_set_palette
        
        ldy #$d0
        
        lda state_v2
        adc state_v1
        sta state_v2
        
	lda #$b6
        jsr sprite_3_set_sprite
        ; x
	lda #$40
        jsr sprite_3_set_x
        ; y
	lda state_v2
        jsr sprite_3_set_y
        ; palette
        lda #$01
        jsr sprite_4_set_palette
        
	
	jmp update_enemies_handler_next
