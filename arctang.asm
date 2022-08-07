; quadrants
; 
;  0 | 1
;  --+--
;  2 | 3

; 24 angular regions total (0-23)
; 6 regions per quadrant
;  direction  
; 12 o'clock  6
;  3 o'clock  0
;  6 o'clock  18
;  9 o'clock  12

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
;	temp00 		= quadrant
;	temp01 		= region
;	temp02		= x register stash
;	temp03		= y register stash
; returns a = direction (or region)
	stx temp02
        sty temp03
	; find quadrant
        lda #0
        sta temp00
; y quadrants
        lda player_y_hi
        sec
        sbc collision_0_y
        bcc .top_quadrant
.bottom_quadrant
        inc temp00
        inc temp00
        jmp .y_quadrant_done
.top_quadrant
	lda collision_0_y
        sec
        sbc player_y_hi
.y_quadrant_done
        sta collision_0_h
        tay
; x quadrants
        lda player_x_hi
        sec
        sbc collision_0_x
        bcc .left_quadrant
.right_quadrant
        inc temp00
        jmp .x_quadrant_done
.left_quadrant
	lda collision_0_x
        sec
        sbc player_x_hi
.x_quadrant_done
        sta collision_0_w
        tax
	; quadrant is now in temp00
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
	lda temp01
        clc
	bmi .result_lookup
.region1  ; 1.25 < L / S < 2.5	; d = 2,4,8,10,14,16,20,22
	lda temp01
        clc 
        adc #4
        bpl .result_lookup
.region2  ; 2.5 < L / S < 7.5	; d = 1,5,7,11,13,17,19,23
	lda temp01
        clc
        adc #8
        bpl .result_lookup
.region3 ; 7.5 < L / S		; d = 0,6,12,18
	lda temp01
        clc
        adc #12
.result_lookup
	; temp01 should be ready in the accumulator
        adc temp00
        tax
        lda ARCTANG_TRANSLATION_LOOKUP_TABLE,x
        ; restore enemy_ram_offset
	ldx temp02
        ldy temp03
        rts

        
        
   
arctang_bound_dir: subroutine
	; a = value to be bounded
        ; returns value 0..23 in a
        bpl .check_above_24
.below_0
	clc
        adc #24
        rts
.check_above_24
	cmp #24
        bcc .bounded
        sec
        sbc #24
.bounded
	rts

        

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
        bpl arctang_16bit_maths
        
arctang_update_y: subroutine
        ; temp00 = hi
        ; temp01 = lo
        ; temp02 = region
        ldx temp02
        lda ARCTANG_REGION_TO_Y_VELOCITY_TABLE,x
        asl
        tay
        lda ARCTANG_REGION_Y_PLUS_OR_MINUS_TABLE,x
        bpl arctang_16bit_maths
        
arctang_16bit_maths: subroutine
	; a = plus or minus
        ; y = velocity table offset
        bne .velocity_add
.velocity_sub
	; lo byte
	lda temp01
        sec 
        sbc (arctang_velocity_lo),y
        sta temp01
        ; hi byte
	lda temp00
        iny
        sbc (arctang_velocity_lo),y
        sta temp00
        jmp .done_x
.velocity_add
	; lo byte
        lda temp01
        clc
        adc (arctang_velocity_lo),y
        sta temp01
        ; hi byte
	lda temp00
        iny
        adc (arctang_velocity_lo),y
        sta temp00
.done_x
	rts
        

        

arctang_enemy_update:
	; updates both x and y position given:
        ;	- enemy_ram_ex holds region/direction
        ;	- enemy_ram_x/y holds lo bytes
        ;	- oam_ram_x/y holds hi bytes

        ; set region for arctang
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
        jsr enemy_fix_y_visible
        sta oam_ram_y,y
	ldx enemy_ram_offset
        lda temp01
        sta enemy_ram_y,x
        
        rts
