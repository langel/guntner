


ikes_mom_spawn:
	jsr get_oam_offset_from_slot_offset
        lda #$fa
        sta oam_ram_x,y
        lda #$80
        sta oam_ram_y,y
        lda #$05
        sta enemy_ram_ex,x
	rts
        
        
ikes_mom_cycle:

	lda wtf
        and #$07
        bne .dir_update_done
        ; current direction
        lda enemy_ram_ex,x
        sta temp00 
        ; next direction
        jsr enemy_get_direction_of_player
        sta temp01
.dec_border_check
        ; if current direction < 6
        ; and next direction > 18
        ; then we decrease
        lda temp00
        cmp #6
        bcs .inc_border_check
        lda temp01
        cmp #18
        bcc .inc_border_check
        jmp .dir_dec
.inc_border_check
        ; OR
        ; if current direction > 18
        ; and next direction < 6
        ; then we increase
        lda temp00
        cmp #18
        bcc .basic_check
        lda temp01
        cmp #6
        bcs .basic_check
        jmp .dir_inc
.basic_check
        ; OR basic comparison
        ; current_direction < next_direction
        cmp enemy_ram_ex,x
        bcc .dir_inc
.dir_dec
	dec enemy_ram_ex,x
        bpl .dir_update_done
.fix_minus
	lda #23
        sta enemy_ram_ex,x
        jmp .dir_update_done
.dir_inc
	inc enemy_ram_ex,x
        lda #24
        cmp enemy_ram_ex,x
        bcs .dir_update_done
        lda #$00
        sta enemy_ram_ex,x
.dir_update_done

	lda arctang_velocities_lo+2
        sta arctang_velocity_lo
        jsr enemy_update_arctang_path
        
        
	; x
	lda oam_ram_x,y
        jsr sprite_4_set_x
        ; y
	lda oam_ram_y,y
        jsr sprite_4_set_y
        ; sprite
	lda #$22
        jsr sprite_4_set_sprite
        ; palette
        lda #$02
        jsr sprite_4_set_palette
        
	jmp update_enemies_handler_next