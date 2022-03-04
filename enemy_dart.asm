
; can we move in 16 different directions?
; 1
; darts are being fired from sandbox2 spawn currently
; only 8 on screen at a time
; enemy_ram_offset is $a0 .. $d8
; 2
; put enemy direction in enemy_ram_ex
; use sine scaler to get position

; 128 possible angles
;   4 quadrants
;  32 angles per quadrant
; 
;  3 | 2
;  --+--
;  1 | 0

;  direction  7bit 8bit
; 12 o'clock  $00  $00
;  3 o'clock  $20  $40
;  6 o'clock  $40  $80
;  9 o'clock  $60  $c0

enemy_get_direction_of_player:
; references these zp vars
;	collision_0_x
;	collision_0_y
;	player_x_hi
;	player_y_hi
; uses these zp vars
;	collision_0_w	= x delta
;	collision_0_h	= y delta
;	collision_1_x	= "small"
;	collision_1_y	= "large"
;	collision_1_h	= "half"
;	collision_1_w	= enemy_ram_offset x register cache
;	temp00 		= quadrant
;	temp01 		= region
; returns a = direction for sine scaler
	stx collision_1_w
	; find quadrant
        lda #0
        sta temp00
; x quadrants
        lda collision_0_x
        sec
        sbc player_x_hi
        bcc .left_quadrant
.right_quadrant
        sta collision_0_w
        jmp .x_quadrant_done
.left_quadrant
        inc temp00
	lda player_x_hi
        sec
        sbc collision_0_x
        sta collision_0_w
.x_quadrant_done
; y quadrants
        lda collision_0_y
        sec
        sbc player_y_hi
        bcc .top_quadrant
        sta collision_0_h
        jmp .y_quadrant_done
.top_quadrant
        inc temp00
        inc temp00
	lda player_y_hi
        sec
        sbc collision_0_y
        sta collision_0_h
.y_quadrant_done
	; quadrant is now in temp00
.calc_deltas
        ; calc y diff
	lda player_y_hi
        sec
        sbc collision_0_y
        sta collision_0_h
        tay
	; calc x diff
	lda player_x_hi
        sec
        sbc collision_0_x
        sta collision_0_w
        tax
        
   	; start finding that region
        cpx collision_0_h
        bcs .x_greater_or_equal_y
.x_less_than_y
	lda #16
        sta temp01
        stx collision_1_x
        sty collision_1_y
        bne .determine_region
.x_greater_or_equal_y
	lda #0
        sta temp01
        stx collision_1_y
        sty collision_1_x
.determine_region
	lda collision_1_x
        lsr
        sta collision_1_h
        lda collision_1_x
        asl
        bcs .q_smaller
        clc
        adc collision_1_h
        bcs .q_smaller
        cmp collision_1_y
        bcc .q_larger
.q_smaller
	lsr collision_1_h
        lda collision_1_x
        clc
        adc collision_1_h
        cmp collision_1_y
        bcc .region1
        bcs .region0
.q_larger
        lda collision_1_x
        asl
        asl
        asl
        bcs .region2
        sec
        sbc collision_1_h
        cmp collision_1_y
        bcc .region3
        jmp .region2
.region0  ; L / S < 1.25	; d = 3,9,15,21
	jmp .result_lookup
.region1  ; 1.25 < L / S < 2.5	; d = 2,4,8,10,14,16,20,22
	lda temp01
        clc 
        adc #4
        sta temp01
        bpl .result_lookup
.region2  ; 2.5 < L / S < 7.5	; d = 1,5,7,11,13,17,19,23
	lda temp01
        clc
        adc #8
        sta temp01
        bpl .result_lookup
.region3 ; 7.5 < L / S		; d = 0,6,12,18
	lda temp01
        clc
        adc #12
        sta temp01
.result_lookup
	lda temp00
        clc
        adc temp01
        tax
        lda ARCTANG_TRANSLATION_LOOKUP_TABLE,x
        tax
        lda ARCTANG_TRANSLATION_LOOKUP_TABLE2,x
        ; restore enemy_ram_offset
	ldx collision_1_w
        rts

;  0 = right
;  6 = up
; 12 = left
; 18 = down

ARCTANG_TRANSLATION_LOOKUP_TABLE:
	byte  9, 3,15,21
	byte 10, 2,14,22
	byte 11, 1,13,23
	byte 12, 0,12, 0
	byte  9, 3,15,21
	byte  8, 4,16,20
	byte  7, 5,17,19
	byte  6, 6,18,18
        

ARCTANG_TRANSLATION_LOOKUP_TABLE2:
	byte $40, $35, $2b, $20, $16, $0b
        byte $00, $f5, $eb, $e0, $d6, $cb
        byte $c0, $b5, $ab, $a0, $96, $8b
        byte $80, $75, $6b, $60, $56, $4b
        
        
        ; each region is 15 degrees
ARCTANG_DART_VELOCITY_TABLE:
	; 3.333 pixels per frame
        ; x lo byte, hi byte
	byte  85, 3
        byte  56, 3
        byte 227, 2
        byte  91, 2
        byte 171, 1
        byte 221, 0
        ; y lo byte, hi byte
        byte   0, 0
        byte 221, 0
        byte 171, 1
        byte  91, 2
        byte 227, 2
        byte  56, 3
        

; arctang movement is 16-bit
; oam ram x,y = high byte
; enemy ram x,y = low byte


dart_spawn: subroutine
	lda #$10
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
	; y = parent enemy_ram_offset
        ; only works if called by a parent cycle routine
        ldy enemy_oam_offset
        lda oam_ram_x,y
        clc
        adc #$05
        sta enemy_ram_x,x
        ;sta collision_0_x
        lda oam_ram_y,y
        clc
        adc #$02
        sta enemy_ram_y,x
        ;sta collision_0_y
        ; set direction
        ;tya
        ;clc
        ;adc #$10
        ;sta enemy_ram_ex,x
        jsr enemy_get_direction_of_player
        ;ldx enemy_ram_offset
        sta enemy_ram_ex,x
        ; reset pattern counter
        lda #0
        sta enemy_ram_pc,x
	rts
        
        
dart_cycle: subroutine
	dec enemy_ram_x,x
	dec enemy_ram_y,x
        inc enemy_ram_pc,x
	dec enemy_ram_x,x
	dec enemy_ram_y,x
        inc enemy_ram_pc,x
        ; find sprite x with sine_of_scale
        ; a = sine max = enemy_ram_pc
        ; x = angle pos = enemy_ram_ex
        ldy enemy_ram_pc,x
        lda enemy_ram_ex,x
        tax
        tya
        jsr sine_of_scale
        asl
        ldx enemy_ram_offset
        ldy enemy_oam_offset
        clc
        adc enemy_ram_x,x
        sta oam_ram_x,y
        ; find sprite y with sine_of_scale
        ; a = sine max = enemy_ram_pc
        ; x = angle pos = enemy_ram_ex
        ldy enemy_ram_pc,x
        lda enemy_ram_ex,x
        clc
        adc #$c0
        tax
        tya
        jsr sine_of_scale
        asl
        ldx enemy_ram_offset
        ldy enemy_oam_offset
        clc
        adc enemy_ram_y,x
        sta oam_ram_y,y

	; check for despawn
        lda oam_ram_x,y
        cmp #$09
        bcc .despawn
	lda oam_ram_y,y
        cmp sprite_0_y
        bcs .despawn
        

	lda #$6a
        sta oam_ram_spr,y
        lda #0
        jsr enemy_set_palette
.done	
	jmp update_enemies_handler_next
.despawn
        lda #$00
        sta enemy_ram_type,x
        lda #$ff
        sta oam_ram_y,y
        jmp .done
	