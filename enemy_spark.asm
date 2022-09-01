
	;       U     R     D     L
spark_dir_x_table:
	byte #$00, #$01, #$00, #$ff
spark_dir_y_table:
	byte #$ff, #$00, #$01, #$00

spark_spawn: subroutine
	; x = slot in enemy ram
        ; y = boss slot in enemy ram
        jsr get_next_random
        sta enemy_ram_x,x
	lda #4
        sta enemy_ram_y,x
        lda #0
        sta enemy_ram_ex,x
        rts

spark_cycle: subroutine
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        ; change direction?
        lda wtf
        and #$07
        bne .dont_reset_dir
; 50% chance of downward movement
        jsr get_next_random
        bpl .not_hard_down
        lda #$02
        bne .set_dir
.not_hard_down
; otherwise random 4 directions
        jsr get_next_random
        lsr
        and #%00000011
.set_dir
        sta enemy_ram_ex,x
.reset_done
.dont_reset_dir
        ; apply direction
        ldy enemy_ram_ex,x
        lda spark_dir_x_table,y
        sta temp00
        lda spark_dir_y_table,y
        sta temp01
        ldy enemy_oam_offset
        lda enemy_ram_x,x
        clc
        adc temp00
        sta enemy_ram_x,x
        sta oam_ram_x,y
        lda enemy_ram_y,x
        clc
        adc temp01
        jsr enemy_fix_y_visible
        sta enemy_ram_y,x
        sta oam_ram_y,y
	; attributes
        jsr get_next_random
        sta oam_ram_att,y
        ; sprite
        jsr get_next_random
        and #$03
        clc
        adc #$6c
        sta oam_ram_spr,y
.done
	jmp update_enemies_handler_next