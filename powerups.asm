; powerups always spawn from starglasses
        
; powerup juggling brought to you by sine waves
; x pos is point of origin
; only need to use rise and fall arc
; must capture max fall velocity (4px/frame)
; rise and fall needs full 8bit range

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
        clc
        adc #$04
        sta enemy_ram_y,x
	lda #$40
        sta enemy_ram_pc,x
        lda #$01
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
        lda enemy_dmg_accumulator
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
        lda #$01
        sta enemy_ram_pc,x
        lda oam_ram_x,y
        sta enemy_ram_x,x
        ; will wrap to the left so add hp
        inc enemy_ram_hp,x
        ; give it sfx
        jsr sfx_battery_hit
.frame
        lda enemy_ram_pc,x
	cmp #$80
        beq .max_velocity
.sine_arc
	ldy enemy_ram_pc,x
        iny
        lda sine_table,y
        sta temp00
        dey
        lda sine_table,y
        sec
        sbc temp00
        sta temp00
        sta enemy_ram_ac,x
        ldy enemy_oam_offset
        lda enemy_ram_x,x
        clc
        adc temp00
        sta enemy_ram_x,x
        sta oam_ram_x,y
        lda wtf
        and #$01
        beq .move_done
        inc enemy_ram_pc,x
        jmp .move_done
.max_velocity
	lda oam_ram_x,y
        clc
        adc #$04
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
	.word powerup_pickup_mask
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
        
        
powerup_pickup_mask: subroutine
        inc mask_shield
        inc mask_shield
        inc mask_shield
	rts
        
powerup_pickup_mushroom: subroutine
	; XXX still need to override player controls
        ; XXX still need to bend music
        ; XXX reset pallete on player death
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
	; XXX might want different lengths
        ;     based on difficulty setting
        lda #120
        sta r_bag_counter
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

        