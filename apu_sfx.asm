; these should only use Pulse 2 and Noise channels
; unless its a non-music moment (like player death)

; sound test 00
sfx_pewpew: subroutine
	; pulse 2
	;rts
	lda #%10001111
        sta $4004
        lda #%10000010
        sta $4005
        lda #$08
        sta $4006
        lda #%00010000
        sta $4007
	rts

; sound test 01
sfx_player_damage: subroutine
	; noise
	;rts
        lda #%00001111
        sta $400c
        lda #%00001111
        sta $400e
        lda #%00010000
        sta $400f
        rts
        
; sound test 02
sfx_player_death: subroutine
	; noise and?
        ;rts
        ; setup pulse 1
	lda #%10001111
        sta $4000
        lda #%10000111
        sta $4001
        lda #$fc
        sta $4002
        lda #%00001010
        sta $4003
        ; setup pulse 2
	lda #%10001111
        sta $4004
        lda #%10000111
        sta $4005
        lda #$fb
        sta $4006
        lda #%00001001
        sta $4007
        ; setup noise handler
	lda #$02
        sta audio_noise_mode
        sta sfx_frame_id
        lda #$00
        sta audio_noise_volume
        lda #$80
        sta audio_noise_pitch
	rts
        
sfx_player_death_frame: subroutine
        lda audio_noise_volume
        lsr
        lsr
        lsr
        lsr
        and #%00010000
        sta $400c 
        lda audio_noise_pitch
        lsr
        lsr
        lsr
        sta $400e
        lda #%01111000
        sta $400f
        inc audio_noise_pitch
        inc audio_noise_volume
        inc audio_noise_volume
        bne .dont_kill_player_death_sound
        lda #$00
        sta $400c
        sta audio_noise_mode
        sta sfx_frame_id
.dont_kill_player_death_sound
	rts
        
; sound test 04
sfx_enemy_damage: subroutine
	; pulse 2
	;rts
	lda #%10001111
        sta $4004
        lda #%10000010
        sta $4005
        lda #$08
        sta $4006
        lda #%00010001
        sta $4007
	rts
        
; sound test 05
sfx_battery_hit: subroutine
	; turn on counter / set volume
        lda #$0f
        sta $400c
	; mode and pitch
        lda #$82
        sta $400e
        ; set envelope
        lda #$08
        sta $400f
	rts
        
; sound test 06
sfx_powerup_pickup: subroutine
	lda #$03
        sta sfx_frame_id
        lda #$00
        sta sfx_counter
	rts
        
sfx_powerup_pickup_arp:
 .byte	#$1a, #$1d, #$21, #$26

sfx_powerup_pickup_frame: subroutine
	lda sfx_counter
        lsr
        lsr
        cmp #$04
        beq .end_sound
        tax
        lda sfx_counter
        and #%00000011
        bne .dont_trigger
        lda audio_root_tone
        clc
        adc sfx_powerup_pickup_arp,x
        tax
	lda #%10000111
        sta $4004
        lda #$00
        sta $4005
        lda periodTableLo,x
        sta $4006
        lda periodTableHi,x
        ora #%01000000
        sta $4007
        
.dont_trigger
        inc sfx_counter
	rts
.end_sound
	lda #$00
        sta sfx_frame_id
        rts

        
; sound test 03
sfx_enemy_death: subroutine
	; enemy death is noise mode 1
        lda #$01
        sta audio_noise_mode
        sta sfx_frame_id
        lda #$0f
        sta audio_noise_pitch
        sta audio_noise_volume
	rts
        ; XXX wtf?
	lda #%00001111
        sta $400c
        lda #%00000100
        sta $400e
        lda #%01111000
        sta $400f
	rts

sfx_enemy_death_frame: subroutine
        lda audio_noise_pitch
        sta $400e
        lda audio_noise_volume
        and #%00010000
        sta $400c
        lda #%01111000
        sta $400f
        dec audio_noise_pitch
        dec audio_noise_volume
        bne .dont_kill_enemy_death_sound
        lda #$00
        sta $400c
        sta audio_noise_mode
        sta sfx_frame_id
.dont_kill_enemy_death_sound
	rts