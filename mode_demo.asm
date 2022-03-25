


demo_init:
	jsr game_init_generic
        lda #1
        sta player_lives
        lda #5
        jsr state_update_set_addr
        lda #$ff
        sta demo_true
  ; SCROLL SPEED
  	lda #$07
        sta scroll_speed
        asl
        asl
        asl
        sta scroll_speed_m
        jsr starfield_bg_init
        jsr render_enable
        jsr palette_fade_in_init
        rts
        
        

demo_update: subroutine
	lda player_lives
        cmp #$00
        beq .done

        ; some buttons return to menu
        lda player_start_d
        ora player_a_d
        ora player_b_d
        cmp #$ff
        bne .menu_return_buttons_not_pressed
        lda #0
	jsr palette_fade_out_init
	jmp state_update_done
.menu_return_buttons_not_pressed
	;jsr demo_enemy_spawn
	jsr get_enemy_slot_4_sprite
        cmp #$ff
        beq .no_enemy_spawn
        jsr starglasses_spawn
.no_enemy_spawn
        jsr player_demo_controls
.done
	jsr game_update_generic
	jmp state_update_done
        
        
        
        
demo_enemy_spawn: subroutine
	;jmp .no_1_sprite_spawn
        lda enemy_slot_1_next
        cmp #$ff
        beq .no_1_sprite_spawn
        tax
        lda rng0
        lsr
        and #$07
        cmp #$00
        beq .spawn_bat
        cmp #$01
        beq .spawn_zigzag
        cmp #$02
        beq .spawn_skeet
        cmp #$03
        beq .spawn_chomps
        cmp #$04
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
.spawn_chomps
	jsr chomps_spawn
        rts
.spawn_spark
	jsr spark_spawn
        rts
.no_1_sprite_spawn
        lda enemy_slot_2_next
        cmp #$ff
        beq .no_maggs_spawn
        tax
        jsr maggs_spawn
.no_maggs_spawn
	rts

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
        jsr dumbface_spawn
        jmp .no_bigs_spawn
.spawn_skully
        jsr skully_spawn
        jmp .no_bigs_spawn
.spawn_starglasses
        jsr starglasses_spawn
.no_bigs_spawn
	rts
        
        


        