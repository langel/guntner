

;phase_kill_count	byte
;phase_current		byte
;phase_state		byte
;phase_table_ptr	byte
;phase_spawn_type	byte
;phase_arctang_counter	byte
;phase_spawn_counter	byte
;phase_interval_counter	byte
;phase_end_game		byte



; phase_state : 0 = still spawning


        
; XXX need to try different rates of periodic enemy spawns
; NEW GAME PERIODIC LARGE ENEMY SPAWNS
; every level has a table for periodic enemy spawns
;	enemy id, (repeat); null terminated
;	enemies spawn every nth frame
;	rate could be set by level (and/or difficulty)

phase_handling_stuff

        
        
        
        
phase_handler: subroutine
	; only advance phase activity if player is alive
	lda player_death_flag
        beq .player_not_dead
        rts
.player_not_dead
        ; always check if its time for an interval spawn
        jsr phase_interval_spawn
        ; call the appropriate phase handler
        lda phase_current
        and #$0f
        tax
        lda phase_type_table,x
        tax
        lda phase_handlers_lo,x
        sta temp00
        lda phase_handlers_hi,x
        sta temp01
        jmp (temp00)



; PHASE UTILITIES

phase_check_next_phase: subroutine
	; if phase_state == 0 then
        ; we don't know the kill count yet
	lda phase_state
        beq .not_next_phase
        ; kill_counter > 0 means we need more killing
        lda phase_kill_counter
        bmi .end_of_current_phase
        beq .end_of_current_phase
.not_next_phase
        rts
.end_of_current_phase
	; use phase_state as a timer
	inc phase_state
        ; transition time
        lda phase_state
        cmp #$20
        bne .dont_crossbones
        jsr phase_clear_1_sprite_spawns
        jsr sfx_enemy_death
.dont_crossbones
        lda phase_state
        ; wait ~60 frames before trigger next phase sfx
        cmp #$40
        bne .dont_trigger_sfx
     	jsr sfx_phase_next
.dont_trigger_sfx
        lda phase_state
        ; wait ~64 frames before starting next phase
        ; this should be synced with sfx 2nd chime
        cmp #$44
        bne .not_next_phase
	; next phase process
        
phase_next: subroutine
	; reset phase vars
        lda #$00
        sta phase_kill_counter
        sta phase_spawn_counter
        sta phase_state
	inc phase_current
        ; set phase level
        lda phase_current
        and #$0f
        bne .not_next_level
        inc phase_level   
.not_next_level
	jsr starfield_speed_increase
        jsr phase_palette_load
	pla
        pla
	rts

phase_check_spawn_frame: subroutine
	lda wtf
        and #$07
        beq .spawn_frame_go
        pla
        pla
        rts
.spawn_frame_go
	rts
        
phase_clear_1_sprite_spawns: subroutine
; all small enemies spawned by phase become crossbones
	sec
        ldy #$0f
        ldx #$78
.clear_spawn_loop
        lda phase_spawn_table,y
        beq .prep_next_loop
        lda #0
        sta phase_spawn_table,y
        lda #crossbones_id
        sta enemy_ram_type,x
.prep_next_loop
        txa
        sbc #$08
        tax
        dey
        bpl .clear_spawn_loop
	rts

phase_spawn_track: subroutine
	; a = enemy ram pos
        ; kills x
        sta temp00
        lsr
        lsr
        lsr
        tax
        inc phase_spawn_table,x
        lda temp00
        rts
        
phase_palette_load: subroutine
	; each level has its own palette
	ldy phase_level
        ldx palette_level_offset_table,y
	ldy #15
        jsr palette_load
        jsr palette_load
        jsr palette_load
        ; boss phases have palettes too!
        lda phase_current
        and #$0f
        cmp #$0f
        bne .done
        ldx phase_level
        lda palette_boss_offset_table,x
	tax
        ldy #15
        jsr palette_load
        jsr palette_load
.done
	rts
       
        
        
        
; PHASE TYPES
        
phase_zero: subroutine
	jsr phase_check_next_phase
        lda phase_state
        bne .done
	lda phase_current
        bne .congration
	lda #$40
        bne .continue
.congration
	lda #$20
.continue
        sta dashboard_message
        inc phase_spawn_counter
        lda #100
        cmp phase_spawn_counter
        bne .stay_zero
        lda #$ff
        sta dashboard_message
        lda phase_current
        ; XXX this should #$40 for the full game
        cmp #$40
        beq .end_game
        inc phase_state
.stay_zero
.done
	rts
.end_game
        lda #$00
        sta scroll_x_hi
        sta scroll_page
	lda #$04
	jsr palette_fade_out_init
	rts
        
        
phase_galger: subroutine
	jsr phase_check_next_phase
        jsr phase_check_spawn_frame
        ; phase state > 0 == done initializing phase
        lda phase_state
        bne .phase_init_done
        ; set kill counter
        lda phase_level
        asl
        clc
        adc #$06
        sta phase_kill_counter
        sta phase_spawn_counter
        ; set arctang sequence and advance
        lda phase_arctang_counter
        and #$0f
        tax
        jsr arc_sequence_set
        inc phase_arctang_counter
        ; set phase_state to init done
        inc phase_state
.phase_init_done
	lda phase_spawn_counter
        beq .dont_spawn
.do_a_spawn
	jsr get_enemy_slot_1_sprite
        cpx #$ff
        beq .dont_spawn
        txa
        jsr phase_spawn_track
        tax
        lda #galger_id
	sta phase_spawn_type
        jsr enemy_spawn_delegator
        dec phase_spawn_counter
.dont_spawn
	rts


phase_spawns: subroutine
	jsr phase_check_next_phase
        jsr phase_check_spawn_frame
        ; phase state > 0 == done spawning
	lda phase_state
        bne .dont_spawn
        ; if downcounter > 0 then spawn
        lda phase_spawn_counter
        bne .do_spawn
        ; check for next spawn type
        ldy phase_table_ptr
        inc phase_table_ptr
        lda phase_enemy_table,y
        ; if type == 0 then stop spawning
        bne .next_spawn_type
        inc phase_state
        ; phase_state should be 1 now
        bne .dont_spawn
.next_spawn_type
	sta phase_spawn_type
        ; load number to spawn
        ldy phase_table_ptr
        inc phase_table_ptr
        lda phase_enemy_table,y
        sta phase_spawn_counter
.do_spawn
        ldy phase_spawn_type
        jsr enemy_slot_from_type
        cpx #$ff
        beq .dont_spawn
        txa
        jsr phase_spawn_track
        tax
	dec phase_spawn_counter
        inc phase_kill_counter
        lda phase_spawn_type
        jsr enemy_spawn_delegator
.dont_spawn
	rts
        
        
        
phase_spawn_long: subroutine
	jsr phase_check_next_phase
        jsr phase_check_spawn_frame
        ; phase state > 0 == done spawning
        lda phase_state
        bne .phase_init_done
.init
	; kill count calculation
	; 1 + level + difficulty * (4 or 8)
        clc
	lda #1
        adc phase_level
        adc game_difficulty
        sta temp00
        ; store low digit of current phase
        lda phase_current
        and #$0f
        sta temp01
        ; get multiplier
        ldx #8
        cpx temp01
        bcc .mult_set
        ldx #4
.mult_set
	lda #0
.kill_count_loop
	clc
        adc temp00
        dex
        bne .kill_count_loop
   	; store kill count target and advance state
        sta phase_kill_counter
        inc phase_state
.phase_init_done
	; make sure state is 1 or dont spawn
	cmp #$01
        bne .dont_spawn
        lda phase_level
        cmp #$03
        bne .not_final_level
.final_level_spawn_rng
        jsr get_next_random
        lsr
        and #$03
        beq .final_level_spawn_rng
        sec
        sbc #$01
.not_final_level
	clc
        adc #spark_id
        tay
	jsr get_enemy_slot_1_sprite
        cpx #$ff
        beq .dont_spawn
.set_and_jump
	txa
        jsr phase_spawn_track
        tax
        tya
        jmp enemy_spawn_delegator
.dont_spawn
	rts
        
        
        
        
phase_boss_fight: subroutine
	; handle boss intro/outro cinematics here
        ; phase_spawn_counter = scene timer
        ; phase_kill_counter = which scene
        lda phase_kill_counter
        bne .not_intro
        jmp phase_boss_fight_intro
.not_intro
	cmp #$02
        bne .not_cooldown
        jmp phase_boss_fight_cooldown
.not_cooldown
	lda boss_death_happening
        beq .not_death
        jmp phase_boss_dying
.not_death
	rts
        
        
phase_boss_fight_intro:
        lda phase_spawn_counter
        bne .dont_init_cinematics
.init_cinematics
        ; brighten stars
        ldx #$07
.star_lumen_loop
	lda palette_cache,x
        clc
        adc #$10
        sta palette_cache,x
        dex
        bne .star_lumen_loop
        ; play boss fight encounter jingle
        lda #song_boss_intro
        jsr song_start
        ; increase scroll speed
        inc scroll_speed_hi
        inc scroll_speed_hi
        inc scroll_speed_hi
        ; set spawn_counter timing
        lda #$a0
        sta phase_spawn_counter
.dont_init_cinematics
	; WHOOOOOSH!!~
	inc player_x_hi
	inc player_x_hi
        lda player_x_hi
        cmp #232
        bcc .right_max
        lda #230
        sta player_x_hi
.right_max
        jsr ppu_mess_emph
.done_messing_emph
	inc phase_spawn_counter
        bne .done

        inc phase_kill_counter
        lda #0
        sta ppu_mask_emph
        sta phase_spawn_counter
        
        dec scroll_speed_hi
        dec scroll_speed_hi
        ; play boss fight song
        lda #song_boss_fight
        jsr song_start
        ; do a fade in
        ; XXX a fade from white would be better!
        jsr palette_fade_in_init
        ; spawn boss
        jsr state_clear ; a = 0
	ldx phase_level
        lda level_boss_table,x
        ldx #$b8
        jmp enemy_spawn_delegator
.done
	rts
        
        
phase_boss_dying_sfx_table:
	hex 03 06 0d 11
        
phase_boss_dying: subroutine
	lda phase_spawn_counter
        bne .dont_init
        ; stop music
        jsr song_stop
        ; calculate length of boss death
        ; 8 frame increments
        lda phase_level
        clc
        adc #$02
        asl ; ( phase level + 2 ) * 2 = 4, 6, 8, 10
        adc #$08 ; + 8 = 12, 14, 16, 18
        sta state_v0
        inc phase_spawn_counter
.dont_init
	ldy #8
.rng_pal_loop
	jsr get_next_random
        lsr
        and #%00111100
        sta pal_spr_1_1,y
        dey
        bpl .rng_pal_loop
        ; spawn a sfx every 8th frame
	jsr phase_check_spawn_frame
        lda rng1
        and #$03
        tay
        ldx phase_boss_dying_sfx_table,y
        jsr sfx_test_delegator
        dec state_v0
        bne .done
        ; boss dead do stuff
        lda #$00
.boss_dead_kill_all
	tax
        lda #crossbones_id
        sta enemy_ram_type,x
        ldy temp00
        txa
	cmp #$a0
        bcc .not_4_sprites
        sta temp00
        lsr
        lsr
        lsr
        tax
        ldy enemy_slot_offset_to_oam_offset,x
        ldx temp00
        jsr sprite_4_dead_cleanup
        lda temp00
.not_4_sprites
        clc
        adc #$08
        cmp #$e0
        bne .boss_dead_kill_all
        inc phase_kill_counter
        lda #$40
        sta phase_spawn_counter
        ; setup next scene
        jsr phase_palette_load
        jsr sfx_enemy_death
        jsr powerup_pickup_plus_one
        ; startup in game music
        lda #song_in_game
        jsr song_start
        ; let crossbones animate
        lda #$00
        sta boss_death_happening
.done
	rts
        
        
phase_boss_fight_cooldown: subroutine
	lda phase_spawn_counter
        and #$0f
        bne .dont_slow_stars
        dec scroll_speed_hi
.dont_slow_stars
	dec phase_spawn_counter
        bne .dont_advance
        lda #$00
        sta boss_death_happening
        sta boss_heart_stars
        sta boss_dmg_handle_true
        sta phase_kill_counter
        lda #song_in_game
        jsr song_start
        jsr phase_next
        ; dim stars
        ldx #$07
.star_lumen_loop
	lda palette_cache,x
        sec
        sbc #$10
        sta palette_cache,x
        dex
        bne .star_lumen_loop
.dont_advance
	rts
        
        
        
        
        
phase_interval_spawn: subroutine
	; dont spawn if boss is dying
	lda boss_death_happening
        bne .no_enemy
	; check for ike's mom spawn
        lda ftw
        ;cmp #84 ; about 6 minutes
        cmp #42 ; about 3 minutes
        bcc .no_ikes_mom
        ldy #ikes_mom_id
        bne phase_interval_spawn_special_4_sprite
.no_ikes_mom
	; interval enemy spawn?
        lda timer_frames_1s
        cmp #char_set_offset
        bne .no_enemy
        lda timer_frames_10s
        cmp #char_set_offset
        bne .no_enemy
        ; look for 10 second increments
        lda timer_seconds_1s
        cmp #char_set_offset
        beq .starglasses_possible
        cmp #char_set_offset+1
        beq .spawn_enemy
        cmp #char_set_offset+7
        beq .spawn_enemy
        bne .no_enemy
.starglasses_possible
	lda timer_seconds_10s
        ;and #$01
        cmp #char_set_offset+3
        beq .starglasses_happening
        cmp #char_set_offset+5
        bne .no_enemy
.starglasses_happening
        ldy #starglasses_id
        bne phase_interval_spawn_special_4_sprite
.spawn_enemy
	ldy phase_level
	lda level_intervals_lo,y
        sta temp02
	lda level_intervals_hi,y
        sta temp03
        ldy phase_interval_counter
        lda (temp02),y
        bne .dont_reset_counter
.reset_counter
        sta phase_interval_counter
        lda (temp02),y
.dont_reset_counter	
	tay
        jsr enemy_slot_from_type
        cpx #$ff
        beq .no_enemy
	inc phase_interval_counter
        tya
        jsr enemy_spawn_delegator
.no_enemy
	rts
        
phase_interval_spawn_special_4_sprite: subroutine
	jsr get_enemy_slot_4_sprite
        cpx #$ff
        beq .nope
        tya
        jsr enemy_spawn_delegator
.nope
	rts
        
        
        
        