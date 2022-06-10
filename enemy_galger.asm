

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
arc_leg_arc_offset	EQU	$404
arc_leg_arc_target	EQU	$405
arc_leg_speed_inc	EQU	$406
arc_leg_speed_dec	EQU	$407

; height of playfield = 182px

arc_sequence_begin:
	byte	  #0, #0, #6, #8, #9,
arc_sequence_end:
	byte	  #1, #5, #7, #8, #9,
arc_sequence_x_origin:
	byte	#158, #160,  #232,  #0,  #248, 
arc_sequence_y_origin:
	byte	#120, #236,  #148, #50, #102,
arc_sequences:
; subtract with adding
	; step data:
        ;   xoffset, yoffset, xsize, ysize, 
        ;   angle start, angle end, speed forward, speed back
	; sequence Wide S
        byte     #0,  #216, #100, #40, $80, $40, $0, $2
        byte   #100,  #0,   #100, #40, $80, $00, $2, $0
	; sequence 00
	.byte	#160, #236,  #96,  #96, $80, $80, $3, $0
	.byte	 #38,  #80,  #24,  #16, $00, $00, $7, $0
	.byte	#252,   #0,  #32,  #32, $00, $80, $6, $0
	.byte	#240, #240,  #64,  #48, $00, $00, $5, $0
	.byte	  #0,   #0,  #64,  #60, $00, $80, $4, $0
	.byte	#240,  #60,  #96,  #52, $80, $c0, $0, $3
	; sequence 01
        byte    #48,  #0,  #64, #242, $00, $80, $0, $2
        byte	#212, #160, #160,  #80, $00, $02, $0, $2
        ; sequence 02
        byte    #8,  #0, #41, #80, $00, $07, $0, $07
        ; sequence 03
        byte	#8, #248, #96, #96, $00, $f9, $06, $0
        
        
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
        lda #$c0
        sta enemy_ram_pc,x 
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
        adc #$7e
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
        lda arc_leg_arc_target,x
        bne .non_12_oclock_target
        lda arc_leg_speed_inc,x
        beq .speed_dec_12oclock
.speed_inc_12oclock
        clc
        adc enemy_ram_pc,x
        sta enemy_ram_pc,x
        bcs .next_leg
        rts
.speed_dec_12oclock
	lda enemy_ram_pc,x
        sec
        sbc arc_leg_speed_dec,x
        sta enemy_ram_pc,x
        bcc .next_leg
.non_12_oclock_target
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
        sta arc_leg_arc_offset,x
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
	lda enemy_ram_pc,x
        clc
        adc arc_leg_arc_offset,x
        sta enemy_ram_pc,x
        
.arc_leg_done
        rts
        