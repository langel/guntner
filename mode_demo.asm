
        
player_demo_init: subroutine
; redraw playfield/hud
	; disable rendering
        lda #$00
        sta PPU_MASK	
        jsr nametables_clear
; clear top rows
	PPU_SETADDR $2000
        ldy #$00
        lda #$20
.clear_top_rows
	sta PPU_DATA
        iny
        bne .clear_top_rows
	jsr starfield_init
        jsr dashboard_init
        sta PPU_ADDR
        sta PPU_ADDR	; PPU addr = $0000
        sta PPU_SCROLL
        sta PPU_SCROLL  ; PPU scroll = $0000
	; enable rendering
        lda #MASK_BG|MASK_SPR
        sta PPU_MASK	
        jsr timer_reset
; set player lives
	lda #$01
        sta player_lives
; set player gun strength
	lda #$03
        sta player_gun_str
        
; set player position
	jsr player_game_reset
        rts


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
        jsr apu_trigger_player_death
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
	jsr get_enemy_slot_1_sprite
        cmp #$ff
        beq .no_1_sprite_spawn
        tax
        lda rng0
        and #$01
        cmp #$00
        bne .spawn_bat
        jsr birb_spawn
        rts
.spawn_bat
	jsr bat_spawn
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
        and #$07
        cmp #$00
        beq .spawn_starglasses
        jsr skully_spawn
        jmp .no_bigs_spawn
.spawn_starglasses
        jsr starglasses_spawn
.no_bigs_spawn
	rts
        
        


        
        
; controls player in demo mode    
run_player_demo: subroutine
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
	;lda #%0000110
        ;sta player_dir_bits
	jsr player_move_position
	rts

        
        


