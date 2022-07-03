


attract_init:
  ; SCROLL SPEED
	jsr game_init_generic
  	lda #03
        sta scroll_speed_hi
        lda #173
        sta scroll_speed_lo
        lda #5
        jsr state_update_set_addr
        lda #$ff
        sta attract_true
        jsr render_enable
        jsr palette_fade_in_init
        ; turn on iframes
        lda #20
        sta state_iframes
        ; XXX testing
        ;lda #1
        ;jsr song_start
        rts
        
        

attract_update: subroutine
        ; some buttons return to menu
        lda player_start
        ora player_a
        ora player_b
        cmp #$ff
        bne .menu_return_buttons_not_pressed
        lda #0
	jsr palette_fade_out_init
	jmp state_update_done
.menu_return_buttons_not_pressed
	lda wtf
        and #$03
        bne .no_enemy_spawn
	jsr attract_spawn_enemy
.no_enemy_spawn
	lda player_health
        cmp #$00
        beq .done
        jsr player_demo_controls
        jsr player_bullets_check_controls
.done
	jsr game_update_generic
        ; XXX testing
        ;jsr apu_game_music_frame
	jmp state_update_done
        
        
attract_spawn_table:
	byte #birb_id, #birb_id, #spark_id, #starglasses_id
        byte #maggs_id, #skully_id, #dumbface_id, #starglasses_id
        byte #spark_id, #zigzag_id, #zigzag_id, #skully_id
        byte #skeet_id, #skeet_id, #spark_id, #starglasses_id
        
attract_spawn_enemy: subroutine
	lda wtf
        and #$07
        bne .done
        lda rng1
        and #$0f
        tax
        ldy attract_spawn_table,x
        sty phase_spawn_type
        jsr enemy_slot_from_type
        cmp #$ff
        beq .done
        tax
        lda phase_spawn_type
	jsr enemy_spawn_delegator
.done
	rts
