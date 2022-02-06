
text_options:
	.byte "Options Screeen"
        .byte #$00

text_song:
	.byte "song"
        .byte #$00
        
text_sound:
	.byte "sound"
        .byte #$00
        
     
options_screen_init: subroutine
	lda #$01
        sta game_mode
	lda #$00
        sta options_song_id	
        sta options_sound_id
        sta options_rudy_pos
        sta scroll_y
        sta scroll_page
        lda #$38
        sta player_x_hi
        jsr WaitSync	
	; disable rendering
        lda #$00
        sta PPU_MASK	
        
        jsr nametables_clear
        jsr scroll_pos_reset
        jsr set_player_sprite
        
        
	PPU_SETADDR $2048
        ldy #$00
.options_text
	lda text_options,y
        beq .options_end
        sta PPU_DATA
        iny
        bne .options_text
.options_end
        
        
	PPU_SETADDR $210a
        ldy #$00
.song_text
	lda text_song,y
        beq .song_end
        sta PPU_DATA
        iny
        bne .song_text
.song_end

	PPU_SETADDR $214a
        ldy #$00
.sound_text
	lda text_sound,y
        beq .sound_end
        sta PPU_DATA
        iny
        bne .sound_text
.sound_end

; hud bar on title screen
	PPU_SETADDR $22c0
        lda #$1d
        ldy #$20
.set_hud_bar
	sta PPU_DATA
        dey
        bne .set_hud_bar
        
        
; turn ppu back on
        jsr WaitSync	; wait for VSYNC
	; enable rendering
        lda #MASK_BG|MASK_SPR
        sta PPU_MASK	
        jsr WaitSync	; wait for VSYNC
        jsr timer_reset
	rts

        
        
        
options_screen_handler: subroutine
	lda options_rudy_pos
        asl
        asl
        asl
        asl
        clc
        adc #$48
        sta oam_ram_rudy
        sta oam_ram_rudy+4
	jsr apu_game_frame
        lda #$02
        sta PPU_OAM_DMA
; check if option changes
	lda player_down_d
        cmp #$00
        beq .dont_change_option
        inc options_rudy_pos
        lda options_rudy_pos
        and #%00000001
        sta options_rudy_pos
.dont_change_option
; show song id
	PPU_SETADDR $2112
        ;inc options_song_id	
	lda options_song_id
        cmp #100
        bne .song_id_no_reset
        lda #$00
        sta options_song_id
.song_id_no_reset
        asl
        tax
        lda decimal_table,x
        sta PPU_DATA
        inx
        lda decimal_table,x
        sta PPU_DATA
; show sound id
	PPU_SETADDR $2152
        lda player_right_d
        cmp #$00
        beq .dont_up_sound
        inc options_sound_id
.dont_up_sound
	lda player_left_d
        cmp #$00
        beq .dont_down_sound
    	dec options_sound_id
.dont_down_sound
	lda options_sound_id
        cmp #$ff
        bne .sound_id_no_reset
        lda #$05
        sta options_sound_id
.sound_id_no_reset
	cmp #$06
        bne .sound_id_not_maxed
        lda #$00
        sta options_sound_id
.sound_id_not_maxed
        asl
        tax
        lda decimal_table,x
        sta PPU_DATA
        inx
        lda decimal_table,x
        sta PPU_DATA
; trigger sound with button
	lda player_a_d
        ora player_b_d
        cmp #$00
        bne .trigger_sound
        rts
.trigger_sound
	lda options_sound_id
        cmp #$00
        bne .not00
        jmp sfx_pewpew
.not00
 	cmp #$01
        bne .not01
        jmp sfx_player_damage
.not01
	cmp #$02
        bne .not02
        jmp sfx_player_death
.not02
	cmp #$03
        bne .not03
        jmp sfx_enemy_death
.not03
	cmp #$04
        bne .not04
        jmp sfx_battery_hit
.not04
	cmp #$05
        bne .not05
        jmp sfx_powerup_pickup
.not05
	cmp #$06
        bne .not06
        jmp sfx_player_death
.not06
	cmp #$07
        bne .not07
        jmp sfx_player_death
.not07
	rts