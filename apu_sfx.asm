; these should only use Pulse 2 and Noise channels
; unless its a non-music moment (like player death)


sfx_update_delegator: subroutine
        ; x = update offset
        lda sfx_update_table_lo,x
        sta temp00
        lda sfx_update_table_hi,x
        sta temp01
        jmp (temp00)
sfx_update_table_lo:
	byte #<do_nothing			; 0
	byte #<sfx_player_death_update		; 1
        byte #<sfx_enemy_death_update		; 2
        byte #<sfx_powerup_battery_update	; 3
        byte #<sfx_powerup_bomb_update		; 4
        byte #<sfx_powerup_1up_update		; 5
        byte #<sfx_phase_next_update		; 6
sfx_update_table_hi:
	byte #>do_nothing
	byte #>sfx_player_death_update
        byte #>sfx_enemy_death_update
        byte #>sfx_powerup_battery_update
        byte #>sfx_powerup_bomb_update
        byte #>sfx_powerup_1up_update
        byte #>sfx_phase_next_update
        
        
        
sfx_test_delegator: subroutine
	; x = sound effect id
        lda sfx_test_table_lo,x
        sta temp00
        lda sfx_test_table_hi,x
        sta temp01
        jmp (temp00)
sfx_test_table_lo:
	byte #<sfx_pewpew			; 00
        byte #<sfx_player_damage		; 01
        byte #<sfx_player_death			; 02
        byte #<sfx_enemy_damage			; 03
        byte #<sfx_enemy_death			; 04
        byte #<sfx_powerup_hit			; 05
        byte #<sfx_powerup_bomb			; 06
        byte #<sfx_powerup_mushroom		; 07
        byte #<sfx_powerup_mask			; 08
        byte #<sfx_powerup_1up			; 09
        byte #<sfx_powerup_battery_25		; 0a
        byte #<sfx_powerup_battery_50		; 0b
        byte #<sfx_powerup_battery_100		; 0c
        byte #<sfx_shoot_dart			; 0d
        byte #<sfx_shoot_bullet			; 0e
        byte #<sfx_rng_chord			; 0f
        byte #<sfx_phase_next			; 10
        byte #<sfx_snare			; 11
        byte #<sfx_hat				; 12
        byte #<sfx_ghost_snare			; 13
sfx_test_table_hi:
	byte #>sfx_pewpew
        byte #>sfx_player_damage
        byte #>sfx_player_death
        byte #>sfx_enemy_damage
        byte #>sfx_enemy_death
        byte #>sfx_powerup_hit
        byte #>sfx_powerup_bomb
        byte #>sfx_powerup_mushroom
        byte #>sfx_powerup_mask
        byte #>sfx_powerup_1up
        byte #>sfx_powerup_battery_25
        byte #>sfx_powerup_battery_50
        byte #>sfx_powerup_battery_100
        byte #>sfx_shoot_dart
        byte #>sfx_shoot_bullet
        byte #>sfx_rng_chord
        byte #>sfx_phase_next
        byte #>sfx_snare
        byte #>sfx_hat
        byte #>sfx_ghost_snare


; sound test 00
sfx_pewpew: subroutine
	lda sfx_pu2_counter
        bne .no
	; pulse 2
	lda #%10001111
        sta $4004
        lda #%10000010
        sta $4005
        lda rng0
        and #$3f
        ora #$08
        sta $4006
        lda #%00010000
        sta $4007
        lda #0
        sta apu_pu2_counter
        sta sfx_pu2_update_type
.no
	rts

; sound test 01
sfx_player_damage: subroutine
	; noise
        lda rng0
        and #$8f
        ora #$0c
        sta apu_cache+$e
        lda #$10
        sta apu_noi_counter
        lda #$02
        sta apu_noi_envelope
        lda #$10
        sta sfx_noi_counter
        rts
        
; sound test 02
sfx_player_death: subroutine
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
	lda #$01
        sta sfx_noi_update_type
	lda #$00
        sta sfx_pu2_update_type
        lda #$00
        sta sfx_temp00 ; volume
        lda #$80
        sta sfx_temp01 ; pitch
        ;sta sfx_noi_counter
	rts
        
sfx_player_death_update: subroutine
        lda sfx_temp00 ; vol
        lsr
        lsr
        lsr
        lsr
        and #%00010000
        sta apu_cache+$c
        lda sfx_temp01 ; pitch
        lsr
        lsr
        lsr
        sta apu_cache+$e
        inc sfx_temp01 ; pitch
        inc sfx_temp00 ; vol
        inc sfx_temp00 ; vol
        bne .dont_kill_player_death_sound
        lda #$10
        sta apu_cache+$c
        lda #$00
        sta sfx_noi_update_type
.dont_kill_player_death_sound
	rts
        
        
        
; sound test 03
sfx_kick:
sfx_enemy_damage: subroutine
	lda sfx_pu2_counter
        bne .no
	; pulse 2
	lda #%10001111
        sta $4004
        lda #%10000010
        sta $4005
        lda rng0
        sta $4006
        lda #%00010001
        sta $4007
        lda #$08
        sta sfx_pu2_counter
        lda #0
        sta sfx_pu2_update_type
.no
	rts
        
        
; sound test 04
sfx_enemy_death: subroutine
	lda #%00011111
        sta apu_cache+$c
        lda #$0f
        sta apu_cache+$e
	lda #$02
        sta apu_noi_envelope
        sta sfx_noi_update_type
        lda #$10
        sta apu_noi_counter
        sta sfx_noi_counter
        rts
        
sfx_enemy_death_update: subroutine
	lda apu_cache+$c
        sta apu_cache+$e
        and #%00001111
        beq sfx_noi_update_clear
        rts

sfx_noi_update_clear: subroutine
	lda #%00010000
        sta apu_cache+$c
	lda #$00
        sta sfx_noi_update_type
        rts


        
        
; sound test 05
sfx_powerup_hit: subroutine
        lda #$82
        sta apu_cache+$e
        lda #$20
        sta apu_noi_counter
        lda #$04
        sta apu_noi_envelope
        lda #$16
        sta sfx_noi_counter
        rts
        

; sound test 06
sfx_powerup_bomb: subroutine
	lda #44
        sta bomb_counter
        sta sfx_noi_counter
	lda #$04
        sta sfx_noi_update_type
	rts
        
sfx_powerup_bomb_update: subroutine
        lda #%00011111
        sta apu_cache+$c
        lda bomb_counter
        and #%00001111
        ora #%00000011
        sta apu_cache+$e
        lda bomb_counter
        beq sfx_noi_update_clear
	rts

; sound test 07
sfx_powerup_mushroom: subroutine
	; slow pu2 sweep up
	lda #%10001111
        sta $4004
        lda #%10101010
        sta $4005
        lda audio_root_tone
        tax
        lda periodTableLo,x
        sta $4006
        lda periodTableHi,x
        ora #%01000000
        sta $4007
        lda #$10
        sta sfx_pu2_counter
	rts

; sound test 08
sfx_powerup_mask: subroutine
	; XXX not exactly satisfied
	; fast pu2 sweep up
	lda #%10001111
        sta $4004
        lda #%11111001
        sta $4005
        lda rng0
        and #$3f
        ora #$08
        sta $4006
        lda #%00010100
        sta $4007
        lda #$10
        sta sfx_pu2_counter
	rts
        
; sound test 09
sfx_powerup_1up: subroutine
	; imperial jingle
        ; root note -- x - x x X
        lda #$00
        sta sfx_temp00
        lda #$05
        sta sfx_pu2_update_type
        rts
sfx_powerup_1up_update: subroutine
	lda sfx_temp00
        beq .trigger_lower_note
        cmp #$10
        beq .trigger_lower_note
        cmp #$18
        beq .trigger_lower_note
        cmp #$20
        beq .trigger_higher_note
        bne .done
.trigger_lower_note
	lda audio_root_tone
        clc
        adc #$18
        bne .trigger_note
.trigger_higher_note
        lda #$00
        sta sfx_pu2_update_type
	lda audio_root_tone
        clc
        adc #$24
.trigger_note
        tax
	lda #%10000011
        sta $4004
        lda #$00
        sta $4005
        lda periodTableLo,x
        sta $4006
        lda periodTableHi,x
        ora #%01000000
        sta $4007
        lda #$10
        sta sfx_pu2_counter
.done
	inc sfx_temp00
	rts
       
        
; sound test 0a
sfx_powerup_battery_25: subroutine
        lda #$08
        sta sfx_temp00 ; counter
        bne sfx_powerup_battery_set_update_type
; sound test 0b
sfx_powerup_battery_50: subroutine
        lda #$04
        sta sfx_temp00 ; counter
        bne sfx_powerup_battery_set_update_type
; sound test 0c
sfx_powerup_battery_100: subroutine
        lda #$00
        sta sfx_temp00 ; counter
sfx_powerup_battery_set_update_type:
	lda #$03
        sta sfx_pu2_update_type
        rts
        
sfx_powerup_battery_arp:
 .byte	#$18, #$1c, #$1f, #$24

sfx_powerup_battery_update: subroutine
	lda sfx_temp00
        and #%00000011
        bne .dont_trigger
        lda sfx_temp00
        lsr
        lsr
        cmp #$04
        beq .end_sound
        tax
        lda audio_root_tone
        clc
        adc sfx_powerup_battery_arp,x
        tax
	lda #%10000011
        sta $4004
        lda #$00
        sta $4005
        lda periodTableLo,x
        sta $4006
        lda periodTableHi,x
        ora #%01000000
        sta $4007
        lda #$10
        sta sfx_pu2_counter
.dont_trigger
        inc sfx_temp00 ; counter
	rts
.end_sound
	lda #$00
        sta sfx_pu2_update_type
        rts

; sound test 0d
sfx_shoot_dart: subroutine
	; pulse 1
	lda #%00001111
        sta $4000
        lda #%10000011
        sta $4001
        lda rng0
        and #$3f
        ora #$08
        sta $4002
        lda #%00001000
        sta $4003
        lda #$10
        sta sfx_pu1_counter
	rts
        
; sound test 0e
sfx_shoot_bullet: subroutine
	lda #%00011111
        sta apu_cache+$c
        lda wtf
        and #$03
        clc
        adc #$09
        sta apu_cache+$e
	lda #$04
        sta apu_noi_envelope
        lda #$20
        sta apu_noi_counter
        rts
        
        
; sound test 0f
sfx_rng_chord: subroutine
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
        
        
sfx_phase_next_counter		= $150        
        
; sound test 10
sfx_phase_next: subroutine
        lda #$00
        sta sfx_phase_next_counter
        lda #$06
        sta sfx_pu2_update_type
        rts
        
sfx_phase_next_update: subroutine
	lda sfx_phase_next_counter
        beq .trigger_first
        cmp #$04
        beq .trigger_last
        bne .done
.trigger_first
        lda #$40
        sta apu_pu2_counter
        lda #$20
        sta sfx_pu2_counter
        lda #3
        sta apu_pu2_envelope
	lda audio_root_tone
        clc
        adc #24 ; two octaves
        tax
        ldy #6
        jsr apu_set_pitch
        bne .done
.trigger_last
        lda #$40
        sta apu_pu1_counter
        sta apu_pu2_counter
        lda #$20
        sta sfx_pu2_counter
        lda #3
        sta apu_pu1_envelope
        sta apu_pu2_envelope
	lda audio_root_tone
        clc
        adc #31 ; two octaves + 5th
        tax
        ldy #2
        jsr apu_set_pitch
        ldy #6
        jsr apu_set_pitch
        inc apu_cache+6
        inc apu_cache+6
        inc apu_cache+6
        ; trigger next phase and kill sfx
        lda #$00
        sta sfx_pu2_update_type
.done
	inc sfx_phase_next_counter
	rts
        
        
; sound test 11
sfx_snare: subroutine
        lda #$a
        sta apu_cache+$e
        lda #$06
        sta apu_noi_counter
        lda #$06
        sta apu_noi_envelope
        rts
        
; sound test 12
sfx_hat: subroutine
	lda sfx_noi_counter
        bne .no
        lda apu_rng1
        and #3
        sta apu_cache+$e
        lda #$e
        sta apu_noi_counter
        lda #$05
        sta apu_noi_envelope
.no
        rts
        
        
; sound test 13
sfx_ghost_snare: subroutine
	lda rng2
        and #$01
        adc #$0b
        sta apu_cache+$e
        lda #$04
        sta apu_noi_counter
        lda #$06
        sta apu_noi_envelope
        rts