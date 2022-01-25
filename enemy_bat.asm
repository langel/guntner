

bat_spawn: subroutine
	; x = slot in enemy ram
        ; y = boss slot in enemy ram
        ; stash boss slot in pattern counter
	lda #$07
        sta enemy_ram_type,x
        lda #$20
        sta enemy_ram_x,x
        sta enemy_ram_y,x 
        lda #$02
        sta enemy_ram_hp,x
        tya
        sta enemy_ram_pc,x
        txa
        lsr
        clc
        adc #$20
        sta enemy_ram_oam,x
	rts
     
     
bat_cycle:
	ldx enemy_handler_pos
        ldy enemy_temp_oam_x
        ; update x pos
        lda enemy_ram_x,x
        sta $0203,y
        sta collision_0_x
        ; update y pos
        lda enemy_ram_y,x
        sta $0200,y
        sta collision_0_y
        ; update animation
        inc enemy_ram_ac,x
        lda enemy_ram_ac,x
        lsr
        lsr
        and #%00000011
        cmp #$00
        bne .not_frame0
        lda #$39
        jmp .frame_done
.not_frame0
        cmp #$02
        bne .not_frame2
        lda #$3b
        jmp .frame_done
.not_frame2
	lda #$3a        	
.frame_done
        sta $0201,y
        ; setup collision dimensions
        lda #$08
        sta collision_0_w
        sta collision_0_h
; shot by bullet?
        jsr player_bullet_collision_handler
        cmp #$00
        beq .not_hit
        ; decrease health
	ldx enemy_handler_pos
        dec enemy_ram_hp,x
        lda enemy_ram_hp,x
        cmp #$00
        bne .not_dead
.is_dead
	inc phase_kill_count
	; give points
        lda #05
        jsr player_add_points_00
        ; change it into crossbones!
        jsr apu_trigger_enemy_death
        lda #$01
        sta ENEMY_RAM+0,x
.not_dead
	jsr apu_trigger_enemy_damage
        ; palette
        lda #$00
        sta $0202,y
        jmp .done
.not_hit
        ; palette
        lda #$01
        sta $0202,y
.done
	jsr player_collision_detect
	jmp update_enemies_handler_next