

;phase_spawn_table	EQM $0150


; zp vars

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
        clc
        adc #phase_handlers_jump_table_offset
        jmp jump_to_subroutine



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
        ; check for starfield lumen reset
        lda phase_current
        and #$01
        beq .no_starfield_lumen_reset
        jsr starfield_twinkle_reset
.no_starfield_lumen_reset
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
	; x = enemy ram pos
        stx temp00
        txa
        lsr
        lsr
        lsr
        tax
        inc phase_spawn_table,x
        ldx temp00
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
        ; phase #$40 == game done/end
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
	lda #state_init_jump_table_offset+4
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
        bcs .dont_spawn
        jsr phase_spawn_track
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
        bcs .dont_spawn
        jsr phase_spawn_track
	dec phase_spawn_counter
        inc phase_kill_counter
        lda phase_spawn_type
        jsr enemy_spawn_delegator
.dont_spawn
	rts
        

phase_spawn_long_table:
	byte 8, 16, 12, 24, 16, 32, 20, 40
        
phase_spawn_long: subroutine
	jsr phase_check_next_phase
        jsr phase_check_spawn_frame
        ; phase state > 0 == done spawning
        lda phase_state
        bne .phase_init_done
.init
	; oiriginal kill count calculation
	; 1 + level + difficulty * (4 or 8)
        ; ---------------------------------;
        ; difficulty 	   0    1    2    3
        ; -------------|----|----|----|----;
        ; phase 06	   4    8   12   16
        ; phase 0d	   8   16   24   32
        ; phase 16	   8   12   16   20
        ; phase 1d	  16   24   32   40
        ; phase 26	  12   16   20   24
        ; phase 2d	  24   32   40   48
        ; phase 36	  16   20   24   28
        ; phase 3d        32   40   48   56
        ldx phase_spawn_long_c
        lda phase_spawn_long_table,x
   	; store kill count target and advance state
        sta phase_kill_counter
        inc phase_spawn_long_c
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
        bcs .dont_spawn
.set_and_jump
        jsr phase_spawn_track
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
        
        
phase_boss_assistants_table:
	byte chomps_id, skully_id, maggs_id, muya_id
        
phase_boss_fight_intro:
        lda phase_spawn_counter
        bne .dont_init_cinematics
.init_cinematics
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
        
        ; brighten stars
        lda starfield_color0
        adc #$10
        sta starfield_color0
        lda starfield_color1
        adc #$10
        sta starfield_color1

	; boss spawning this frame
        jsr state_clear 
        inc phase_kill_counter
        lda #0
        sta ppu_mask_emph
        sta phase_spawn_counter
        
        dec scroll_speed_hi
        dec scroll_speed_hi
        ; play boss fight song
        lda #song_boss_fight
        jsr song_start
        ; do a fade in FROM HWITE!! :U
	lda #$37
        sta pal_fade_c
        sta state_from_white
        ; sfx!
        jsr sfx_enemy_death
        ; spawn assistant enemies
        ldx phase_level
        lda phase_boss_assistants_table,x
        sta temp02
        tay
        jsr enemy_slot_from_type
        lda temp02
        jsr enemy_spawn_delegator
        ldy temp02
        jsr enemy_slot_from_type
        lda temp02
        jsr enemy_spawn_delegator
        ; spawn boss
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
        lda phase_boss_dying_sfx_table,y
        jsr sfx_test_delegator
        dec state_v0
        bne .done
        
        ; kill everything on screen
	ldx #$00
        stx enemy_slot_id
        stx enemy_ram_offset
.iteration_loop
	ldx enemy_slot_id
        ldy enemy_slot_offset_to_oam_offset,x
        sty enemy_oam_offset
        ldx enemy_ram_offset
        lda enemy_ram_type,x
        cmp #$03
        bcc .skip_crossbones_transmogrification
        jsr enemy_death_handler
.skip_crossbones_transmogrification
	; setup next loop
        inc enemy_slot_id
        lda #$08
        clc
        adc enemy_ram_offset
        sta enemy_ram_offset
        cmp #$e0
        bne .iteration_loop
        ; setup starfield decceleration
        inc phase_kill_counter
        lda #$40
        sta phase_spawn_counter
        ; reset palettes
        jsr phase_palette_load
        ; setup next scene
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
        ; if seconds == 0 then starglasses possible
        cmp #char_set_offset
        beq .starglasses_possible
        ; if seconds == 1 or 7 then spawn enemy
        cmp #char_set_offset+1
        beq .spawn_enemy
        cmp #char_set_offset+7
        beq .spawn_enemy
        bne .no_enemy
.starglasses_possible
	lda timer_seconds_10s
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
        bcs .no_enemy
	inc phase_interval_counter
        tya
        jsr enemy_spawn_delegator
.no_enemy
	rts
        
phase_interval_spawn_special_4_sprite: subroutine
	jsr get_enemy_slot_4_sprite
        bcs .nope
        tya
        jsr enemy_spawn_delegator
.nope
	rts
        
        
        
        