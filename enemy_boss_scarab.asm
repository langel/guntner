
; things the bat entities need to know
; boss_x  : topleft offset
; boss_y  : topleft offset
; state_v2 : x sine position
; state_v3 : y sine position
; state_v4 : x body position
; state_v5 : y body position
; state_v6 : x wing position
; state_v7 : y wing position

; scarab palette
; $0c, $27, $38

boss_scarab_spawn: subroutine
	; claim highest 4 sprite slot for beetle body
	;ldx #boss_scarab_id
        ;stx $03b8
        ; claim 4 more slots for the wings
        lda #do_nothing_id
        sta $03c0
        sta $03c8
        sta $03d0
        sta $03d8
        ; setup initial state
        lda #$0
        sta boss_x
        lda #$1c
        sta boss_y
        lda #$00
        sta state_v3
        sta state_v6
        sta state_v7
        lda #$c0
        sta state_v2
	rts
        
        ;   KNOW
        ;  THYSELF
        ; DEATHLESS
        
boss_scarab_cycle: subroutine
        lda #$10
        sta collision_0_w
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
        inc state_v7
        lda state_v7
        cmp #3
        bne .state_v7_dont_reset
        lda #0
        sta state_v7
.state_v7_dont_reset
	lda wtf
        and #1
        sta state_v6
        
	; top middle
	lda #$10
        clc
	adc enemy_oam_offset
        tay
        lda state_v4
        sec
        sbc #$6
        clc
        adc state_v6
        sta temp00
        jsr sprite_4_set_x
        lda state_v5
        sec
        sbc #$c
        sbc state_v7
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
        sbc state_v7
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
        adc state_v7
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
        adc state_v7
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
        and #$03
        bne .done
        lda wtf
        and #$20
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
        lda #<arctang_velocity_2.5
        sta enemy_ram_pc,x
        lda #$02
        sta oam_ram_att,y
        lda #$fe
        sta oam_ram_spr,y
        ldx enemy_ram_offset
        ldy enemy_oam_offset
        

.done
	lda wtf
        and #$0f
        bne .done_x_entrance
	lda boss_x
        cmp #$40
        beq .done_x_entrance
        inc boss_x
.done_x_entrance
	jmp update_enemies_handler_next