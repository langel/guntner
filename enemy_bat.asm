
; 187 bytes

bat_spawn: subroutine
	; x = slot in enemy ram
        ; y = boss slot in enemy ram
        ; stash boss slot in pattern counter
	lda #$07
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x
        lda #$20
        sta enemy_ram_y,x 
        lda #$00
        sta enemy_ram_pc,x
	rts
     
     
bat_cycle: subroutine
        lda #$08
        sta collision_0_w
        lda #$05
        sta collision_0_h
        jsr enemy_handle_damage_and_death
	; adjust all counters
	inc enemy_ram_x,x
        ; update animation
        lda enemy_ram_ac,x
        cmp #$80
        bcs .pattern_inc
.pattern_dec
        dec enemy_ram_pc,x
        jmp .pattern_done
.pattern_inc
	inc enemy_ram_pc,x
.pattern_done
        inc enemy_ram_ac,x
        lda enemy_ram_ac,x
        lsr
        lsr
        and #%00000011
        cmp #$00
        bne .not_frame0
        lda #$39
        jmp .frame_done
.not_frame0
        cmp #$02
        bne .not_frame2
        lda #$3b
        jmp .frame_done
.not_frame2
	lda #$3a        	
.frame_done
	sta oam_ram_spr,y
        ; only calc sine every other frame
        lda wtf
        and #$00000001
        sta temp00
        lda enemy_slot_id
        and #%00000001
        cmp temp00
        beq .process_sine_pos
        jmp .done
.process_sine_pos
        ; update x pos
        ldy enemy_ram_pc,x
        lda enemy_ram_ac,x
        tax
        tya
        lsr
        lsr
        jsr sine_of_scale
        clc
	ldx enemy_ram_offset
        adc enemy_ram_x,x
        ldy enemy_oam_offset
        sta oam_ram_x,y
        ; update y pos
        ldy enemy_ram_pc,x
        lda enemy_ram_ac,x
        clc
        adc #$40
        tax
        tya
        lsr
        lsr
        jsr sine_of_scale
        clc
	ldx enemy_ram_offset
        adc enemy_ram_y,x
        ldy enemy_oam_offset
        sta oam_ram_y,y
        ; set palette
        lda #$03
        jsr enemy_set_palette
.done
	jmp update_enemies_handler_next