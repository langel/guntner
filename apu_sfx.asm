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
	.byte #<sfx_do_nothing
	.byte #<sfx_player_death_update
        .byte #<sfx_enemy_death_update
        .byte #<sfx_powerup_pickup_update
        .byte #<sfx_powerup_bomb_update
sfx_update_table_hi:
	; XXX can probably remove this table
        ;     get all subroutines on same page
	.byte #>sfx_do_nothing
	.byte #>sfx_player_death_update
        .byte #>sfx_enemy_death_update
        .byte #>sfx_powerup_pickup_update
        .byte #>sfx_powerup_bomb_update
sfx_do_nothing: subroutine
	rts
        
        
sfx_test_delegator: subroutine
	; x = sound effect id
        lda sfx_test_table_lo,x
        sta temp00
        lda sfx_test_table_hi,x
        sta temp01
        jmp (temp00)
sfx_test_table_lo:
	.byte #<sfx_pewpew
        .byte #<sfx_player_damage
        .byte #<sfx_player_death
        .byte #<sfx_enemy_damage
        .byte #<sfx_enemy_death
        .byte #<sfx_powerup_hit
        .byte #<sfx_powerup_bomb
        .byte #<sfx_powerup_mushroom
        .byte #<sfx_powerup_mask
        .byte #<sfx_powerup_1up
        .byte #<sfx_powerup_battery_25
        .byte #<sfx_powerup_battery_50
        .byte #<sfx_powerup_battery_100
sfx_test_table_hi:
	; XXX can probably remove this table
        ;     get all subroutines on same page
	.byte #>sfx_pewpew
        .byte #>sfx_player_damage
        .byte #>sfx_player_death
        .byte #>sfx_enemy_damage
        .byte #>sfx_enemy_death
        .byte #>sfx_powerup_hit
        .byte #>sfx_powerup_bomb
        .byte #>sfx_powerup_mushroom
        .byte #>sfx_powerup_mask
        .byte #>sfx_powerup_1up
        .byte #>sfx_powerup_battery_25
        .byte #>sfx_powerup_battery_50
        .byte #>sfx_powerup_battery_100

; sound test 00
sfx_pewpew: subroutine
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
        lda #$10
        sta sfx_pu2_counter
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
sfx_enemy_damage: subroutine
	; pulse 2
	lda #%10001111
        sta $4004
        lda #%10000010
        sta $4005
        lda rng0
        sta $4006
        lda #%00010001
        sta $4007
        lda #$10
        sta sfx_pu2_counter
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
	lda #$04
        sta sfx_noi_update_type
	rts
        
sfx_powerup_bomb_update: subroutine
	lda bomb_counter
        and #%00001111
        ora #%00010000
        sta apu_cache+$c
        lda bomb_counter
        ora #$0d
        sta apu_cache+$e
        lda bomb_counter
        beq sfx_noi_update_clear
	rts

; sound test 07
sfx_powerup_mushroom: subroutine
	; slow pu2 sweep up
	lda #%10001111
        sta $4004
        lda #%11111001
        sta $4005
        lda audio_root_tone
        clc
        adc #12
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
        lda #%10101010
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
        
; sound test 08
sfx_powerup_1up: subroutine
	; imperial jingle
        
        
; sound test 09
sfx_powerup_battery_25: subroutine
        lda #$10
        sta sfx_temp00 ; counter
        bne sfx_powerup_battery_set_update_type
; sound test 0a
sfx_powerup_battery_50: subroutine
        lda #$08
        sta sfx_temp00 ; counter
        bne sfx_powerup_battery_set_update_type
; sound test 0b
sfx_powerup_battery_100: subroutine
        lda #$00
        sta sfx_temp00 ; counter
sfx_powerup_battery_set_update_type:
	lda #$03
        sta sfx_pu2_update_type
        rts
        
        
sfx_powerup_pickup_arp:
 .byte	#$18, #$1c, #$1f, #$24

sfx_powerup_pickup_update: subroutine
	lda sfx_temp00 ; counter
        lsr
        lsr
        lsr
        sta sfx_temp01
        cmp #$04
        beq .end_sound
        tax
        lda sfx_temp00 ; counter
        and #%00000111
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
        inc sfx_temp00 ; counter
	rts
.end_sound
	lda #$00
        sta sfx_pu2_update_type
        rts
