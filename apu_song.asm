
song_rng_chord		EQM $00
song_sick_dingle	EQM $01
song_boss_intro		EQM $02
song_boss_fight		EQM $03

do_nothing_id        EQM $01
crossbones_id        EQM $02



song_update: subroutine
	lda options_music_on
        bne .music_on
        rts
.music_on
        ldx audio_song_id
        lda song_update_table_lo,x
        sta temp00
        lda song_update_table_hi,x
        sta temp01
        jmp (temp00)
song_update_table_lo:
	byte #<do_nothing		; rng chord
        byte #<song_01			; sick dingle
        byte #<song_02			; in game
        byte #<song_03			; boss intro
        byte #<song_04			; boss fight
song_update_table_hi:
	byte #>do_nothing		; rng chord
        byte #>song_01			; sick dingle
        byte #>song_02			; in game
        byte #>song_03			; boss intro
        byte #>song_04			; boss fight

        
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
        cmp #$00
        bne .trigger_note
        ; change the note
        lda #$08
        sta audio_pattern_pos
.update_root_note
        lda apu_rng1
        and #%00000111
        tax
        lda octoscale,x
        sta audio_root_tone
.trigger_note
        ; pulse 1
        lda apu_rng1
        and #%0000001
        cmp #$00
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
        lda octoscale,x
        clc
        adc #$0c
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
        lda octoscale,x
        clc
        adc #$18
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
	;dec audio_frame_counter
	rts
        
        
        
; in game
song_02: subroutine
	lda wtf
        and #$07
        bne .done
	; triangle
        lda audio_pattern_pos
        eor apu_rng0
        and #7
        beq .no_triangle
	lda #$03
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
        lda minorscale,x
        ldy #$0a
        jsr apu_set_pitch
.no_triangle
        ; kick
        lda audio_pattern_pos
        bne .no_kick
        jsr sfx_kick
.no_kick
	; hats
        lda apu_rng0
        and #6
        beq .no_hat
        jsr sfx_hat
.no_hat
	; snare
        lda apu_noi_counter
        cmp #$f
        bne .no_snare
        lda audio_pattern_pos
        cmp #6
        bne .no_snare
        jsr sfx_snare
.no_snare
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
        adc #12
        sta apu_temp
        tax
        lda octoscale,x
        tax
        ldy #2
        jsr apu_set_pitch
        lda apu_temp
        clc
        adc #8
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
	; KICK (pulse 2)
        jsr sfx_kick
.dont_loop
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