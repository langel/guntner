


birb_spawn: subroutine
	; x is set by enemy spawner
	lda #$02
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        lda rng1
        jsr NextRandom
        sta rng1
        sta enemy_ram_pc,x ; pattern counter
        lda rng2
        jsr NextRandom
        sta rng2
        sta enemy_ram_ac,x ; animation counter
        lsr
        clc
        adc #$0c
        sta enemy_ram_y,x ; y pos
        clc
        txa
        lsr
        adc #$20
        sta enemy_ram_oam,x ; OAM ref  
   	rts
        
           
        
  
;;;; HANDLING BIRB
        
birb_cycle: subroutine
	ldx enemy_handler_pos
        ldy enemy_temp_oam_x
        ; update pattern
        lda ENEMY_RAM+3,x
        inc ENEMY_RAM+3,x
        inc ENEMY_RAM+3,x
        lda ENEMY_RAM+3,x
        
        ; set x position
        ; get x pattern position
        ; add it to base x position
        ; save that to OAM x position
        lda ENEMY_RAM+3,x
        tax
        lda sine_table,x
        lsr
        lsr
        lsr
	ldx enemy_handler_pos
        inc ENEMY_RAM+1,x
        clc
        adc ENEMY_RAM+1,x
        sta $0203,y
        sta collision_0_x
        
        ; set y position
        lda ENEMY_RAM+3,x
        clc 
        adc #$40
        tax
        lda sine_table,x
        lsr
        lsr
        lsr
	ldx enemy_handler_pos
        clc
        adc ENEMY_RAM+2,x
        sta $0200,y
        sta collision_0_y
        
        ; current sprite
        lda ENEMY_RAM+4,x
        clc
        adc #$14
        sta ENEMY_RAM+4,x
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        clc 
        adc #$2c
        sta $0201,y
        lda #$08
        sta collision_0_w
        lda #$05
        sta collision_0_h
; get damage amount
        jsr enemy_get_damage_this_frame
        lda enemy_dmg_accumulator
        cmp #$00
        beq .birb_not_hit
        lda enemy_ram_hp,x
        sec
        sbc enemy_dmg_accumulator
        bmi .birb_is_dead
        sta enemy_ram_hp,x
        jmp .birb_not_dead
.birb_is_dead
	inc phase_kill_count
	; give points
        lda #05
        jsr player_add_points_00
        ; change it into crossbones!
        jsr apu_trigger_enemy_death
        lda #$01
        sta enemy_ram_type,x
.birb_not_dead
	jsr apu_trigger_enemy_damage
        ; palette
        lda #$00
        sta $0202,y
        jmp .birb_done
.birb_not_hit
        ; palette
        lda #$01
        sta $0202,y
.birb_done
	jmp update_enemies_handler_next
        