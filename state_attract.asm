


attract_init:
  ; SCROLL SPEED
  	lda #$07
        sta scroll_speed_cache
	jsr game_init_generic
        lda #5
        jsr state_update_set_addr
        lda #$ff
        sta attract_true
        jsr starfield_bg_init
        jsr render_enable
        jsr palette_fade_in_init
        ; XXX testing
        ;jsr audio_init_song
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
	jsr attract_enemy_spawn
	jsr get_enemy_slot_4_sprite
        cmp #$ff
        beq .no_enemy_spawn
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
        
        
        
        
attract_enemy_spawn: subroutine
	; 1 sprite enemy slots
        lda enemy_slot_1_next
        cmp #$ff
        beq .no_1_sprite_spawn
        tax
        lda rng0
        lsr
        and #$07
        cmp #$01
        beq .spawn_zigzag
        cmp #$02
        beq .spawn_skeet
        cmp #$03
        beq .spawn_spark
        jsr birb_spawn
        rts
.spawn_bat
	jsr bat_spawn
        rts
.spawn_zigzag
	jsr zigzag_spawn
        rts
.spawn_skeet
	jsr skeet_spawn
        rts
.spawn_spark
	jsr spark_spawn
        rts
.no_1_sprite_spawn

	; 2 sprite enemy slots
        lda enemy_slot_2_next
        cmp #$ff
        beq .4_sprite_slots
        tax
        lda wtf
        and #$01
        beq .no_maggs_spawn
        jsr maggs_spawn
        rts
.no_maggs_spawn
	jsr chomps_spawn
	rts

	; 4 sprite enemy slots
.4_sprite_slots
        lda enemy_slot_4_next
        cmp #$ff
        beq .no_bigs_spawn
        tax
        lda rng0
        jsr NextRandom
        sta rng0
        and #$03
        cmp #$00
        beq .spawn_starglasses
        cmp #$01
        beq .spawn_skully
        cmp #$02
        beq .spawn_throber
        jsr dumbface_spawn
        jmp .no_bigs_spawn
.spawn_skully
        jsr skully_spawn
        jmp .no_bigs_spawn
.spawn_starglasses
        jsr starglasses_spawn
        jmp .no_bigs_spawn
.spawn_throber
	;jsr throber_spawn
.no_bigs_spawn
	rts
        
        


        