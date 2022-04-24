
ant_spawn: subroutine
	; x is set by enemy spawner
	lda #$11
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$f7
        sta enemy_ram_x,x ; x pos
        lda #$00
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
        sta enemy_ram_y,x ; y ant pos
        lda #$0e
        sta enemy_ram_pc,x ; y dart origin
   	rts
.ceiling_ant
	sta enemy_ram_ex,x
        lda #$a7
        sta enemy_ram_y,x ; y ant pos
        sta enemy_ram_pc,x ; y dart origin
   	rts
        
        
ant_cycle: subroutine
	lda wtf
        lsr
        lsr
        and #$3f
        cmp #$37
        bcc .normal_walking
.stop_and_shoot
	; frames default to spazzing
        ; frames f0-f5 butt up
        ; frame f5 shoot dart
        ; frames f6-ff butt down
	lda wtf
        cmp #$f9
        bcs .butt_down
        cmp #$f8
        bcs .dart_fire
        cmp #$f0
        bcs .butt_up
.butt_shake
        lsr
        and #$01
        asl
        clc
        adc #$e8
        sta enemy_ram_ac,x
        bne .dont_advance
.butt_up
	lda #$ea
        sta enemy_ram_ac,x
        bne .dont_advance
.dart_fire
        lda enemy_ram_x,x
        sta collision_0_x
        lda enemy_ram_pc,x
        sta collision_0_y
        jsr dart_spawn
        ldx enemy_ram_offset
        ldy enemy_oam_offset
        bne .dont_advance
.butt_down
	lda #$e8
        sta enemy_ram_ac,x
        bne .dont_advance
        
.normal_walking
        and #$03
        asl
        clc
	adc #$e0
        sta enemy_ram_ac,x
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
	lda enemy_ram_ac,x
        jsr sprite_4_set_sprite
	lda #$01
        bne .ant_pos_done
.ceiling_ant
	lda enemy_ram_ac,x
        jsr sprite_4_set_sprite_flip
        lda #$81
.ant_pos_done
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
.done
	jmp update_enemies_handler_next
        
