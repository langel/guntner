

;phase_kill_count	byte
;phase_current		byte
;phase_state		byte
;phase_table_ptr	byte
;phase_spawn_type	byte
;phase_spawn_counter	byte
;phase_large_counter	byte
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
	; XXX debugging
	;jsr demo_phase_skip_after_time    
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
        jsr phase_palette_load
.not_next_level
        ; increase star speed
        lda #53
        clc
        adc scroll_speed_lo
        sta scroll_speed_lo
        bcc .scroll_hi_done
        inc scroll_speed_hi
.scroll_hi_done
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
        lda phase_boss_palette_offset_table,x
	tax
        ldy #15
        jsr palette_load
        jsr palette_load
.done
	rts
       
        
        
        
; PHASE TYPES
        
phase_zero: subroutine
	lda phase_current
        bne .congration
	lda #$40
        bne .continue
.congration
	lda #$20
.continue
        sta dashboard_message
        inc phase_state
        lda phase_state
        cmp #100
        bne .stay_zero
        lda #$ff
        sta dashboard_message
        jsr phase_next
.stay_zero
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
        cmp #$ff
        beq .dont_spawn
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
        cmp #$ff
        beq .dont_spawn
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
        cmp #$ff
        beq .dont_spawn
.set_and_jump
        jsr phase_spawn_track
        tax
        tya
        jmp enemy_spawn_delegator
.dont_spawn
	rts
        
        
phase_boss_palette_offset_table:
	byte #57, #63, #69, #72
        
phase_boss_fight: subroutine
	; XXX handle boss intro/outro cinematics here
	lda phase_state
        bne .done
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
	inc player_x_hi
	inc player_x_hi
        jsr ppu_mess_emph
.done_messing_emph
	inc phase_spawn_counter
        bne .done

        inc phase_state
        lda #0
        sta ppu_mask_emph
        
        dec scroll_speed_hi
        dec scroll_speed_hi
        ; play boss fight song
        lda #song_boss_fight
        jsr song_start
        ; do a fade in
        jsr palette_fade_in_init
        ; spawn boss
	ldx phase_level
        lda level_boss_table,x
        ldx #$b8
        jmp enemy_spawn_delegator
.done
	rts
        
        
        
        
phase_interval_spawn: subroutine
; LEVEL LARGE ENEMY SPAWN INTERVAL
	; large enemy spawn?
        lda timer_frames_1s
        cmp #char_set_offset
        bne .no_large_enemy
        lda timer_frames_10s
        cmp #char_set_offset
        bne .no_large_enemy
        ; look for 10 second increments
        lda timer_seconds_1s
        cmp #char_set_offset+7
        beq .spawn_large_enemy
        bne .no_large_enemy
.spawn_large_enemy
        jsr get_enemy_slot_4_sprite
        cmp #$ff
        beq .no_large_enemy
        tax
        ldy phase_large_counter
        lda level_enemy_table,y
        bne .dont_reset_large_counter
.reset_large_counter
        ldy #0
        sty phase_large_counter
        lda level_enemy_table,y
.dont_reset_large_counter	
	inc phase_large_counter
        jsr enemy_spawn_delegator
.no_large_enemy
	rts
        
        
        
        
        
        
        
; debugger that quickly shows all phase spawns
; XXX remove before done
demo_phase_skip_after_time: subroutine
	lda ftw
        cmp #0
        bne .done
        lda wtf
        cmp #150
        bne .done
        ; reset wtf/ftw
        lda #0
        sta wtf
        sta ftw
        ; clear all enemies
	lda #$0
        sta temp00
        sta enemy_ram_offset
        lda #$20
        sta enemy_oam_offset
.enemy_clear_loop
	ldx temp00
        lda phase_spawn_table,x
        beq .enemy_clear_skip
        jsr enemy_death
        lda #0
        ldx temp00
        sta phase_spawn_table,x
.enemy_clear_skip
        clc
        lda #$08
        adc enemy_ram_offset
        cmp #$e0
        beq .enemy_clear_done
        sta enemy_ram_offset
        lda #$04
        clc
        adc enemy_oam_offset
        sta enemy_oam_offset
        inc temp00
        bne .enemy_clear_loop
.enemy_clear_done
	jsr phase_next
.done
	rts
        

        

        
        
        
        
	