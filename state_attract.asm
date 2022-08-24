


attract_init:
  ; SCROLL SPEED
	jsr game_init_generic
  	lda #03
        sta scroll_speed_hi
        lda #173
        sta scroll_speed_lo
        lda #state_update_jump_table_offset+5
	sta state_update_addr
        lda attract_true
        bne .attract_mode_set
        jsr clear_all_enemies
        lda #$ff
        sta attract_true
        lda #iframe_attract_length
        sta state_iframe_length
.attract_mode_set
        jsr render_enable
        jsr palette_fade_in_init
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
        and #$07
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
	jmp state_update_done
        
        
        
attract_spawn_enemy: subroutine
	; starglasses
	lda $03a0
        bne .no_starglasses
        ldx #$a0
        lda #starglasses_id
        bne .delegate
.no_starglasses
	; birb
	jsr get_enemy_slot_1_sprite
        cpx #$ff
        beq .no_birb
        lda #birb_id
        bne .delegate
.no_birb
	; maggs
	jsr get_enemy_slot_2_sprite
        cpx #$ff
        beq .no_maggs
        lda #maggs_id
        bne .delegate
.no_maggs
	; skully
	jsr get_enemy_slot_4_sprite
        lda #skully_id
        cpx #$c0
        bcc .delegate
	rts
.delegate
        jmp enemy_spawn_delegator


