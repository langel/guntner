
        

dart_spawn: subroutine
	lda #$10
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        ; x = dart enemy_oam_offset
        txa
        pha ; store x on stack
        sec
        sbc #$a0
        asl
        clc
        adc #$80
        tax
	; y = parent enemy_oam_offset
        ; only works if called by a parent cycle routine
        ldy enemy_oam_offset
        lda oam_ram_x,y
        clc
        adc #$05
        sta collision_0_x
        sta oam_ram_x,x
        lda oam_ram_y,y
        clc
        adc #$02
        sta collision_0_y
        sta oam_ram_y,x
        jsr enemy_get_direction_of_player
        tay
        pla ; pull x from stack
        tax
        tya
        sta enemy_ram_ex,x
        ; reset stuff
        lda #0
        sta enemy_ram_x,x
        sta enemy_ram_y,x
        sta enemy_ram_pc,x
	rts

        
dart_direction_to_sprite_table:
	.byte $c0,$c1,$c2,$c3,$c4,$c5
        .byte $c6,$c5,$c4,$c3,$c2,$c1
	.byte $c0,$c1,$c2,$c3,$c4,$c5
        .byte $c6,$c5,$c4,$c3,$c2,$c1
dart_direction_to_attribute_table:
	.byte $00,$00,$00,$00,$00,$00
        .byte $40,$40,$40,$40,$40,$40
        .byte $c0,$c0,$c0,$c0,$c0,$c0
        .byte $80,$80,$80,$80,$80,$80
        
        
dart_cycle: subroutine

	; check for player collision
        lda #$08
        sta collision_0_w
        lda #$04
        sta collision_0_h
        jsr player_collision_detect
        cmp #$00
        beq .no_collision
        lda #4
        sta player_damage
        jsr player_take_damage
        jmp .despawn
.no_collision
	; handle direction movement
	jsr enemy_update_arctang_path

	; check for despawn
        lda oam_ram_x,y
        cmp #$09
        bcc .despawn
	lda oam_ram_y,y
        cmp sprite_0_y
        bcs .despawn
        
	;lda #$6a
        lda enemy_ram_ex,x
        tax
        lda dart_direction_to_sprite_table,x
        sta oam_ram_spr,y
        lda dart_direction_to_attribute_table,x
        ldx enemy_ram_offset
        clc
        adc #$01
        jsr enemy_set_palette
.done	
	jmp update_enemies_handler_next
.despawn
        lda #$00
        sta enemy_ram_type,x
        lda #$ff
        sta oam_ram_y,y
        jmp .done
	