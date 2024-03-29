
; temp00 = eye sprite x origin
; temp01 = eye sprite y origin

enemy_boss_eyes: subroutine
        ; EYE SPRITE
.now_lets_add_eyes
	ldx #$fc
        lda #$a9
        sta oam_ram_spr,x
        lda boss_eyes_pal
        sta oam_ram_att,x
        ; find x
        lda temp00
        sta oam_ram_x,x
        ; check if rudy is left of vampire
        cmp player_x_hi
        bcc .looking_right
.looking_left
        lda #$99
        sta oam_ram_spr,x
	;inc oam_ram_x,x
.looking_right
	; find y
        ldy temp01
        iny
        tya
        ldy enemy_oam_offset
        sta oam_ram_y,x
        clc
        adc #$1c
        sec
        sbc player_y_hi
        bcc .looking_down
        clc
        adc #$cc
        bcs .looking_up
.looking_across
	lda oam_ram_spr,x
        cmp #$99
        beq .adjust_for_left_looking
        jmp .done
.adjust_for_left_looking
        rts
.looking_up
	dec oam_ram_y,x
        rts
.looking_down
	inc oam_ram_y,x
.done
	rts
