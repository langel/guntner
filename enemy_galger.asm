

; flight path built on sine table circles

; quadrants clockwise : x val , y val
; 0 or 12-3 : $00-$40 , $c0-$00
; 1 or 3-6  : $40-$80 , $00-$40
; 2 or 6-9  : $80-$c0 , $40-$80
; 3 or 9-12 : $c0-$00 , $80-$c0

; state sequence -- comes in from top
;        ; x,y origin ; quandrant(s) ; diameter x,y ; x,y origin diff
; state1 ;  88,-48    ;       1      ; 96, 96       ;            
; state2 ; 124, 32    ;     2-3      ; 24, 16       ; +38, +80
; state3 ; 120, 32    ;     0-1      ; 32, 32       ;  -4, 0
; state4 ; 104, 16    ;     2-3      ; 64, 48       ; -16, -16
; state5 ; 104, 16    ;     0-1      ; 64, 60       ;   0, 0
; state6 ;  88, 76    ; 3 in reverse ; 96, 52       ; -16, +60
; state7 resets the pattern...   -8, 56             ; -96, -20

; before 1st leg translation === saves stuff in enemy ram
; x, y origin: 184, 228		<-- saved in x, y
; how many legs : 6		<-- saved in ex
; initial arc position: $c0	<-- saved in pattern counter


arc_leg_x_offset	EQU	$400
arc_leg_y_offset	EQU	$401
arc_leg_x_scale		EQU	$402
arc_leg_y_scale		EQU	$403
arc_leg_arc_start	EQU	$404
arc_leg_arc_target	EQU	$405
arc_leg_speed_inc	EQU	$406
arc_leg_speed_dec	EQU	$407

; height of playfield = 182px
arc_sequence_begin:
	byte $00, $06, $07, $08, $0a, $0c, $0e, $10, $12
arc_sequence_end:
	byte $05, $06, $07, $09, $0b, $0d, $0f, $11, $14
arc_sequence_x_origin:
	byte $a0, $f8, $e8, $e8, $c8, $ba, $dc, $c0, $80
arc_sequence_y_origin:
	byte $ec, $5e, $32, $b8, $84, $78, $70, $8c, $34
arc_sequences:
	; sequence 0 : Spiral O.G.
	byte $a0, $ec, $60, $60, $40, $80, $03, $00
	byte $26, $50, $18, $10, $80, $00, $07, $00
	byte $fc, $00, $20, $20, $00, $80, $06, $00
	byte $f0, $f0, $40, $30, $80, $00, $05, $00
	byte $00, $00, $40, $3c, $00, $80, $04, $00
	byte $f0, $3c, $60, $34, $00, $c0, $00, $03
	; sequence 1 : Circle LeftDownReverse
	byte $08, $f8, $60, $60, $00, $f9, $06, $00
	; sequence 2 : Tunnel Going Right
	byte $08, $00, $29, $50, $80, $87, $00, $07
	; sequence 3 : Horse Shoe Loop
	byte $30, $00, $40, $f2, $00, $80, $00, $02
	byte $d4, $a0, $a0, $50, $80, $02, $00, $02
	; sequence 4 : wide S short
	byte $00, $d8, $64, $28, $80, $40, $00, $02
	byte $64, $00, $64, $28, $c0, $00, $02, $00
	; sequence 5 : wide S medium
	byte $00, $b4, $a0, $50, $80, $40, $00, $02
	byte $a4, $00, $a0, $50, $c0, $00, $02, $00
	; sequence 6 : stair step small
	byte $00, $c8, $3c, $3c, $80, $40, $00, $04
	byte $3c, $f8, $3c, $3c, $c0, $00, $04, $00
	; sequence 7 : stair step big
	byte $00, $8c, $78, $78, $80, $40, $00, $03
	byte $78, $f2, $78, $78, $c0, $00, $03, $00
	; sequence 8 : W
	byte $80, $d8, $40, $78, $c0, $40, $00, $03
	byte $40, $00, $40, $78, $ba, $40, $00, $03
	byte $40, $28, $80, $28, $c3, $3d, $03, $00
        
        
galger_spawn: subroutine
	; x is set by enemy spawner
	lda #$0f
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        ; arc system setup
        ldy state_v6
        lda arc_sequence_begin,y
        sta enemy_ram_ex,x
        lda arc_sequence_x_origin,y
        sta enemy_ram_x,x
        lda arc_sequence_y_origin,y
        sta enemy_ram_y,x
        ; angle / pc set in leg init
        lda #$00
        sta enemy_ram_ac,x
        jsr arc_leg_init
	rts
        
galger_cycle: subroutine
; saved for later
        lda #$08
        sta collision_0_w
        lda #$08
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
	; time to shoot a dart?
        ;inc enemy_ram_ac,x
        ;lda enemy_ram_ac,x
        lda wtf
        lda rng0
        lsr
        and #$3f
        bne .dont_fire
.dart_fire
	lda oam_ram_x,y
        sta collision_0_x
        lda oam_ram_y,y
        sta collision_0_y
        jsr dart_spawn
        ldy enemy_oam_offset
.dont_fire
        ldx enemy_ram_offset
        
	jsr arc_leg
        ; current sprite
        lda wtf
        and #$01
        clc
        ; XXX dunno if animation is good here
        ;adc #$7e
        lda #$7e
        sta oam_ram_spr,y
        ; do palette
        lda enemy_ram_pc,x
        ; XXX we rotating or not?
        and #$c0
        ora #$01
        lda #$03
        jsr enemy_set_palette
.done	
	jmp update_enemies_handler_next
        
        
        
                
arc_leg: subroutine
        ; set x position
        
        lda enemy_ram_pc,x
        sta temp00
        lda arc_leg_x_scale,x
        ldx temp00
        jsr sine_of_scale
        
        ldx enemy_ram_offset
        clc
        adc enemy_ram_x,x
        sta oam_ram_x,y
        
        ; set y position
        lda enemy_ram_pc,x
        clc
        adc #$c0
        sta temp00
        lda arc_leg_y_scale,x
        ldx temp00
        jsr sine_of_scale
        
        ldx enemy_ram_offset
        clc
        adc enemy_ram_y,x
        sta oam_ram_y,y
        
        cmp #240
        bcc .y_under_240
        sec
        sbc sprite_0_y_diff
        sta oam_ram_y,y
        lda enemy_ram_y,x
        sec
        sbc sprite_0_y_diff
        sta enemy_ram_y,x
        bcs .y_check_done
.y_under_240
	cmp sprite_0_y
        bcc .y_check_done
        clc
        adc sprite_0_y_diff
        sta oam_ram_y,y
        lda enemy_ram_y,x
        clc
        adc sprite_0_y_diff
        sta enemy_ram_y,x
.y_check_done
        
        ; forward arc position
        lda enemy_ram_ac,x
        beq .speed_handle_normal
.speed_handle_abnormal
        lda arc_leg_speed_inc,x
        cmp #$00
        beq .speed_ab_dec
.speed_ab_inc
        clc
        adc enemy_ram_pc,x
        sta enemy_ram_pc,x
        bcc .speed_ab_done
        bcs .speed_dec_ac
.speed_ab_dec
	lda enemy_ram_pc,x
        sec
        sbc arc_leg_speed_dec,x
        sta enemy_ram_pc,x
        bcs .speed_ab_done
.speed_dec_ac
	dec enemy_ram_ac,x
.speed_ab_done
	rts
	

.speed_handle_normal
        lda arc_leg_speed_inc,x
        cmp #$00
        beq .speed_dec
.speed_inc
        clc
        adc enemy_ram_pc,x
        sta enemy_ram_pc,x
        cmp arc_leg_arc_target,x
        bcs .next_leg
        rts
.speed_dec
	lda enemy_ram_pc,x
        sec
        sbc arc_leg_speed_dec,x
        sta enemy_ram_pc,x
        cmp arc_leg_arc_target,x
        bcc .next_leg
        rts
        
.next_leg
	lda state_v6 ; arc sequence id
        tay
	inc enemy_ram_ex,x
        lda arc_sequence_end,y
        cmp enemy_ram_ex,x
        bcs .dont_wrap_sequence
        lda arc_sequence_begin,y
        sta enemy_ram_ex,x
.dont_wrap_sequence
arc_leg_init:
	lda enemy_ram_ex,x
	; update arc data in enemy slot
        asl
        asl
        asl
        tay
        lda arc_sequences,y
        sta arc_leg_x_offset,x
        lda arc_sequences+1,y
        sta arc_leg_y_offset,x
        lda arc_sequences+2,y
        sta arc_leg_x_scale,x
        lda arc_sequences+3,y
        sta arc_leg_y_scale,x
        lda arc_sequences+4,y
        sta arc_leg_arc_start,x
        sta enemy_ram_pc,x
        lda arc_sequences+5,y
        sta arc_leg_arc_target,x
        lda arc_sequences+6,y
        sta arc_leg_speed_inc,x
        lda arc_sequences+7,y
        sta arc_leg_speed_dec,x
        ldy enemy_oam_offset
	; update x origin
	lda enemy_ram_x,x
        clc
        adc arc_leg_x_offset,x
        sta enemy_ram_x,x
        ; update y origin
	lda enemy_ram_y,x
        clc
        adc arc_leg_y_offset,x
        sta enemy_ram_y,x
        ; update arc origin
        lda arc_leg_arc_start,x
        sta enemy_ram_pc,x
        lda arc_leg_speed_inc,x
        cmp #$00
        beq .check_speed_dec_count
.check_speed_inc_count
	lda arc_leg_arc_start,x
        cmp arc_leg_arc_target,x
        bcc .arc_leg_done
        inc enemy_ram_ac,x
        bne .arc_leg_done
.check_speed_dec_count
        lda arc_leg_arc_start,x
        cmp arc_leg_arc_target,x
        bcs .arc_leg_done
        inc enemy_ram_ac,x
.arc_leg_done
        rts
        