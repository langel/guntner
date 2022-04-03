
  
apu_init: subroutine
        ; Init $4000-4013
        ldy #$13
.loop  
	lda apu_default_register_values,y
        sta $4000,y
        dey
        bpl .loop
 
        ; We have to skip over $4014 (OAMDMA)
        lda #$0f
        sta $4015
        lda #$40
        sta $4017
   
        rts
        
apu_default_register_values:
        .byte $30,$08,$00,$00
        .byte $30,$08,$00,$00
        .byte $80,$00,$00,$00
        .byte $30,$00,$00,$00
        .byte $00,$00,$00,$00
        
        
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
        
	lda #%00001111
        sta $400c
        lda #%00000100
        sta $400e
        lda #%01111000
        sta $400f
        
; enemy death*
; enemy damage*
; player fires*
; player damage*
; player death*
        
        
apu_game_frame: subroutine
	; XXX experiment
	; powerup hit
	lda apu_temp
        beq .not_powerup_hit
        jmp sfx_powerup_hit_frame
.not_powerup_hit
	lda sfx_frame_id
        cmp #$00
        bne .active_sfx
        rts
.active_sfx
	cmp #$01
        bne .not_enemy_death
        jmp sfx_enemy_death_frame
.not_enemy_death
	cmp #$02
        bne .not_player_death
        jmp sfx_player_death_frame
.not_player_death
	cmp #$03
        bne .not_powerup_pickup
    	jmp sfx_powerup_pickup_frame
.not_powerup_pickup
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
	jsr sfx_battery_hit
.dont_increase_counter
	lda apu_temp
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$30
        sta $109
        lda apu_temp
        and #$0f
        clc
        adc #$30
        sta $10a
        rts
        
 
     
; NOISE CHANNEL
;$400C	--LC VVVV	Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
;$400D	---- ----	Unused
;$400E	L--- PPPP	Loop noise (L), noise period (P)
;$400F	LLLL L---	Length counter load (L)
        

        
; PULSE CHANNELS
;$4000 / $4004	DDLC VVVV	Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
;$4001 / $4005	EPPP NSSS	Sweep unit: enabled (E), period (P), negate (N), shift (S)
;$4002 / $4006	TTTT TTTT	Timer low (T)
;$4003 / $4007	LLLL LTTT	Length counter load (L), timer high (T)
        
apu_trigger_title_screen_chord: subroutine
	;rts
        ; setup pulse 1
	lda #%10001111
        sta $4000
        lda #$00
        sta $4001
        lda rng0
        and #%00001111
        clc
        adc #$10
        tax
        lda periodTableLo,x
        sta $4002
        lda periodTableHi,x
        ora #%00001000
        sta $4003
        ; setup pulse 2
	lda #%10001111
        sta $4004
        lda #$00
        sta $4005
        lda rng1
        and #%00001111
        clc
        adc #$08
        tax
        lda periodTableLo,x
        sta $4006
        lda periodTableHi,x
        ora #%00001000
        sta $4007
        ; setup triangle
	lda #%01111111
        sta $4008
        lda rng2
        and #%00001111
        clc
        adc #$08
        tax
        lda periodTableLo,x
        sta $400a
        lda periodTableHi,x
        ora #%00001000
        sta $400b
	rts
        
apu_game_music_init: subroutine
	lda #$ff
        sta audio_frame_counter
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
	lda phase_current
        clc
        adc #$11
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
	lda #%10000011
        sta $4000
        lda #$00
        sta $4001
        lda rng2
        and #%00000111
        clc
        adc audio_root_tone
        tax
        lda octoscale,x
        clc
        adc #$0c
        tax
        lda periodTableLo,x
        sta $4002
        lda periodTableHi,x
        ora #%01000000
        sta $4003
.no_pulse_lead
	; triangle
	lda #%00001111
        sta $4008
        lda audio_root_tone
        clc
        adc #$18
        tax
        lda periodTableLo,x
        sta $400a
        lda periodTableHi,x
        ;ora #%01010000
        sta $400b
        dec audio_pattern_pos
.do_nothing
	;dec audio_frame_counter
	rts
        
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

; 00  10
; 01 254
; 02  20
; 03   2
; 04  40
; 05   4
; 06  80
; 07   6
; 08 160
; 09   8
; 0a  60
; 0b  10
; 0c  14
; 0d  12
; 0e  26
; 0f  14
; 10  12
; 11  16
; 12  24
; 13  18
; 14  48
; 15  20
; 16  96
; 17  22
; 18 192
; 19  24
; 1a  72
; 1b  26
; 1c  16
; 1d  28
; 1e  32
; 1f  30
  