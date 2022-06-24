

        
apu_song_init: subroutine
	lda audio_song_id
        bne .normal
        ; music init
        lda #$70
        ;lda #$30
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
        
apu_song_update: subroutine
	lda audio_song_id
        bne .normal
        jmp apu_o_g_song
.normal
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
        jsr sfx_enemy_damage
.no_kick
	; hats
        lda apu_rng0
        and #6
        beq .no_hat
        lda apu_rng1
        and #3
        sta apu_cache+$e
        lda #$f
        sta apu_noi_counter
        lda #$05
        sta apu_noi_envelope
.no_hat
	; snare
        lda apu_noi_counter
        cmp #$f
        bne .no_snare
        lda audio_pattern_pos
        cmp #6
        bne .no_snare
        lda #$a
        sta apu_cache+$e
        lda #$06
        sta apu_noi_counter
        lda #$06
        sta apu_noi_envelope
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
        

apu_o_g_song: subroutine
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
        ;inc phase_current
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
