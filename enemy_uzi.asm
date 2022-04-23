
uzi_spawn: subroutine
	lda #$13
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        lda #$10
        sta enemy_ram_x,x
	rts
        
        
        
uzi_cycle: subroutine
	inc enemy_ram_pc,x
        lda enemy_ram_pc,x
        tax
        lda sine_table,x
        lsr
        clc
        adc #$18
        ldx enemy_ram_offset
        sta enemy_ram_y,x
        jsr sprite_4_set_y
        lda enemy_ram_x,x
        jsr sprite_4_set_x
        lda enemy_ram_ex,x
        lda #$be
        jsr sprite_4_set_sprite
	lda #$01
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
.bullet_spawn
	lda rng0
        lsr
        and #$0f
        bne .dont_shoot
        jsr bullet_spawn
.dont_shoot
	jmp update_enemies_handler_next
        
     
     
bullet_spawn: subroutine
	lda oam_ram_x,y
        sta temp02
        lda oam_ram_y,y
        sta temp03
	jsr get_enemy_slot_1_sprite
        cmp #$ff
        beq .done
	lda #$14
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        lda temp02
        clc
        adc #$0d
        sta enemy_ram_x,x
        lda temp03
        clc
        adc #$03
        sta enemy_ram_y,x
.done
	rts
        
bullet_cycle: subroutine
	lda wtf
        and #$01
        clc
        adc #$de
        sta oam_ram_spr,y
        inc enemy_ram_x,x
        inc enemy_ram_x,x
        inc enemy_ram_x,x
        lda enemy_ram_x,x
        cmp #$08
        bcs .dont_despawn
.despawn
	jsr enemy_death
.dont_despawn
        sta oam_ram_x,y
        lda enemy_ram_y,x
        sta oam_ram_y,y
	lda #$01
        jsr enemy_set_palette
	jmp update_enemies_handler_next