

boss_vamp_bat_spawn: subroutine
	; a = animation counter
	; x = bat slot in enemy ram
        ; y = boss slot in enemy ram
        ; stash boss slot in pattern counter
        sta enemy_ram_ac,x
	lda #$09
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda enemy_ram_x,y
        sta enemy_ram_x,x
        lda enemy_ram_y,y
        sta enemy_ram_y,x 
        tya
        sta enemy_ram_pc,x
        txa
        lsr
        clc
        adc #$20
        sta enemy_ram_oam,x
	rts
        
        
boss_vamp_bat_cycle: subroutine
	ldx enemy_handler_pos
        ldy enemy_temp_oam_x
        ; update x pos
        lda enemy_ram_ac,x
        tax
        lda sine_table,x
        lsr
        lsr
        clc
        adc boss_x
        sec
        sbc #$1b
	ldx enemy_handler_pos
        sta $0203,y
        sta collision_0_x
        ; update y pos
        lda enemy_ram_ac,x
        clc
        adc #$40
        tax
        lda sine_table,x
        lsr
        lsr
        clc
        adc boss_y
        sec
        sbc #$1d
	ldx enemy_handler_pos
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
; get damage amount
        jsr enemy_get_damage_this_frame
        lda enemy_dmg_accumulator
        cmp #$00
        beq .not_hit
        lda enemy_ram_hp,x
        sec
        sbc enemy_dmg_accumulator
        bmi .is_dead
        sta enemy_ram_hp,x
        jmp .not_dead
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
	jmp update_enemies_handler_next
	

        
boss_vamp_spawn: subroutine
	lda #$08
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        sta boss_hp
        lda #$40
        sta enemy_ram_x,x
        lda #$15
        sta enemy_ram_y,x 
        txa
        lsr
        clc
        adc #$20
        sta enemy_ram_oam,x
        PPU_SETADDR $3F15
        lda #$12
        sta PPU_DATA
        PPU_SETADDR $3F19
        lda #$15
        sta PPU_DATA
        lda #$00
        sta PPU_DATA
        lda #$37
        sta PPU_DATA
        ; XXX not sure if we need this here
        lda #$0d
        sta boss_v0 ; target count of bat underlings
        lda #$00
        sta boss_v1
        txa
        tay
        sty boss_v3
.bat_spawn_loop
	; a = animation counter / v1
	; x = slot in enemy ram 
        ; y = boss slot in ram  / v3
        ; stash boss slot in pattern counter
	jsr get_enemy_slot_1_sprite
        tax
        lda boss_v1
        clc
        adc #$14
        sta boss_v1
        ldy boss_v3
        jsr boss_vamp_bat_spawn
	dec boss_v0
        beq .done
        jmp .bat_spawn_loop
.done
   	rts



boss_vamp_cycle: subroutine
	ldx enemy_handler_pos
        ldy enemy_temp_oam_x
        inc enemy_ram_ac,x
	; calc x
        inc boss_v2 ; x sine
        inc boss_v2 ; x sine
        inc boss_v2 ; x sine
        lda boss_v2
        lsr
        tax
        lda sine_15_max_128_length,x
        sta boss_v0
	ldx enemy_handler_pos
        lda enemy_ram_x,x
        clc
        adc boss_v0
        sta boss_x
	sta collision_0_x
	sta $0203,y
	sta $020b,y
	clc
	adc #$08
	sta $0207,y
	sta $020f,y
	; calc y
        lda enemy_ram_ac,x
        tax
	lda sine_table,x
	lsr
	ldx enemy_handler_pos
	clc
        adc enemy_ram_y,x
        sta boss_y
	sta collision_0_y
	sta $0200,y
	sta $0204,y
	clc
	adc #$08
	sta $0208,y
	sta $020c,y
	; tiles
        lda #$27
	sta $0201,y
	lda #$28
	sta $0205,y
	lda #$37
	sta $0209,y
	lda #$38
	sta $020d,y
        ; setup collision dimensions
        lda #$0d
        sta collision_0_w
        sta collision_0_h
; get damage amount
        jsr enemy_get_damage_this_frame
        lda enemy_dmg_accumulator
        cmp #$00
        beq .not_hit
        lda enemy_ram_hp,x
        sec
        sbc enemy_dmg_accumulator
        bmi .is_dead
        sta enemy_ram_hp,x
        sta boss_hp
        jmp .not_dead
.is_dead
	inc phase_kill_count
	; give points
        lda #$ff
        jsr player_add_points_00
        ; change it into crossbones!
        jsr apu_trigger_enemy_death
        lda #$01
        sta enemy_ram_type,x
        jmp sprite_4_cleanup_for_next
.not_dead
	jsr apu_trigger_enemy_damage
        ; palette
        lda #$00
        sta $0202,y
        sta $0206,y
        sta $020a,y
        sta $020e,y
        jmp .done
.not_hit
        ; palette
        lda #$02
        sta $0202,y
        sta $0206,y
        sta $020a,y
        sta $020e,y
.done
	jmp update_enemies_handler_next
        