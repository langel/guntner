; powerups always spawn from starglasses
        
; powerup juggling brought to you by sine waves
; x pos is point of origin
; only need to use rise and fall arc
; must capture max fall velocity (4px/frame)
; rise and fall needs full 8bit range
        
powerup_from_starglasses:
	ldx enemy_ram_offset
        ldy enemy_oam_offset
	lda #$06
        sta enemy_ram_type,x
        lda oam_ram_x,y
        sta enemy_ram_x,x
        lda oam_ram_y,y
        sta enemy_ram_y,x
	lda #$80
        sta enemy_ram_pc,x
        lda #$02
        sta enemy_ram_hp,x
        ; sprite
        lda #$2b
        sta oam_ram_spr,y
        ; palette
	lda #$03
        sta oam_ram_att,y
	rts
      
        
powerups_cycle: subroutine
        ; only calc sine every other frame
;        lda wtf
;        and #$00000001
;        sta enemy_temp_temp
;        lda enemy_slot_id
;        and #%00000001
;        cmp enemy_temp_temp
;        beq .process_this_frame
;	jmp update_enemies_handler_next
.process_this_frame
	ldx enemy_ram_offset
        ldy enemy_oam_offset
        lda oam_ram_x,y
        sta collision_0_x
        lda oam_ram_y,y
        sta collision_0_y
        lda #$08
        sta collision_0_w
        sta collision_0_h
        lda #$00
        sta enemy_dmg_accumulator
        jsr player_bullet_collision_handler
        cmp #$00
        bne .reset_velocity
        jsr player_collision_detect
        cmp #$00
        beq .frame
.despawn_powerup
 	;; XXX needs its own sfx
        ; might want different ones by type
        jsr apu_trigger_enemy_death
        jsr enemy_death
        lda player_health
        clc
        adc #$80
        sta player_health
        bcc .frame
        lda #$ff
        sta player_health
	jmp update_enemies_handler_next
.reset_velocity
        lda #$00
        sta enemy_ram_pc,x
        lda oam_ram_x,y
        sta enemy_ram_x,x
        ; will wrap to the left so add hp
        inc enemy_ram_hp,x
        ; give it sfx
        jsr apu_trigger_battery_hit
.frame
        lda enemy_ram_pc,x
	cmp #$ff
        beq .max_velocity
.sine_arc
	lda enemy_ram_pc,x
        lsr
	tay
        lda enemy_ram_x,x
        sec
        sbc sine_table,y
        sec
        iny
        sbc sine_table,y
        ldy enemy_oam_offset
        sta oam_ram_x,y
	ldx enemy_ram_offset
        inc enemy_ram_pc,x
        jmp .move_done
.max_velocity
	lda enemy_ram_x,x
        clc
        adc #$03
	sta enemy_ram_x,x
        sta oam_ram_x,y
        bcc .move_done
        ; will fall off the right so minus hp
        dec enemy_ram_hp,x
.move_done
.despawn_check
	lda enemy_ram_hp,x
        cmp #$00
        bne .done
 	;; XXX needs its own sfx
        ;; despawns to the right
        ;jsr apu_trigger_enemy_death
        jsr enemy_death
.done   
	jmp update_enemies_handler_next
        
        