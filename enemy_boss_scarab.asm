
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
        lda #$10
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
        
scarab_oam_offset_table:
	byte $c0, $d0, $e0, $f0
scarab_wing_y_offset_table:
	byte $f4, $e4, $0c, $1c
scarab_wing_sprite_table:
	byte $80, $60, $80, $60
                
        
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
        
        
		
		
	; palette
	lda #$01
        ldy enemy_oam_offset
        jsr sprite_4_set_palette
        beq .hit
        clc
        adc #$01
.hit
	sta temp01
        
        ; calc x pos of wing set
        lda state_v4
        sec
        sbc #$6
        clc
        adc state_v6
        sta temp00
		
		
	ldx #$03
.wing_sprites_loop
	ldy scarab_oam_offset_table,x
	; x
	lda temp00
        jsr sprite_4_set_x
	; y
	lda state_v5
	clc
	adc scarab_wing_y_offset_table,x
	jsr sprite_4_set_y
        ; sprite
	lda scarab_wing_sprite_table,x
        ; flipped wing?
        cpx #$02
        bcc .no_flip
        jsr sprite_4_set_sprite_flip
        ; att flipped
        lda temp01
        ora #$80
        bne .sprite_done
.no_flip
        jsr sprite_4_set_sprite
	; att
	lda temp01
.sprite_done
        jsr sprite_4_set_palette_no_process
	dex
	bpl .wing_sprites_loop
        
        
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
        sta dart_x_origin
        lda state_v5
        clc
        adc #$04
        sta dart_y_origin
        lda #$02
        sta dart_velocity
        lda #$fe
        sta dart_sprite
        lda #$00
        sta dart_dir_adjust
        jsr dart_spawn
        

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