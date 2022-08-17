
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
        ; velocity
        ldy dart_velocity
        lda arctang_velocities_lo,y
        sta enemy_ram_pc,x
        ; get y register and set origin
        jsr get_oam_offset_from_slot_offset
        lda dart_x_origin
        sta oam_ram_x,y
        lda dart_y_origin
        sta oam_ram_y,y
        ; direction
        jsr enemy_get_direction_of_player
        clc
        adc dart_dir_adjust
        jsr arctang_bound_dir
        sta enemy_ram_ex,x
        ; sprite
        lda dart_sprite
        bne .sprite_custom
        lda enemy_ram_ex,x
        tax
        lda dart_direction_to_sprite_table,x
        clc
        adc #$b9
        sta oam_ram_spr,y
        ; attributes
        lda dart_direction_to_attribute_table,x
        ora #$01
        sta oam_ram_att,y
        bne .sprite_done
.sprite_custom
	sta oam_ram_spr,y
        lda #$01
        sta oam_ram_att,y
.sprite_done
        ; sfx
        jsr sfx_shoot_dart
        ; register happy town
        ldx enemy_ram_offset
        ldy enemy_oam_offset
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
	; check for x despawn
        lda oam_ram_x,y
        cmp #$03
        bcc .despawn
        cmp #$fc
        bcs .despawn
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
        jsr enemy_gives_damage
.despawn
        jsr enemy_clear
        jmp .done
.no_collision
	; handle direction movement
        lda enemy_ram_pc,x
        sta arctang_velocity_lo
	jsr arctang_enemy_update
        ; check for y despawn
	lda oam_ram_y,y
        cmp #$06
        bcc .despawn
.done	
	jmp update_enemies_handler_next
	