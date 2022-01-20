

        
powerups_cycle: subroutine

; this is crossbones cycle
; need to make it increase y instead of decrease x
	ldx enemy_handler_pos
        inc ENEMY_RAM+5,x
        lda ENEMY_RAM+5,x
        lsr
        lsr
        lsr
        sta ENEMY_RAM+3,x
        tay
        ldy enemy_temp_oam_x
        lda $0200,y
        sec
        sbc ENEMY_RAM+3,x
        bcc .death
        sta $0200,y
        lda #$0b
        sta $0201,y
        lda #$03
        sta $0202,y
        jmp .done
.death
        jsr enemy_death
.done