
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
.bottom_quadrant
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
	; need absolute values
; calc y diff
	lda player_y_hi
        sec
        sbc collision_0_y
        bcc .player_y_less_than
.player_y_greater_than
        bcs .calc_y_done
.player_y_less_than
	lda collision_0_y
        sec
        sbc player_y_hi
.calc_y_done
        sta collision_0_h
        tay
; calc x diff
	lda player_x_hi
        sec
        sbc collision_0_x
        bcc .player_x_less_than
.player_x_greater_than
        bcs .calc_x_done
.player_x_less_than
	lda collision_0_x
        sec
        sbc player_x_hi
.calc_x_done
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
.q_smaller ; S * 2.5 > L
	lsr collision_1_h
        lda collision_1_x
        clc
        adc collision_1_h
        cmp collision_1_y
        bcc .region1
        bcs .region0
.q_larger ; S * 2.5 < L
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
	; XXX isn't temp01 already in the accumulator?
	lda temp00
        clc
        adc temp01
        tax
        lda ARCTANG_TRANSLATION_LOOKUP_TABLE,x
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
        

        
ARCTANG_VELOCITY_3.333_TABLE:
	; 3.333 pixels per frame
        ; lo byte, hi byte
	byte  85, 3
        byte  56, 3
        byte 227, 2
        byte  91, 2
        byte 171, 1
        byte 221, 0
        byte   0, 0
        
ARCTANG_VELOCITY_2.5_TABLE:
	byte 127, 2
        byte 104, 2
        byte  43, 2
        byte 197, 1
        byte  64, 1
        byte 166, 0
        byte   0, 0
        
ARCTANG_VELOCITY_1.25_TABLE:
	byte  64, 1
	byte  53, 1
        byte  20, 1
        byte 225, 0
        byte 161, 0
        byte  81, 0
        byte   0, 0
	
        
ARCTANG_REGION_TO_X_VELOCITY_TABLE:
	byte 0, 1, 2, 3, 4, 5
        byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
        byte 6, 5, 4, 3, 2, 1
        
ARCTANG_REGION_X_PLUS_OR_MINUS_TABLE:
	; 1 = plus
        ; 0 = minus
        byte 1, 1, 1, 1, 1, 1
        byte 0, 0, 0, 0, 0, 0
        byte 0, 0, 0, 0, 0, 0
        byte 1, 1, 1, 1, 1, 1
        
ARCTANG_REGION_TO_Y_VELOCITY_TABLE:
        byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
        byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
        
ARCTANG_REGION_Y_PLUS_OR_MINUS_TABLE:
	; 1 = plus
        ; 0 = minus
        byte 0, 0, 0, 0, 0, 0
        byte 0, 0, 0, 0, 0, 0
        byte 1, 1, 1, 1, 1, 1
        byte 1, 1, 1, 1, 1, 1

; arctang movement is 16-bit
; oam ram x,y = high byte
; enemy ram x,y = low byte

        
arctang_update_x: subroutine
        ; temp00 = hi
        ; temp01 = lo
        ; temp02 = region
        ldx temp02
        lda ARCTANG_REGION_TO_X_VELOCITY_TABLE,x
        asl
        tay
        lda ARCTANG_REGION_X_PLUS_OR_MINUS_TABLE,x
        jmp arctang_16bit_maths
        

arctang_update_y: subroutine
        ; temp00 = hi
        ; temp01 = lo
        ; temp02 = region
        ldx temp02
        lda ARCTANG_REGION_TO_Y_VELOCITY_TABLE,x
        asl
        tay
        lda ARCTANG_REGION_Y_PLUS_OR_MINUS_TABLE,x
        jmp arctang_16bit_maths
        
        
arctang_16bit_maths: subroutine
	; a = plus or minus
        ; y = velocity table offset
        cmp #0
        bne .velocity_add
.velocity_sub
	; lo byte
	lda temp01
        sec 
        sbc ARCTANG_VELOCITY_3.333_TABLE,y
        sta temp01
        ; hi byte
        iny
	lda temp00
        sbc ARCTANG_VELOCITY_3.333_TABLE,y
        sta temp00
        jmp .done_x
.velocity_add
	; lo byte
        lda temp01
        clc
        adc ARCTANG_VELOCITY_3.333_TABLE,y
        sta temp01
        ; hi byte
	iny
	lda temp00
        adc ARCTANG_VELOCITY_3.333_TABLE,y
        sta temp00
.done_x
	rts
        

dart_spawn: subroutine
	lda #$10
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        ; x = dart enemy_oam_offset
        txa
        pha ; store x on stack
        sec
        sbc #$a0
        asl
        clc
        adc #$80
        tax
	; y = parent enemy_oam_offset
        ; only works if called by a parent cycle routine
        ldy enemy_oam_offset
        lda oam_ram_x,y
        clc
        adc #$05
        sta collision_0_x
        sta oam_ram_x,x
        lda oam_ram_y,y
        clc
        adc #$02
        sta collision_0_y
        sta oam_ram_y,x
        jsr enemy_get_direction_of_player
        tay
        pla ; pull x from stack
        tax
        tya
        sta enemy_ram_ex,x
        ; reset stuff
        lda #0
        sta enemy_ram_x,x
        sta enemy_ram_y,x
        sta enemy_ram_pc,x
	rts

        
        
        
dart_cycle: subroutine
	
        ; set region for actang
        lda enemy_ram_ex,x
        sta temp02 ; region
        
        ; set x byte for arctang
        lda oam_ram_x,y 
        sta temp00 ; hi byte
	lda enemy_ram_x,x 
        sta temp01 ; lo byte
        jsr arctang_update_x
        ldy enemy_oam_offset
        lda temp00
        sta oam_ram_x,y
	ldx enemy_ram_offset
        lda temp01
        sta enemy_ram_x,x
        
        ; set y byte for arctang
        lda oam_ram_y,y 
        sta temp00 ; hi byte
	lda enemy_ram_y,x 
        sta temp01 ; lo byte
        jsr arctang_update_y
        ldy enemy_oam_offset
        lda temp00
        sta oam_ram_y,y
	ldx enemy_ram_offset
        lda temp01
        sta enemy_ram_y,x

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
	