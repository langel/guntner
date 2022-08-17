
uzi_spawn: subroutine
        lda #$20
        sta enemy_ram_x,x
        lda #$24
        sta enemy_ram_ac,x
	rts
        
        
        
uzi_cycle: subroutine
        lda #$10
        sta collision_0_w
        lda #$10
        sta collision_0_h
        jsr enemy_handle_damage_and_death
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
        lda #$ec
        jsr sprite_4_set_sprite
; palette
	lda #$01
        jsr sprite_4_set_palette
.bullet_spawn
	lda rng0
        lsr
        and #$07
        bne .dont_shoot
        jsr bullet_spawn  
        ; makes for less repetitive patterns
        jsr get_next_random
        jsr get_next_random
.dont_shoot
	jmp update_enemies_handler_next
        
     
     
bullet_spawn: subroutine
	lda oam_ram_x,y
        sta temp02
        lda oam_ram_y,y
        sta temp03
        jsr get_enemy_slot_next
        cpx #$ff
        beq .done
        ; sprite
	lda #bullet_id
        sta enemy_ram_type,x
        tay
        lda enemy_hitpoints_table,y
        sta enemy_ram_hp,x
        ; load y register
        jsr get_oam_offset_from_slot_offset
        ; x pos
        lda temp02
        clc
        adc #$0b
        sta oam_ram_x,y
        ; y pos
        lda temp03
        clc
        adc #$03
        sta oam_ram_y,y
        ; animate uzi kickback
        ldx enemy_ram_offset
        lda enemy_ram_ac,x
        clc
        adc #$05 ; kickback in pixels
        sta enemy_ram_ac,x
        ; trigger sfx
        jsr sfx_shoot_bullet
.done
	rts
        
bullet_cycle: subroutine
        lda #$08
        sta collision_0_w
        lda #$04
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        ; animate gleam
	lda wtf
        lsr
        lsr
        and #$01
        clc
        adc #$ee
        sta oam_ram_spr,y
        ; move to the right
        lda oam_ram_x,y
        adc #$03
        ; despawn check
        cmp #$04
        bcs .dont_despawn
.despawn
	jsr enemy_clear
        jmp .done
.dont_despawn
        sta oam_ram_x,y
	lda #$01
        jsr enemy_set_palette
.done
	jmp update_enemies_handler_next