
; set velocity after calling spawn with :
;	lda #<arctang_velocity_3.33
;	sta enemy_ram_pc,x
        

dart_spawn: subroutine
; put x,y origin in:
;	collision_0_x
;	collision_0_y
.checks
	; dart_frame_max is set at top of enemy_handler
        lda dart_frame_max
        beq .done
        dec dart_frame_max
        jsr get_enemy_slot_next
        cpx #$ff
        beq .done
.spawn
	lda #dart_id
        sta enemy_ram_type,x
        lda #0
        sta enemy_ram_x,x ; sub pixel pos
        sta enemy_ram_y,x ; sub pixel pos
        ;sta enemy_ram_pc,x
        ; velocity
        lda #<arctang_velocity_3.33
        sta enemy_ram_pc,x
        ; get y register and set origin
        jsr get_oam_offset_from_slot_offset
        lda collision_0_x
        sta oam_ram_x,y
        lda collision_0_y
        sta oam_ram_y,y
        jsr enemy_get_direction_of_player
        ; stash x
        stx temp00
        ; sprite
        sta enemy_ram_ex,x
        tax
        lda dart_direction_to_sprite_table,x
        clc
        adc #$b9
        sta oam_ram_spr,y
        ; attributes
        lda dart_direction_to_attribute_table,x
        clc
        adc #$01
        sta oam_ram_att,y
        ; pull x
        ldx temp00
        ; sfx
        jsr sfx_shoot_dart
.done
	rts

        
dart_direction_to_sprite_table:
	.byte 0,1,2,3,4,5,6,5,4,3,2,1
	.byte 0,1,2,3,4,5,6,5,4,3,2,1
dart_direction_to_attribute_table:
	.byte $00,$00,$00,$00,$00,$00
        .byte $40,$40,$40,$40,$40,$40
        .byte $c0,$c0,$c0,$c0,$c0,$c0
        .byte $80,$80,$80,$80,$80,$80
        
        
dart_cycle: subroutine
	; check for player collision
        lda #$04
        sta collision_0_w
        sta collision_0_h
        lda oam_ram_x,y
        clc
        adc #$02
        sta collision_0_x
        lda oam_ram_y,y
        adc #$02
        sta collision_0_y
        jsr player_collision_detect
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
        lda enemy_ram_pc,x
        sta arctang_velocity_lo
	jsr enemy_update_arctang_path
        
.done	
	jmp update_enemies_handler_next
.despawn
        jsr enemy_death
        jmp .done
	