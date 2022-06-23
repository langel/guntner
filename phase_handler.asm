

;phase_kill_count	byte
;phase_current		byte
;phase_state		byte
;phase_table_ptr	byte
;phase_spawn_type	byte
;phase_spawn_counter	byte
;phase_large_counter	byte
;phase_end_game		byte

; phase_state : 0 = still spawning

; level-phase (4 levels)
;	starts at x-1
;	ends at x-9
;	even levels use galgers
;	odd levels spawn other small enemy types
;	x-9 is always a boss fight
;	starglasses spawns at a certain interval
;	larger enemies spawn when?



; OLD DEMO PHASES
; 1: 1 birb
; 2: 2 maggs
; 3: 2 starglasses
; 4: 1 skully
; 5: 2 starglasses, 2 maggs, 4 birbs
; 6: 8 birbs, 4 maggs
; 7: 12 birbs, 3 skullys
; 8: 12 birbs, 1 skully, 2 maggs
; 9: 16 birbs, 6 skullys, 4 maggs, 2 starglasses
        
; NEW GAME LEVEL PHASES PATTERN
; 1: some small enemies
; 2: galger pattern
; 3: some medium enemies
; 4: galger pattern
; 5: constant small spawn -- kill x enemies
; 6: galger pattern
; 7: small, medium, & large spawns
; 8: galger pattern
; 9: boss fight

; NEW GAME PERIODIC LARGE ENEMY SPAWNS
; period could be every so many seconds
; period could vary per level
; each level has a table
; 1: starglasses, starglasses, skully, uzi, starglasses, etc

; every phase has a table for enemy spawns
;	enemy id, enemy count, (repeat); null terminated
;	enemies spawn every 8th frame

; every level has a table for periodic enemy spawns
;	enemy id, (repeat); null terminated
;	enemies spawn every nth frame
;	rate could be set by level (and/or difficulty)


phase_next: subroutine
        lda #$00
        sta phase_kill_counter
        sta phase_state
	inc phase_current
        lda #53
        clc
        adc scroll_speed_lo
        sta scroll_speed_lo
        bcc .scroll_hi_done
        inc scroll_speed_hi
.scroll_hi_done
	rts
        
        
        
phase_handler: subroutine

	jsr demo_phase_skip_after_time        
	lda phase_state
        beq .not_next_phase
        lda phase_kill_counter
        bne .not_next_phase
.next_phase
	jsr phase_next
.not_next_phase

; LEVEL LARGE ENEMY SPAWN INTERVAL
	; large enemy spawn?
        lda timer_frames_1s
        cmp #$30
        bne .no_large_enemy
        lda timer_frames_10s
        cmp #$30
        bne .no_large_enemy
        ; look for 10 second increments
        lda timer_seconds_1s
        cmp #$37
        beq .spawn_large_enemy
        bne .no_large_enemy
        lda timer_seconds_1s
        cmp #$30
        bne .no_large_enemy
        ; XXX look for 20 sec increments
        lda timer_seconds_10s
        cmp #$31
        beq .spawn_large_enemy
        cmp #$33
        beq .spawn_large_enemy
        cmp #$35
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
        ldy #0
        sty phase_large_counter
        lda level_enemy_table,y
.dont_reset_large_counter	
	inc phase_large_counter
        tay
        lda enemy_spawn_table_lo,y
        sta temp02
        lda enemy_spawn_table_hi,y
        sta temp03
        jmp (temp02)
.no_large_enemy


	; check for spawning state
        ; phase_spawn_type
	; phase_spawn_counter
	lda wtf
        ; only spawn every 8th frame
        and #$07
        bne .dont_spawn
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
        jmp .dont_spawn
.next_spawn_type
	sta phase_spawn_type
        ; set arc sequence regardless of type
        lda phase_current
        lsr
        sec
        sbc #1
        tax
        jsr arc_sequence_set
        ; load number to spawn
        ldy phase_table_ptr
        inc phase_table_ptr
        lda phase_enemy_table,y
        sta phase_spawn_counter
.do_spawn
        ldy phase_spawn_type
        lda enemy_spawn_table_lo,y
        sta temp02
        lda enemy_spawn_table_hi,y
        sta temp03
        ldx enemy_size_table,y
        cpx #1
        bne .not_size_1
	jsr get_enemy_slot_1_sprite
        jmp .slot_found_check
.not_size_1
	cpx #2
        bne .not_size_2
	jsr get_enemy_slot_2_sprite
        jmp .slot_found_check
.not_size_2
	jsr get_enemy_slot_4_sprite
.slot_found_check
        cmp #$ff
        beq .skip_spawn
        sta temp00
        lsr
        lsr
        lsr
        tax
        inc phase_spawn_table,x
	dec phase_spawn_counter
        inc phase_kill_counter
        ldx temp00
        jmp (temp02)
.skip_spawn
.dont_spawn
	rts
        
        
        
; debugger that quickly shows all phase spawns
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
        

        

        
        
        
        
	