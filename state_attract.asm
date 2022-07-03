


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
        
        
        
        
attract_spawn_enemy: subroutine
	lda wtf
        lsr
        lsr
        lsr
        cmp #0
        beq .1_sprite_slots
        cmp #2 
        beq .2_sprite_slots
        cmp #4
        beq .4_sprite_slots
        rts
        
	; 1 sprite enemy slots
.1_sprite_slots
        jsr get_enemy_slot_1_sprite
        cmp #$ff
        beq .no_1_sprite_spawn
        tax
        lda rng0
        lsr
        and #$03
        clc
        adc #birb_id
	jsr enemy_spawn_delegator
        rts
.no_1_sprite_spawn
        

	; 2 sprite enemy slots
.2_sprite_slots
        jsr get_enemy_slot_2_sprite
        cmp #$ff
        beq .4_sprite_slots
        tax
        lda rng0
        lsr
        and #$01
        clc
        adc #chomps_id
	jsr enemy_spawn_delegator
	rts

	; 4 sprite enemy slots
.4_sprite_slots
        jsr get_enemy_slot_4_sprite
        cmp #$ff
        beq .done
        tax
        lda rng0
        and #$03
        tay
        dey
        tya
        clc
        adc #starglasses_id
	jsr enemy_spawn_delegator
.done
	rts
        
        


        