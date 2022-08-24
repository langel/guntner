
      
        
; controls player in demo mode    
player_demo_controls: subroutine

; PLAYER MOVEMENT
	; clear player directions
        lda #$00
        sta player_controls
        sta player_controls_debounced
        ; set flags in y register
        tay
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
        lda #BUTTON_RIGHT
        ora player_controls
        sta player_controls
        ;inc player_x_hi
        jmp .player_x_done
.player_x_greater
	lda player_demo_lr
        cmp #$00
        beq .player_x_equal
	; go left
        lda #BUTTON_LEFT
        ora player_controls
        sta player_controls
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
        lda #BUTTON_DOWN
        ora player_controls
        sta player_controls
        ;inc player_y_hi
        jmp .player_y_done
.player_y_greater
	lda player_demo_ud
        cmp #$00
        beq .player_y_equal
	; go up
        lda #BUTTON_UP
        ora player_controls
        sta player_controls
	;dec player_y_hi
        jmp .player_y_done
.player_y_equal
	iny
.player_y_done
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
        adc #$5e
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
        lda #BUTTON_A
        ora player_controls
        sta player_controls
.fire_not_turbo
        lda #BUTTON_B
        ora player_controls
        sta player_controls
        lda wtf
        and #$0f ; should be 7
        cmp #$00
        bne .fire_done
        lda #BUTTON_B
        sta player_controls_debounced
.fire_done
	jsr player_bullets_check_controls

	rts

        
        


