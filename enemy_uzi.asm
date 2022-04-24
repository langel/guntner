
uzi_spawn: subroutine
	lda #$13
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        lda #$20
        sta enemy_ram_x,x
        lda #$30
        sta enemy_ram_ac,x
	rts
        
        
        
uzi_cycle: subroutine
; x pos
        lda enemy_ram_x,x
        sec
        sbc enemy_ram_ac,x
        jsr sprite_4_set_x
        lda enemy_ram_ac,x
        beq .kickback_done
        dec enemy_ram_ac,x
.kickback_done
; y pos
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
; sprite
        lda #$be
        jsr sprite_4_set_sprite
; palette
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
        ldx enemy_ram_offset
        lda enemy_ram_ac,x
        clc
        adc #$05 ; kickback in pixels
        sta enemy_ram_ac,x
        ; XXX makes for less repetitive patterns
        jsr get_next_random
        jsr get_next_random
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
        ; sprite
	lda #$14
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        ; x pos
        lda temp02
        clc
        adc #$0b
        sta enemy_ram_x,x
        ; y pos
        lda temp03
        clc
        adc #$03
        sta enemy_ram_y,x
        ; XXX trigger sfx?
        jsr sfx_shoot_bullet
.done
	rts
        
bullet_cycle: subroutine
	; check for player collision
        lda #$08
        sta collision_0_w
        lda #$04
        sta collision_0_h
        ; XXX might be redundant with dart code
        lda oam_ram_x,y
        sta collision_0_x
        lda oam_ram_y,y
        sta collision_0_y
        jsr player_collision_detect
        beq .no_collision
        lda #4
        sta player_damage
        jsr player_take_damage
        jmp .despawn
.no_collision
	lda wtf
        and #$01
        clc
        adc #$de
        sta oam_ram_spr,y
        lda enemy_ram_x,x
        adc #$03
        sta enemy_ram_x,x
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