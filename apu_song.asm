
song_rng_chord		EQM $00
song_sick_dingle	EQM $01
song_in_game		EQM $02
song_boss_intro		EQM $03
song_boss_fight		EQM $04
song_game_over		EQM $05
song_end_bad		EQM $06
song_end_ok		EQM $07
song_end_good		EQM $08



song_update: subroutine
	lda options_music_on
        bne .music_on
        rts
.music_on
        lda audio_song_id
        clc
        adc #song_update_jump_table_offset
        jmp jump_to_subroutine

        
song_start: subroutine
	; a = song id
	sta audio_song_id
        bne .not_rng_chords
        jsr sfx_rng_chord
        rts
.not_rng_chords
        lda #$01
        sta options_music_on
	cmp audio_song_id
        bne .normal
        ; sick dingle music init
        lda #$70
        sta audio_frame_counter
        lda #$02
        sta audio_root_tone
        lda #$04
        sta audio_pattern_pos
        lda #$30
        sta apu_rng1
        lda #$44
        sta apu_rng0
        rts
.normal
	lda #0
        sta audio_frame_counter
        sta audio_root_tone
        sta audio_pattern_pos
        jsr apu_rng_reset
        rts
        
song_stop: subroutine
        lda #$00
        sta options_music_on
	rts
        
song_unstop: subroutine
        lda #$01
        sta options_music_on
	rts
        
        
        
song_01_lda_note: subroutine
	; x = note offset
        ; returns note id in a
        lda apu_temp
        beq .octoscale
.majorpentscale
	lda majpentscale,x
        rts
.octoscale
	lda octoscale,x
        rts
        

; sick dingle
song_01: subroutine
        lda #$11
        clc
        adc audio_frame_counter
        sta audio_frame_counter
        bcc .do_nothing
        lda #$0a
        sta audio_frame_counter
        lda audio_pattern_pos
        bne .trigger_note
        ; change the note
        lda #$08
        sta audio_pattern_pos
.update_root_note
        lda apu_rng1
        and #%00000111
        tax
        jsr song_01_lda_note
        sta audio_root_tone
.trigger_note
        ; pulse 1
        lda apu_rng1
        and #%0000001
        bne .no_pulse_lead
        lda #$20
        sta apu_pu1_counter
        lda #$00
        sta apu_pu1_envelope
        lda apu_rng0
        and #%00000111
        clc
        adc audio_root_tone
        tax
        jsr song_01_lda_note
        clc
        adc #12
        tax
        ldy #$02
        jsr apu_set_pitch
.no_pulse_lead
	; pulse 2
        lda sfx_pu2_counter
        bne .no_pulse_rhythm
        lda #$04
        and apu_rng1
        bit audio_pattern_pos
        beq .no_pulse_rhythm
        lda #$10
        sta apu_pu2_counter
        lda #$00
        sta apu_pu2_envelope
        ldx audio_root_tone
        jsr song_01_lda_note
        clc
        adc #24
        tax
        ldy #$06
        jsr apu_set_pitch
.no_pulse_rhythm
	; triangle
	lda #$03
        sta apu_tri_counter
        lda audio_root_tone
        clc
        adc #$18
        tax
        ldy #$0a
        jsr apu_set_pitch
        dec audio_pattern_pos
.do_nothing
        lda #$00
        sta apu_temp
	rts
        
        
        
; in game
song_02: subroutine
	lda wtf
        and #$07
        beq .do_this_shit
        rts
.do_this_shit
	; options screen decrease player health
        lda state_render_addr
        cmp #state_render_jump_table_offset+1
        bne .not_menu_screens
        dec player_health
.not_menu_screens
	; triangle
        lda audio_pattern_pos
        eor rng1
        and #7
        beq .no_triangle
        ; change note length based on health?
        lda player_health
        eor #$ff
        lsr
        lsr
        lsr
        lsr
        lsr
        adc #$02
	;lda #$05 ; original length
        sta apu_tri_counter
        lda audio_root_tone
        clc
        adc #24
        sta apu_temp
        lda audio_pattern_pos
        and #1
        bne .no_octave
        lda apu_temp
        adc #12
        sta apu_temp
.no_octave
        ldx apu_temp
        lda octoscale,x
        ldy #$0a
        jsr apu_set_pitch
.no_triangle
        ; pulse lead
;        lda sfx_pu1_counter
;        bne .no_pulse_lead
;        lda sfx_pu2_counter
;        bne .no_pulse_lead
;        lda apu_rng0
;        and #$01
        ;bne .no_pulse_lead
;        lda apu_rng1
;        and #%00000001
;        beq .no_pulse_lead
;        lda #$0e
;        sta apu_pu1_counter
;        lda #$0c
;        sta apu_pu2_counter
;        lda #$05
;        sta apu_pu1_envelope
;        sta apu_pu2_envelope
;        lda apu_rng0
;        and #%00000111
;        clc
;        adc audio_root_tone
;        tax
;        lda octoscale,x
;        clc
;        adc #24
;        tax
;        ldy #$02
;        jsr apu_set_pitch
;        txa
;        adc #19
;        tax
;        ldy #$06
;        jsr apu_set_pitch
;.no_pulse_lead
        ; kick
        lda audio_pattern_pos
        bne .no_kick
        jsr sfx_kick
.no_kick
	; check for sfx noise
        lda sfx_noi_counter
        bne .no_noise
	; hats
        lda apu_rng0
        and #6
        beq .no_hat
        jsr sfx_hat
.no_hat
	; ghost snare
        lda rng0
        and #$c
        bne .no_g_snare
        jsr sfx_ghost_snare
.no_g_snare
	; snare
        lda audio_pattern_pos
        cmp #6
        bne .no_snare
.do_snare
        jsr sfx_snare
.no_snare
.no_noise
        ; next tic
        inc audio_pattern_pos
        lda audio_pattern_pos
        cmp #12
        bne .done
        lda apu_rng0
        and #$07
        sta audio_root_tone
        lda #0
        sta audio_pattern_pos
       	inc audio_frame_counter
        lda #24
        cmp audio_frame_counter
        bne .done
        jsr apu_rng_reset
        lda #0
        sta audio_frame_counter
.done
	rts
        


; boss intro 
song_03: subroutine
	lda wtf
        and #$07
        bne .done
        lda audio_pattern_pos
        cmp #$08
        bne .next_step
        jsr song_stop
        rts
.next_step
	inc audio_pattern_pos
	lda #0
        sta apu_pu1_envelope
        sta apu_pu2_envelope
	lda #$40
        sta apu_pu1_counter
        sta apu_pu2_counter
        sta apu_tri_counter
.set_pitch
	inc audio_root_tone
        lda audio_root_tone
        clc
        adc #4
        sta apu_temp
        tax
        lda octoscale,x
        adc #12
        tax
        ldy #2
        jsr apu_set_pitch
        lda apu_temp
        adc #15
        tax
        ldy #6
        jsr apu_set_pitch
        ldy #10
        jsr apu_set_pitch
        ; set noise
        lda #$f
        sbc audio_pattern_pos
        sta apu_cache+$e
	lda #$00
        sta apu_noi_envelope
        lda #$40
        sta apu_noi_counter
.done
	rts
        


; boss fight
song_04: subroutine
	lda audio_frame_counter
        cmp #5
        beq .do_all_the_stuff
        jmp .done
.do_all_the_stuff
        lda #0
        sta audio_frame_counter
        inc audio_pattern_pos
        lda audio_pattern_pos
        cmp #18
        bne .dont_loop
.do_loop
        ; TENSION ANTI_MELODY
        lda audio_pattern_num
        and #$04
        bne .root_raise
.root_lower
	inc audio_root_tone
        bne .root_done
.root_raise
	dec audio_root_tone
.root_done
	lda #0
        sta audio_pattern_pos
	inc audio_pattern_num 
.dont_loop
	; KICK (pulse 2)
        lda audio_pattern_pos
        bne .no_kick
        jsr sfx_kick
.no_kick
	; SNARE
        lda audio_pattern_pos
        cmp #10
        beq .snare
        lda rng0
        and #7
        beq .snare
        bne .no_snare
.snare
        jsr sfx_snare
.no_snare
        ; TENSION ANTI_MELODY (pulse 1)
        lda sfx_pu1_counter
        bne .no_melody
	lda #6
        sta apu_pu1_envelope
	lda #$05
        sta apu_pu1_counter
        ldx audio_root_tone
        lda apu_rng1
        lsr
        and #$08
        beq .change_root
        txa
        bne .stay_root
.change_root
        lda apu_rng0
        and #$07
        sta temp00
        txa
        adc temp00
.stay_root
        clc
        adc #36
        tax
        ldy #$02
        jsr apu_set_pitch
.no_melody
	; BASSLINE
        ldx audio_pattern_pos
        ldy song_04_length,x
        beq .done
        ; chance of staccato
        lda apu_rng0
        and #$0c
        bne .full_length
        ldy #$02
.full_length
        sty apu_tri_counter
        lda song_04_pitch,x
        clc
        adc #24
        sta apu_temp
        lda audio_pattern_num
        and #4
        lsr
        adc apu_temp
        tax
        ldy #10
        jsr apu_set_pitch
        ; hats in unison with bassline
        jsr sfx_hat
        ; we're done
.done
	inc audio_frame_counter
	rts
song_04_pitch:
	byte 12,0,17,0,0,12,12,0,17,0,0,15,0,0,13,0,0,12
song_04_length:
	byte 18,0,10,0,0, 3,18,0,10,0,0, 8,0,0, 8,0,0, 3
        
        
        
; game over        
song_05: subroutine
	lda audio_frame_counter
        cmp #$ff
        bne .do_normal
        lda #$00
        sta ppu_mask_emph
        rts
.do_normal
	jsr apu_bend_down
	jsr apu_bend_down
	lda audio_frame_counter
        cmp #$70
        beq .do_chord
        cmp #$40
        beq .do_chord
        cmp #$30
        beq .do_chord
        cmp #$10
        beq .do_chord
	lda audio_frame_counter
        bne .done
        jsr sfx_snare
.do_chord
        jsr sfx_rng_chord
        jsr ppu_mess_emph
        inc ppu_mask_emph
.done
	inc audio_frame_counter
	rts
        
        
; ending bad
song_06: subroutine
	; rng chord about every 2 seconds (bends down)
	jsr apu_bend_down
	jsr apu_bend_down
	lda audio_frame_counter
        and #$7d
        bne .no_chord
        jsr sfx_rng_chord
.no_chord
	inc audio_frame_counter
	rts
        
        
; ending ok
song_07: subroutine
	; sick dingle but different seed and bends down
	jsr apu_bend_down
        jsr song_01
	rts
        
        
; ending good
song_08: subroutine
	inc apu_temp
        jsr song_01
	rts