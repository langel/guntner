

text_song:
	.byte "song"
        .byte #$00
        
text_sound:
	.byte "sound"
        .byte #$00
        
     
options_screen_init: subroutine
	lda #$01
        sta game_mode
        jsr WaitSync	
	; disable rendering
        lda #$00
        sta PPU_MASK	
        
        jsr nametables_clear
        jsr scroll_pos_reset
	PPU_SETADDR $2200
        ldy #$00
.song_text
	lda text_song,y
        beq .song_end
        sta PPU_DATA
        iny
        bne .song_text
.song_end
	PPU_SETADDR $2220
        ldy #$00
.sound_text
	lda text_sound,y
        beq .song_end
        sta PPU_DATA
        iny
        bne .song_text
.sound_end

; hud bar on title screen
	PPU_SETADDR $22c0
        lda #$1d
        ldy #$20
.set_top_bar
	sta PPU_DATA
        dey
        bne .set_top_bar
; turn ppu back on
	; enable rendering
        lda #MASK_BG|MASK_SPR
        sta PPU_MASK	
        jsr WaitSync	; wait for VSYNC
	rts

        
        
        
options_screen_handler: subroutine
	rts