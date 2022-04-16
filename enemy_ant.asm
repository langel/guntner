
ant_spawn: subroutine
	; x is set by enemy spawner
	lda #$11
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$20
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_pc,x ; pattern counter
        sta enemy_ram_ac,x ; animation counter
        txa
        lsr
        lsr
        lsr
        and #1
        beq .ceiling_ant
.dash_ant
	sta enemy_ram_ex,x
	lda #$06
        sta enemy_ram_y,x ; y pos
   	rts
.ceiling_ant
	sta enemy_ram_ex,x
        lda #$a7
        sta enemy_ram_y,x ; y pos
   	rts
        
ant_cycle: subroutine
	lda wtf
        lsr
        lsr
        and #$03
        asl
        clc
	adc #$e0
        sta temp00
        lda wtf
        and #$03
        bne .dont_advance
        inc enemy_ram_x,x
.dont_advance
        lda enemy_ram_x,x
        jsr sprite_4_set_x
        lda enemy_ram_y,x
        jsr sprite_4_set_y
        lda enemy_ram_ex,x
        bne .ceiling_ant
.dash_ant
	lda temp00
        jsr sprite_4_set_sprite
	lda #$01
        bne .ant_pos_done
.ceiling_ant
	lda temp00
        jsr sprite_4_set_sprite_flip
        lda #$81
.ant_pos_done
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
.dart_fire
	lda wtf
        and #$3f
        bne .done
        lda enemy_ram_x,x
        sta collision_0_x
        lda enemy_ram_y,x
        sta collision_0_y
        jsr dart_spawn
.done
	jmp update_enemies_handler_next
        
