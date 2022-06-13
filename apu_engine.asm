        
; PULSE CHANNELS
;$4000 / $4004	DDLC VVVV	Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
;$4001 / $4005	EPPP NSSS	Sweep unit: enabled (E), period (P), negate (N), shift (S)
;$4002 / $4006	TTTT TTTT	Timer low (T)
;$4003 / $4007	LLLL LTTT	Length counter load (L), timer high (T)
        
APU_PULSE1_VOL		= $4000
APU_PULSE1_SWEEP	= $4001
APU_PULSE1_TIMER_LO	= $4002
APU_PULSE1_TIMER_HI	= $4003
APU_PULSE2_VOL		= $4004
APU_PULSE2_SWEEP	= $4005
APU_PULSE2_TIMER_LO	= $4006
APU_PULSE2_TIMER_HI	= $4007

; TRIANGLE CHANNEL
;$4008  CRRR RRRR 	Length counter halt / linear counter control (C), linear counter load (R)
;$4009 	---- ---- 	Unused
;$400A 	TTTT TTTT 	Timer low (T)
;$400B 	LLLL LTTT 	Length counter load (L), timer high (T) 
 
APU_TRI_CONTROL		= $4008
APU_TRI_UNUSED		= $4009
APU_TRI_TIMER_LO	= $400a
APU_TRI_TIMER_HI	= $400b
     
; NOISE CHANNEL
;$400C	--LC VVVV	Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
;$400D	---- ----	Unused
;$400E	L--- PPPP	Loop noise (L), noise period (P)
;$400F	LLLL L---	Length counter load (L)
        
APU_NOISE_VOL   	= $400C
APU_NOISE_FREQ 		= $400E
APU_NOISE_TIMER		= $400F

DMC_FREQ		= $4010
APU_STATUS		= $4015
APU_DMC_CTRL    	= $4010
APU_CHAN_CTRL   	= $4015
APU_FRAME       	= $4017

apu_cache		= $0140
  
  
apu_init: subroutine
        ; Init $4000-4013
        ldy #$13
.loop  
	lda apu_init_register_values,y
        sta apu_cache,y
        sta $4000,y
        dey
        bpl .loop
        ; We have to skip over $4014 (OAMDMA)
        lda #$0f
        sta $4015
        lda #$40
        sta $4017
        rts
        
        
apu_init_register_values:
        .byte $30,$08,$00,$00
        .byte $30,$08,$00,$00
        .byte $80,$00,$00,$00
        .byte $30,$00,$00,$00
        .byte $00,$00,$00,$00
        
octoscale:
	.byte $00,$02,$03,$05,$06,$08,$09,$0b
	.byte $0c,$0e,$0f,$11,$12,$14,$15,$17
        .byte $18,$1a,$1b,$1d,$1e,$20,$21,$23
   
periodTableLo:
  ;      A   A#  B   C   C#  D   D#  E   F   F#  G   G#
  .byte $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34
  .byte $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a
  .byte $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c
  .byte $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86
  .byte $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42
  .byte $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21
  .byte $1f,$1d,$1b,$1a,$18,$17,$15,$14
periodTableHi:
  .byte $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
  .byte $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00
        
apu_set_pitch: subroutine
	; x = pitch table offset
        ; y = channel low byte offset
        lda periodTableLo,x
        sta apu_cache+0,y
        lda periodTableHi,x
        ora #%11111000
        sta apu_cache+1,y
        rts
        
       
apu_env_run: subroutine
	; x = channel counter offset
        ;     envelope type is byte after
        ; #$00 = pu1
        ; #$04 = pu2
        ; #$07 = noise
        ; returns 4-bit volume in a
        ldy apu_pu1_envelope,x
        lda apu_env_table_lo,y
        sta temp00
        lda apu_env_table_hi,y
        sta temp01
        jmp (temp00)
apu_env_table_lo:
	.byte #<apu_env_lin_long
	.byte #<apu_env_lin_short
	.byte #<apu_env_lin_tiny
        .byte #<apu_env_exp_long
        .byte #<apu_env_exp_short
        .byte #<apu_env_exp_tiny
apu_env_table_hi:
	.byte #>apu_env_lin_long
	.byte #>apu_env_lin_short
	.byte #>apu_env_lin_tiny
        .byte #>apu_env_exp_long
        .byte #>apu_env_exp_short
        .byte #>apu_env_exp_tiny
apu_env_lin_long: subroutine
	; #$40 counter = 63 frames / 1 second
        lda apu_pu1_counter,x
        lsr
        lsr
        and #%00001111
	rts
apu_env_lin_short: subroutine
	; #$20 counter = 31 frames / 0.5 second
        lda apu_pu1_counter,x
        lsr
        and #%00001111
	rts
apu_env_lin_tiny: subroutine
	; #$10 counter = 15 frames / 0.25 second
        lda apu_pu1_counter,x
        and #%00001111
	rts
apu_env_exp_long: subroutine
	; #$40 counter =~ 54 frames / 1 second
        ldy apu_pu1_counter,x
        lda sine_table+$c0,y
        lsr
        lsr
        lsr
	rts
apu_env_exp_short: subroutine
	; #$20 counter =~ 28 frames / 0.5 second
        ldy apu_pu1_counter,x
        lda sine_7bits+$60,y
        lsr
        lsr
	rts
apu_env_exp_tiny: subroutine
	; #$10 counter =~ 15 frames / 0.25 second
        ldy apu_pu1_counter,x
        lda apu_env_exp_tiny_table,y
	rts
apu_env_exp_tiny_table:
	.byte $00,$01,$01,$01,$01,$01,$01,$01,
        .byte $01,$01,$02,$03,$08,$0b,$0f
        
        
apu_update: subroutine
; MUSIC
; SFX Pulse 2
; SFX Noise
; MIX and Write to APU

; SFX Update Delegator
	ldx sfx_pu2_update_type
	jsr sfx_update_delegator
	ldx sfx_noi_update_type
	jsr sfx_update_delegator
; Pulse Channels Counter / Envelope
	ldx #$00
.pulse_channels_loop
        lda apu_pu1_counter,x
        beq .pulse_skip
        dec apu_pu1_counter,x
        bne .pulse_enabled
.pulse_disabled
	lda #$30
        sta $4000,x
        jmp .pulse_skip
.pulse_enabled
        jsr apu_env_run
        ora #%10110000
        sta $4000,x
        lda #$08
        sta $4001,x
        lda apu_cache+2,x
        clc
        adc shroom_mod
        sta $4002,x
        lda apu_cache+3,x
        cmp apu_pu1_last_hi,x
        beq .pulse_skip
        sta $4003,x
        sta apu_pu1_last_hi,x
.pulse_skip
	cpx #$00
        bne .pulse_channels_done
        ldx #$04
        bne .pulse_channels_loop
.pulse_channels_done
; Triangle Counter
        lda apu_tri_counter
        beq .triangle_skip
        dec apu_tri_counter
        bne .triangle_enabled
.triangle_disabled
        lda #$00
        sta $4008
        jmp .triangle_skip
.triangle_enabled
	lda #$7f
        sta $4008
        lda apu_cache+$a
        clc
        adc shroom_mod
        sta $400a
.triangle_skip
; Noise Counter
	lda apu_noi_counter
        beq .noise_skip
        dec apu_noi_counter
        bne .noise_enabled
.noise_disabled
	lda #%00010000
        sta apu_cache+12
        jmp .noise_skip
.noise_enabled
	ldx #$07
        jsr apu_env_run
        ora #%00010000
        sta apu_cache+12
.noise_skip
; copy cache to apu
	ldy #$05
.cache_to_apu_loop
	lda apu_cache+$b,y
        sta $4000+$b,y
        dey
        bpl .cache_to_apu_loop
; RNG updates
	lda apu_rng0
        jsr PrevRandom
        sta apu_rng0
	lda apu_rng1
        jsr NextRandom
        sta apu_rng1
; SFX counter updates
	lda sfx_pu2_counter
        beq .skip_sfx_pu2_dec
        dec sfx_pu2_counter
.skip_sfx_pu2_dec
	lda sfx_noi_counter
        beq .skip_sfx_noi_dec
        dec sfx_noi_counter
.skip_sfx_noi_dec
	rts
        
        
; XXX this is awful
; only used during ConGraTioN
apu_make_it_hum: subroutine
        lda #%10110111
        sta $4000
	ldx wtf
        lda sine_table,x
        sta $4003
        lda #%10110111
        sta $4004
	ldx wtf
        lda sine_table,x
        sta $4006
        lda #$15
        sta $4007
	rts
        




; XXX this will definitely go before release
apu_debugger: subroutine
	; dash cache meter is $108-$118
        lda player_select_d
        beq .dont_increase_counter
        dec apu_temp
        bpl .dont_reset_counter
        lda #$1f
        sta apu_temp
.dont_reset_counter
	;jsr sfx_powerup_mushroom
        ;jsr powerup_pickup_mushroom
        jsr sfx_powerup_1up
.dont_increase_counter
	lda apu_temp
        jsr get_char_hi
        sta $109
        lda apu_temp
        and #$0f
        clc
        adc #$30
        sta $10a
        ; pulse1 vol
        lda $400c
        jsr get_char_lo
        sta $10c
        ; noise envelope volume
	lda $14c
        jsr get_char_hi
        sta $10e
	lda $14c
        jsr get_char_lo ; XXX does this save enough?
        sta $10f
        ; sfx update type
        lda sfx_pu2_update_type
        clc
        adc #$30
        sta $111
        ; sfx update type
        lda sfx_noi_update_type
        clc
        adc #$30
        sta $113
        rts
        
        

apu_trigger_title_screen_chord: subroutine
	; used hardware enevelope was 1 second
        ; ~ 64 frame fade
        ; triangle cuts off at 32 frames
        ; setup pulse 1 + 2
        lda #$40
        sta apu_pu1_counter
        sta apu_pu2_counter
        lda #$00
        sta apu_pu1_envelope
        sta apu_pu2_envelope
        ; pulse 1 pitch
        lda rng0
        and #%00001111
        clc
        adc #$10
        tax
        ldy #$02
        jsr apu_set_pitch
        ; pulse 2 pitch
        lda rng1
        and #%00001111
        clc
        adc #$08
        tax
        ldy #$06
        jsr apu_set_pitch
        ; setup triangle
        lda #$20
        sta apu_tri_counter
        lda rng2
        and #%00001111
        clc
        adc #$08
        tax
        ldy #$0a
        jsr apu_set_pitch
	rts
        
        
  
        
audio_init_song: subroutine
        ; music init
        lda #$70
        ;lda #$30
        sta audio_frame_counter
        lda #$02
        sta audio_root_tone
        lda #$04
        sta audio_pattern_pos
        lda #$30
        sta rng1
        lda #$44
        sta rng2
        rts
        
apu_game_music_frame: subroutine
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
        lda rng1
        and #%00000111
        tax
        lda octoscale,x
        sta audio_root_tone
        ;inc phase_current
.trigger_note
        ; pulse 1
        lda rng1
        and #%0000001
        cmp #$00
        bne .no_pulse_lead
        lda #$20
        sta apu_pu1_counter
        lda #$00
        sta apu_pu1_envelope
        lda rng2
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
        and rng1
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
        
  
  
        
;$400C	--LC VVVV	Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
;$400D	---- ----	Unused
;$400E	L--- PPPP	Loop noise (L), noise period (P)
;$400F	LLLL L---	Length counter load (L)

        
;$4000 / $4004	DDLC VVVV	Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
;$4001 / $4005	EPPP NSSS	Sweep unit: enabled (E), period (P), negate (N), shift (S)
;$4002 / $4006	TTTT TTTT	Timer low (T)
;$4003 / $4007	LLLL LTTT	Length counter load (L), timer high (T)
   
  
; envelope lengths
;     |  0   1   2   3   4   5   6   7    8   9   A   B   C   D   E   F
;-----+----------------------------------------------------------------
;00-0F  10,254, 20,  2, 40,  4, 80,  6, 160,  8, 60, 10, 14, 12, 26, 14,
;10-1F  12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30

; envelope length table again
; column order:
; 	id from table above
;	duration in ticks
;	actual register value
; 00  10  00
; 01 254  08
; 02  20  10
; 03   2  18
; 04  40  20
; 05   4  28
; 06  80  30
; 07   6  38
; 08 160  40
; 09   8  48
; 0a  60  50
; 0b  10  58
; 0c  14  60
; 0d  12  68
; 0e  26  70
; 0f  14  78
; 10  12  80
; 11  16  88
; 12  24  90
; 13  18  98
; 14  48  a0
; 15  20  a8
; 16  96  b0
; 17  22  b8
; 18 192  c0
; 19  24  c8
; 1a  72  d0
; 1b  26  d8
; 1c  16  e0
; 1d  28  e8
; 1e  32  f0
; 1f  30  f8
  