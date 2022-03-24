; powerups always spawn from starglasses
        
; powerup juggling brought to you by sine waves
; x pos is point of origin
; only need to use rise and fall arc
; must capture max fall velocity (4px/frame)
; rise and fall needs full 8bit range
        
; POWER UP TYPES
; battery (partial and full) fill meter
; mushroom makes everything trippy
; machine gun does an autofire
; slow down makes movement unbearable

; palette sprites start at $24
; 0 - skull shield
; 1 - mushroom
; 2 - plus one
; 3 - bomb
; 4 - r bag
; 5 - health 25%
; 6 - health 50%
; 7 - health full
        
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
        ; rng powerup type
        lda rng0
        lsr
        and #$07
        sta enemy_ram_ex,x
        ; sprite
        clc
        adc #$24
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
.player_picksup_powerup
 	;; XXX needs its own sfx
        ; might want different ones by type
        jsr sfx_powerup_pickup
        lda enemy_ram_ex,x
        jsr powerup_type_handler_delegator
        jsr enemy_death
	jmp update_enemies_handler_next
.reset_velocity
        lda #$00
        sta enemy_ram_pc,x
        lda oam_ram_x,y
        sta enemy_ram_x,x
        ; will wrap to the left so add hp
        inc enemy_ram_hp,x
        ; give it sfx
        jsr sfx_battery_hit
.frame
	lda enemy_ram_y,x
        sta oam_ram_y,y
        ; XXX attr shouldn't be hardcoded
	lda #$03
        sta oam_ram_att,y
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
        
        
        
        
powerup_type_handler_table:
	.word powerup_pickup_skull
        .word powerup_pickup_mushroom
	.word powerup_pickup_plus_one
        .word powerup_pickup_bomb
        .word powerup_pickup_r_bag
        .word powerup_pickup_health_25
        .word powerup_pickup_health_50
        .word powerup_pickup_health_100
        
powerup_type_handler_delegator:
        asl
        tax
        lda powerup_type_handler_table,x
        sta temp00
        inx
        lda powerup_type_handler_table,x
        sta temp01
        ldx enemy_ram_offset
        jmp (temp00)
        
        
powerup_pickup_skull: subroutine
	rts
        
powerup_pickup_mushroom: subroutine
	; XXX still need to override player controls
        ; XXX still need to bend music
	lda #108
        sta shroom_counter
	rts
        
powerup_pickup_plus_one: subroutine
	inc player_lives
	rts
        
bomb_damage_frame	.EQU	#29
powerup_pickup_bomb: subroutine
	lda #44
        sta bomb_counter
	rts
        
powerup_pickup_r_bag: subroutine
	rts
        
powerup_pickup_health_25: subroutine
        lda player_health
        clc
        adc #$40
        sta player_health
        bcc .no_max_out
        lda #$ff
        sta player_health
.no_max_out
	rts
        
powerup_pickup_health_50: subroutine
        lda player_health
        clc
        adc #$80
        sta player_health
        bcc .no_max_out
        lda #$ff
        sta player_health
.no_max_out
	rts
        
powerup_pickup_health_100: subroutine
	lda #$ff
        sta player_health
	rts

        