
                
starglasses_spawn: subroutine
	; x is set by enemy spawner
	lda #$04
        sta $0300,x ; enemy type
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda rng0
        jsr NextRandom
        sta rng0
        sta $0303,x ; pattern counter
        sta $0304,x ; animation counter
        lda #$00
        sta $0301,x ; x pos
        lda rng0
        jsr NextRandom
        jsr NextRandom
        sta rng0
        lsr
        lsr
        clc
        adc #$18
        sta $0302,x ; y pos
        txa
        sec
        sbc #$a0
        asl
        clc
        adc #$80
        sta $0307,x ; OAM ref
   	rts
        
           

;;; HANDLING STARGLASSES
starglasses_cycle: subroutine
	ldy enemy_temp_oam_x

	ldx enemy_handler_pos
	; using pattern_counter for x sin
	inc enemy_ram_pc,x
	; using anim_counter for y sin
	inc enemy_ram_ac,x
	inc enemy_ram_ac,x

	; calc x
	lda enemy_ram_pc,x
        tax
	lda sine_table,x
	lsr
	lsr
	ldx enemy_handler_pos
	clc
	adc enemy_ram_x,x
	sta collision_0_x
	sta $0203,y
	sta $020b,y
	clc
	adc #$08
	sta $0207,y
	sta $020f,y

	; calc y
	ldx enemy_handler_pos
        lda enemy_ram_ac,x
        tax
	lda sine_table,x
	lsr
	lsr
	clc
	ldx enemy_handler_pos
	adc enemy_ram_y,x
	sta collision_0_y
	sta $0200,y
	sta $0204,y
	clc
	adc #$08
	sta $0208,y
	sta $020c,y

	; tiles
	ldx enemy_handler_pos
	lda enemy_ram_ac,x
	and #$40
	beq .frame1
.frame0
	lda #$0c
	sta $0201,y
	lda #$0d
	sta $0205,y
	lda #$1c
	sta $0209,y
	lda #$1d
	sta $020d,y
	jmp .frame_done
.frame1
	lda #$0e
	sta $0201,y
	lda #$0f
	sta $0205,y
	lda #$1e
	sta $0209,y
	lda #$1f
	sta $020d,y
.frame_done

	lda #$10
	sta collision_0_w
	sta collision_0_h
; get damage amount
        jsr enemy_get_damage_this_frame
        lda enemy_dmg_accumulator
        cmp #$00
        beq .palette_check
        lda enemy_ram_hp,x
        sec
        sbc enemy_dmg_accumulator
        bcc .dead
        sta enemy_ram_hp,x
        jmp .not_dead
.dead
        jsr apu_trigger_enemy_death
	; give points
        lda #00
        jsr player_add_points_00
	inc phase_kill_count
        lda #25
        jsr player_add_points_00__
        ; spawn powerup
        jsr powerup_from_starglasses
        jmp sprite_4_cleanup_for_next
.not_dead
        lda #ENEMY_HIT_PALETTE_FRAMES
	sta enemy_ram_att,x
	jsr apu_trigger_enemy_damage
.palette_check
	lda enemy_ram_att,x
        cmp #$00
        beq .palette_not_hit
.palette_hit
        dec enemy_ram_att,x
	lda #$00
	sta $0202,y
	sta $0206,y
	sta $020a,y
	sta $020e,y
        jmp .done
.palette_not_hit
	lda #$03
	sta $0202,y
	sta $0206,y
	sta $020a,y
	sta $020e,y
.done
	jmp update_enemies_handler_next
        