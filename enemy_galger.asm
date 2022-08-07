

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

; enemy_ram_pc	= current arc position
; enemy_ram_ac	= arc position high byte
; enemy_ram_ex	= current arc sequence leg

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

	; 16 sequences with 46 steps total
arc_sequence_begin:
	byte $00, $05, $0b, $0f, $11, $13, $15, $1a, $1e, $21, $22, $23, $25, $27, $29, $2b
arc_sequence_end:
	byte $04, $0a, $0e, $10, $12, $14, $19, $1d, $20, $21, $22, $24, $26, $28, $2a, $2d
arc_sequence_lengths:
	byte $05, $06, $04, $02, $02, $02, $05, $04, $03, $01, $01, $02, $02, $02, $02, $03
arc_sequence_x_origin:
	byte $00, $a0, $80, $cd, $98, $35, $be, $d8, $22, $f8, $f1, $cf, $ba, $e2, $c4, $80
arc_sequence_y_origin:
	byte $96, $ec, $2a, $10, $ac, $76, $9e, $a0, $a8, $5e, $32, $84, $78, $70, $8c, $34
arc_sequences:
	; sequence 0 : Spiral Young Buck
	byte $d2, $a0, $60, $60, $80, $40, $00, $02
	byte $60, $10, $40, $40, $c0, $78, $04, $00
	byte $10, $10, $30, $30, $80, $f8, $05, $00
	byte $00, $00, $20, $20, $00, $78, $07, $00
	byte $10, $10, $08, $08, $80, $f0, $10, $00
	; sequence 1 : Spiral O.G.
	byte $a0, $ec, $60, $60, $40, $80, $03, $00
	byte $26, $50, $18, $10, $80, $00, $07, $00
	byte $fc, $00, $20, $20, $00, $80, $06, $00
	byte $f0, $f0, $40, $30, $80, $00, $05, $00
	byte $00, $00, $40, $3c, $00, $80, $04, $00
	byte $f0, $3c, $60, $34, $00, $c0, $00, $03
	; sequence 2 : Big S
	byte $80, $60, $70, $14, $bc, $80, $00, $04
	byte $1c, $d2, $3c, $40, $7d, $03, $00, $04
	byte $00, $c0, $3c, $40, $80, $fa, $04, $00
	byte $dc, $00, $80, $c8, $00, $40, $02, $00
	; sequence 3 : Arc and Loop from Behind
	byte $a8, $00, $ff, $eb, $00, $c0, $00, $01
	byte $00, $5a, $40, $40, $c0, $06, $00, $04
	; sequence 4 : Butt Planet
	byte $28, $b6, $de, $a4, $40, $05, $00, $01
	byte $60, $f0, $20, $12, $80, $c0, $05, $00
	; sequence 5 : Loop Up from Below
	byte $00, $c0, $40, $80, $80, $fa, $02, $00
	byte $00, $00, $40, $40, $00, $7d, $03, $00
	; sequence 6 : Loop de Loop
	byte $00, $00, $80, $10, $80, $c0, $03, $00
	byte $80, $fc, $80, $10, $40, $02, $00, $03
	byte $00, $81, $80, $80, $80, $7e, $02, $00
	byte $00, $81, $80, $10, $00, $c0, $00, $03
	byte $80, $00, $80, $10, $40, $80, $03, $00
	; sequence 7 : Wide Ying Yang
	byte $c8, $c0, $c0, $40, $80, $40, $00, $02
	byte $c0, $00, $40, $40, $c3, $80, $04, $00
	byte $bc, $00, $c0, $40, $80, $c0, $02, $00
	byte $00, $00, $40, $40, $c3, $00, $04, $00
	; sequence 8 : Horse Shoe Loop
	byte $00, $00, $40, $f2, $ca, $80, $00, $02
	byte $d4, $a0, $a0, $50, $80, $02, $00, $02
	byte $30, $00, $40, $f2, $00, $c8, $00, $02
	; sequence 9 : Circle LeftDownReverse
	byte $08, $f8, $60, $60, $00, $f9, $06, $00
	; sequence 10 : Tunnel Going Right
	byte $08, $00, $29, $50, $80, $87, $00, $07
	; sequence 11 : Wide S Short
	byte $00, $d8, $64, $28, $80, $40, $00, $02
	byte $64, $00, $64, $28, $c0, $00, $02, $00
	; sequence 12 : Wide S Medium
	byte $00, $b4, $a0, $50, $80, $40, $00, $02
	byte $a4, $00, $a0, $50, $c0, $00, $02, $00
	; sequence 13 : Stair Step Small
	byte $00, $c8, $3c, $3c, $80, $40, $00, $04
	byte $3c, $f8, $3c, $3c, $c0, $00, $04, $00
	; sequence 14 : Stair Step Big
	byte $00, $8c, $78, $78, $80, $40, $00, $03
	byte $78, $f2, $78, $78, $c0, $00, $03, $00
	; sequence 15 : W
	byte $80, $d8, $40, $78, $c0, $40, $00, $03
	byte $40, $00, $40, $78, $ba, $40, $00, $03
	byte $40, $28, $80, $28, $c3, $3d, $03, $00
        
        
arc_sequence_set: subroutine
	; x holds which sequence
        stx arc_sequence_id
        lda #>arc_sequences
	sta arc_sequence_hi
        lda arc_sequence_begin,x
        asl
        asl
        asl
        bcc .hi_byte_perfect
.hi_byte_increase
	inc arc_sequence_hi
.hi_byte_perfect
	clc
        adc #<arc_sequences
	sta arc_sequence_lo
        bcc .hi_byte_still_perfect
        inc arc_sequence_hi
.hi_byte_still_perfect
        lda arc_sequence_lengths,x
        sta arc_sequence_length
	rts
        
        
galger_spawn: subroutine
	; x is set by enemy spawner
	lda #galger_id
        sta enemy_ram_type,x 
        tay
        lda enemy_hitpoints_table,y
        sta enemy_ram_hp,x 
        ; arc system setup
        lda #0
        sta enemy_ram_ac,x
        sta enemy_ram_ex,x
        ldy arc_sequence_id
        lda arc_sequence_x_origin,y
        sta enemy_ram_x,x
        lda arc_sequence_y_origin,y
        sta enemy_ram_y,x
        ; angle / pc set in leg init
        jsr arc_leg_init
	rts
        
galger_cycle: subroutine
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
	; time to shoot a dart?
        lda rng0
        lsr
        and #$3f
        bne .dont_fire
.dart_fire
	lda oam_ram_x,y
        sta dart_x_origin
        lda oam_ram_y,y
        sta dart_y_origin
        lda #$04
        sta dart_velocity
        lda #$00
        sta dart_sprite
        sta dart_dir_adjust
        jsr dart_spawn
        ldy enemy_oam_offset
.dont_fire
        ldx enemy_ram_offset
        
	jsr arc_leg
        ; current sprite
        lda #$7f
        sta oam_ram_spr,y
        ; do palette
        lda enemy_ram_pc,x
        and #$c0
        ora #$01
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
arc_leg_init:
	lda enemy_ram_ex,x
	; update arc data in enemy slot
        asl
        asl
        asl
        tay
        lda (arc_sequence_lo),y
        sta arc_leg_x_offset,x
        iny
        lda (arc_sequence_lo),y
        sta arc_leg_y_offset,x
        iny
        lda (arc_sequence_lo),y
        sta arc_leg_x_scale,x
        iny
        lda (arc_sequence_lo),y
        sta arc_leg_y_scale,x
        iny
        lda (arc_sequence_lo),y
        sta arc_leg_arc_start,x
        sta enemy_ram_pc,x
        iny
        lda (arc_sequence_lo),y
        sta arc_leg_arc_target,x
        iny
        lda (arc_sequence_lo),y
        sta arc_leg_speed_inc,x
        iny
        lda (arc_sequence_lo),y
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
	inc enemy_ram_ex,x
        lda arc_sequence_length
        cmp enemy_ram_ex,x
        bne .dont_wrap_sequence
        lda #0
        sta enemy_ram_ex,x
.dont_wrap_sequence
        rts
        