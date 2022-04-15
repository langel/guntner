
        

dart_spawn: subroutine
; put x,y origin in:
;	collision_0_x
;	collision_0_y
        jsr get_enemy_slot_next
        cpx #$ff
        beq .done
	lda #$10
        sta enemy_ram_type,x
        lda #0
        sta enemy_ram_x,x ; sub pixel pos
        sta enemy_ram_y,x ; sub pixel pos
        sta enemy_ram_pc,x
        lda #3
        sta enemy_ram_ac,x ; velocity id
        jsr get_oam_offset_from_slot_offset
        lda collision_0_x
        sta oam_ram_x,y
        lda collision_0_y
        sta oam_ram_y,y
        jsr enemy_get_direction_of_player
        sta enemy_ram_ex,x
        tax
        lda dart_direction_to_sprite_table,x
        sta oam_ram_spr,y
.done
	rts

        
dart_direction_to_sprite_table:
	.byte $b0,$b1,$b2,$b3,$b4,$b5
        .byte $b6,$b5,$b4,$b3,$b2,$b1
	.byte $b0,$b1,$b2,$b3,$b4,$b5
        .byte $b6,$b5,$b4,$b3,$b2,$b1
dart_direction_to_attribute_table:
	.byte $00,$00,$00,$00,$00,$00
        .byte $40,$40,$40,$40,$40,$40
        .byte $c0,$c0,$c0,$c0,$c0,$c0
        .byte $80,$80,$80,$80,$80,$80
        
        
dart_cycle: subroutine
	; check for player collision
        lda #$04
        sta collision_0_w
        lda #$04
        sta collision_0_h
        lda oam_ram_x,y
        adc #$02
        sta collision_0_x
        lda oam_ram_y,y
        adc #$02
        sta collision_0_y
        jsr player_collision_detect
        cmp #$00
        beq .no_collision
        lda #4
        sta player_damage
        jsr player_take_damage
        jmp .despawn
.no_collision

	; check for despawn
        lda oam_ram_x,y
        cmp #$09
        bcc .despawn
	lda oam_ram_y,y
        cmp sprite_0_y
        bcs .despawn
        
	; handle direction movement
	jsr enemy_update_arctang_path
        
        ; attributes
        lda enemy_ram_ex,x
        tax
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
	