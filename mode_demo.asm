


demo_time: subroutine
	; read user controls even in demo mode!
	jsr player_change_speed
        
        ; start should return to menu in demo mode
        lda player_start_d
        cmp #$ff
        bne .player_check_for_dead
        jsr title_screen_init
        jmp .done_and_paused
        
.player_check_for_dead
	; MOCKUP DEATH SEQUENCE
        lda player_health
        cmp #$00
        bne .player_not_dead
.player_dead
	lda #$00
        sta player_lives
	jmp .player_dead_anim
        
.player_not_dead
	; push the shoot button
        lda timer_frames_10s
        and #$02
        cmp #$02
        bne .dont_shoot
	lda #$ff
        sta player_b_d
.dont_shoot
        jsr set_player_sprite
        
;; XXX FORCE QUICK DEATH
        lda #$04
        sta player_damage
        ;jsr player_take_damage
        
        jmp .done
        
.player_dead_anim
        jsr death_scroll_speed
        lda player_death_flag
        cmp #$00
        bne .death_already_set
        jsr sfx_player_death
        lda #$01
        sta player_death_flag
        ; "YOU DEAD"
        ldy #$00
        jsr dashboard_message_set
        jmp .done
.death_already_set
	inc you_dead_counter
        lda you_dead_counter
        cmp #120
        bne .still_dead
        
        ; GO BACK TO TITLE SCREEN 
        ; AFTER DEATH SEQUENCE
        jsr title_screen_init
.still_dead
.done
        jsr update_enemies
        ; spawn enemies
.done_and_paused
	rts
        
        
        
        
demo_enemy_spawn: subroutine
	;jmp .no_1_sprite_spawn
	jsr get_enemy_slot_1_sprite
        cmp #$ff
        beq .no_1_sprite_spawn
        tax
        lda rng0
        lsr
        and #$03
        cmp #$00
        beq .spawn_bat
        cmp #$01
        beq .spawn_zigzag
        cmp #$02
        beq .spawn_skeet
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
.no_1_sprite_spawn
	jsr get_enemy_slot_2_sprite
        cmp #$ff
        beq .no_maggs_spawn
        tax
        jsr maggs_spawn
.no_maggs_spawn
	jsr get_enemy_slot_4_sprite
        cmp #$ff
        beq .no_bigs_spawn
        tax
        lda rng0
        jsr NextRandom
        sta rng0
        and #$03
        cmp #$00
        beq .spawn_starglasses
        jsr skully_spawn
        jmp .no_bigs_spawn
.spawn_starglasses
        jsr starglasses_spawn
.no_bigs_spawn
	rts
        
        


        