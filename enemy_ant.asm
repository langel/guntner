
ant_spawn: subroutine
	; x is set by enemy spawner
        lda #$fc
        sta enemy_ram_x,x ; x pos
        lda #$00
        sta enemy_ram_ac,x ; animation counter
        txa
        lsr
        lsr
        lsr
        and #1
        beq .dash_ant
.ceiling_ant
	sta enemy_ram_ex,x
	lda #$03
        sta enemy_ram_y,x ; y ant pos
        lda #$0c
        sta enemy_ram_pc,x ; y dart origin
   	rts
.dash_ant
	sta enemy_ram_ex,x
        lda #$ad
        sta enemy_ram_y,x ; y ant pos
        sta enemy_ram_pc,x ; y dart origin
   	rts
        
        
ant_cycle: subroutine
        lda #$10
        sta collision_0_w
        lda #$10
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
	lda wtf
        lsr
        lsr
        and #$3f
        cmp #$37
        bcc .normal_walking
.stop_and_shoot
	; frames default to spazzing
        ; frames f0-f8 butt up
        ; frame f8 shoot dart
        ; frames f9-ff butt down
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
        sta dart_x_origin
        lda enemy_ram_pc,x
        sta dart_y_origin
        lda #$03
        sta dart_velocity
        lda #$00
        sta dart_sprite
        sta dart_dir_adjust
        jsr dart_spawn
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
        jsr sprite_4_set_palette
.done
	jmp update_enemies_handler_next
        
