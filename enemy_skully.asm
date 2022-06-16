
                    
skully_spawn: subroutine
	; x is set by enemy spawner
	lda #skully_id
        sta enemy_ram_type,x ; enemy type
        tay
        lda enemy_hitpoints_table,y
        sta enemy_ram_hp,x 
        lda rng0
        sta enemy_ram_ac,x ; animation counter
        lda #$00
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_pc,x ; pattern counter
        jsr enemy_spawn_random_y_pos
        sta enemy_ram_y,x ; y pos
   	rts



;;;; HANDLING SKULLY
skully_cycle: subroutine
        lda #$10
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
        ldx enemy_ram_offset
        ldy enemy_oam_offset
        lda #$01 ; set mirror flag
        sta enemy_ram_ex,x
        ; let's find what frame we're on
        lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        lsr
        lsr
        asl
        ; accumulator is now in 0..7 range except x2
        cmp #$0a
        beq .skully_sprite_5
        cmp #$0c
        beq .skully_sprite_6
        cmp #$0e
        beq .skully_sprite_7
.skully_normal_frames
	jsr sprite_4_set_sprite
	lda #$00 ; unset mirror flag
        sta enemy_ram_ex,x
        jmp .skully_sprites_done
.skully_sprite_5
	lda #$06
        jsr sprite_4_set_sprite_mirror
	jmp .skully_sprites_done
.skully_sprite_6
	lda #$04
        jsr sprite_4_set_sprite_mirror
	jmp .skully_sprites_done
.skully_sprite_7
	lda #$02
        jsr sprite_4_set_sprite_mirror
.skully_sprites_done
        ; x pos
        lda enemy_ram_x,x
        jsr sprite_4_set_x
        ; y pos
        lda enemy_ram_y,x
        jsr sprite_4_set_y
.skully_frame
	; update spinning counter
	lda #$07
        clc
        adc enemy_ram_ac,x
        sta enemy_ram_ac,x
        
        ; move skully
        jsr skully_handle_movement
        
        lda enemy_ram_ex,x
        cmp #$01
        beq .mirrored
.not_mirrored
        lda #$03
        jsr enemy_set_palette
        jmp .palette_done
.mirrored
        lda #$43
        jsr enemy_set_palette
.palette_done
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
.skully_done
	jmp update_enemies_handler_next
        
        
skully_handle_movement: subroutine
	lda phase_current
        cmp #$00
        beq .demoshit
        lda #$69
        lda enemy_ram_pc,x
        cmp #$40
        bne .not_chasing
        dec enemy_ram_x,x
        
        rts
.not_chasing
        ; but we are zooming
        lda #$20
        sta enemy_ram_pc,x
        lda #$04
        clc
        adc enemy_ram_x,x
        sta enemy_ram_x,x
        cmp #240
        bcc .demoshit
        lda #$40
        sta enemy_ram_pc,x
	rts
.demoshit
        ; move skully to the right
        inc enemy_ram_x,x
	rts
   