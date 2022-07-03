
                    
dumbface_spawn: subroutine
	; x is set by enemy spawner
        lda rng0
        sta enemy_ram_ac,x ; animation counter
        lda #$00
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_pc,x ; pattern counter
        sta enemy_ram_ex,x
        jsr enemy_spawn_random_y_pos
        sta enemy_ram_y,x ; y pos
   	rts
        
        
dumbface_cycle: subroutine
        lda #$10
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
	inc enemy_ram_x,x
        lda enemy_ram_x,x
        jsr sprite_4_set_x
        
        lda enemy_ram_ex,x
        cmp #$00
        bne .going_down
.going_up
	dec enemy_ram_y,x
        bne .updown_done
        lda #$01
        sta enemy_ram_ex,x
        jmp .updown_done
.going_down
	inc enemy_ram_y,x
        lda enemy_ram_y,x
        cmp #$ad
        bne .updown_done
        lda #$00
        sta enemy_ram_ex,x
.updown_done
        lda enemy_ram_y,x
        jsr sprite_4_set_y
        
        inc enemy_ram_ac,x
	lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        and #$03
	cmp #$01
	beq .frame1
	cmp #$02
	beq .frame2
	cmp #$03
	beq .frame3
.frame0
	lda #$20
        jsr sprite_4_set_sprite
        lda #$01
        jsr enemy_set_palette
	jmp .frame_done
.frame1
	lda #$22
        jsr sprite_4_set_sprite
        lda #$01
        jsr enemy_set_palette
        jmp .frame_done
.frame2
	lda #$20
        jsr sprite_4_set_sprite_mirror
        lda #$41
        jsr enemy_set_palette
	jmp .frame_done
.frame3
	lda #$22
        jsr sprite_4_set_sprite_mirror
        lda #$41
        jsr enemy_set_palette
.frame_done
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
.done
	jmp update_enemies_handler_next