
; things the bat entities need to know
; boss_x  : topleft offset
; boss_y  : topleft offset
; state_v0 : state
; state_v1 : shoot frequency
; state_v2 : x sine position
; state_v3 : y sine position
; state_v4 : x body position
; state_v5 : y body position

; scarab palette
; $0c, $27, $38

boss_scarab_spawn: subroutine
	; claim highest 4 srpite slot for beetle body
	ldx #$16
        stx $03b8
        ; claim 4 more slots for the wings
        lda #$17
        sta $03c0
        sta $03c8
        sta $03d0
        sta $03d8
        ; setup initial state
        lda ENEMY_HITPOINTS_TABLE,x
        sta $03b9
        lda #$14
        sta boss_x
        sta boss_y
        lda #$00
        sta state_v0
        sta state_v1
        sta state_v3
        lda #$40
        sta state_v2
        
        ; palette
        lda #$03
        sta pal_spr_1_1
        lda #$1a
        sta pal_spr_1_2
        lda #$39
        sta pal_spr_1_3
        lda #$0c
        sta pal_spr_2_1
        lda #$27
        sta pal_spr_2_2
        lda #$38
        sta pal_spr_2_3
	rts
        
        ;   KNOW
        ;  THYSELF
        ; DEATHLESS
        
boss_scarab_cycle: subroutine

	lda enemy_ram_y,x
        sec
        sbc #$1c
        bcs .y_greater_than_0
        lda #$00
.y_greater_than_0
        sta collision_0_y
        lda #$0a
        sta collision_0_w
        lda #$4a
        sta collision_0_h
        
        inc boss_dmg_handle_true
        jsr enemy_handle_damage_and_death
        dec boss_dmg_handle_true

; MAIN BODY

	; x pos
        inc state_v2
        ldx state_v2
        lda sine_table,x
        lsr
        lsr
        clc
	adc boss_x
        ldx enemy_ram_offset
        sta enemy_ram_x,x
        sta state_v4
        jsr sprite_4_set_x
        
        ; y pos
        inc state_v3
        inc state_v3
        ldx state_v3
        lda sine_table,x
        lsr
        clc
	adc boss_y
        ldx enemy_ram_offset
        sta enemy_ram_y,x
        sta state_v5
        jsr sprite_4_set_y
        
	; sprite
        lda #$a0
        jsr sprite_4_set_sprite
        
; WINGS
	; twitch offset
        lda rng0
        lsr
        and #$03
        sta temp01 ; x offset
        lda rng1
        and #$03
        ora temp01
        sta temp02 ; y offset
        
	; top middle
	lda #$10
        clc
	adc enemy_oam_offset
        tay
        lda state_v4
        sec
        sbc #$6
        clc
        adc temp01
        sta temp00
        jsr sprite_4_set_x
        lda state_v5
        sec
        sbc #$c
        sbc temp02
        jsr sprite_4_set_y
        lda #$80
        jsr sprite_4_set_sprite
        
        ; top end
	lda #$20
        clc
	adc enemy_oam_offset
        tay
        lda temp00
        jsr sprite_4_set_x
        lda state_v5
        sec
        sbc #$1c
        sbc temp02
        jsr sprite_4_set_y
        lda #$60
        jsr sprite_4_set_sprite
        
	; bottom middle
	lda #$30
        clc
	adc enemy_oam_offset
        tay
        lda temp00
        jsr sprite_4_set_x
        lda state_v5
        clc
        adc #$c
        adc temp02
        jsr sprite_4_set_y
        lda #$80
        jsr sprite_4_set_sprite_flip
        
        ; bottom end
	lda #$40
        clc
	adc enemy_oam_offset
        tay
        lda temp00
        jsr sprite_4_set_x
        lda state_v5
        clc
        adc #$1c
        adc temp02
        jsr sprite_4_set_y
        lda #$60
        jsr sprite_4_set_sprite_flip
        
	; palette
	lda #$01
        ldy enemy_oam_offset
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+$c,y
        clc
        adc #$01
        sta oam_ram_att+$10,y
        sta oam_ram_att+$14,y
        sta oam_ram_att+$18,y
        sta oam_ram_att+$1c,y
        sta oam_ram_att+$20,y
        sta oam_ram_att+$24,y
        sta oam_ram_att+$28,y
        sta oam_ram_att+$2c,y
        ora #$80
        sta oam_ram_att+$30,y
        sta oam_ram_att+$34,y
        sta oam_ram_att+$38,y
        sta oam_ram_att+$3c,y
        sta oam_ram_att+$40,y
        sta oam_ram_att+$44,y
        sta oam_ram_att+$48,y
        sta oam_ram_att+$4c,y
        
; SHOOT
	lda wtf
        and #$1f
        bne .dont_change_freq
        inc state_v1
        lda state_v1
        and #$03
        sta state_v1
.dont_change_freq
	lda wtf
        and state_v1
        bne .done
        
.dart_fire
        lda state_v4
        clc
        adc #$10
        sta collision_0_x
        lda state_v5
        clc
        adc #$04
        sta collision_0_y
        jsr dart_spawn
        cpx #$ff
        beq .done
        lda #<arctang_velocity_1.75
        sta enemy_ram_pc,x
        lda #$02
        sta oam_ram_att,y
        lda #$a2
        sta oam_ram_spr,y
        ldx enemy_ram_offset
        ldy enemy_oam_offset
        

.done
	jmp update_enemies_handler_next