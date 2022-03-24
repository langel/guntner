
      
        
; controls player in demo mode    
player_demo_controls: subroutine

; PLAYER MOVEMENT
	; clear player directions
        lda #$00
        sta player_dir_bits
        ; set flags in y register
        ldy #$00
; check x coordinate
        lda player_x_hi
        cmp player_demo_x
        beq .player_x_equal
        bcs .player_x_greater
.player_x_lesser
	lda player_demo_lr
        cmp #$ff
        beq .player_x_equal
	; go right
        lda #%00000001
        ora player_dir_bits
        sta player_dir_bits
        ;inc player_x_hi
        jmp .player_x_done
.player_x_greater
	lda player_demo_lr
        cmp #$00
        beq .player_x_equal
	; go left
        lda #%00000010
        ora player_dir_bits
        sta player_dir_bits
	;dec player_x_hi
        jmp .player_x_done
.player_x_equal
	iny
.player_x_done
; check y coordinate
        lda player_y_hi
        cmp player_demo_y
        beq .player_y_equal
        bcs .player_y_greater
.player_y_lesser
	lda player_demo_ud
        cmp #$ff
        beq .player_y_equal
	; go down
        lda #%00000100
        ora player_dir_bits
        sta player_dir_bits
        ;inc player_y_hi
        jmp .player_y_done
.player_y_greater
	lda player_demo_ud
        cmp #$00
        beq .player_y_equal
	; go up
        lda #%00001000
        ora player_dir_bits
        sta player_dir_bits
	;dec player_y_hi
        jmp .player_y_done
.player_y_equal
	iny
.player_y_done
	; XXX player_movement does this add 2 too
	; add 2 to y position for collision detection
	lda player_y_hi
        clc
        adc #$02
	sta player_coll_y
; check if both coordinates are met
	cpy #$02
        beq .set_demo_new_target
        jmp .done
.set_demo_new_target

	; set x target
	lda rng0
        jsr NextRandom
        sta rng0
        lsr
        clc
        adc #$60
        sta player_demo_x
        cmp player_x_hi
        bcs .player_going_left
.player_going_right
        lda #$ff
        sta player_demo_lr
        jmp .player_x_dir_done
.player_going_left
	lda #$00
        sta player_demo_lr
.player_x_dir_done
        
        ; set y target
	lda rng0
        jsr NextRandom
        sta rng0
        lsr
        clc
        adc #$10
        sta player_demo_y
        cmp player_y_hi
        bcs .player_going_up
.player_going_down
        lda #$ff
        sta player_demo_ud
        jmp .player_y_dir_done
.player_going_up
	lda #$00
        sta player_demo_ud
.player_y_dir_done

.done
	jsr player_move_position

; PLAYER GUN

        
	lda wtf
        and #$47
        cmp #$40
        bne .fire_not_turbo
        lda #$ff
        sta player_a
.fire_not_turbo
        lda #$ff
        sta player_b
        lda wtf
        and #$0f ; should be 7
        cmp #$00
        bne .fire_done
        lda #$ff
        sta player_b_d
.fire_done
	jsr player_bullets_check_controls

	rts

        
        


