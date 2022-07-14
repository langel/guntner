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
	lda #powerups_id
        sta enemy_ram_type,x
        lda oam_ram_x,y
        clc
        adc #$04
        sta enemy_ram_x,x
        lda oam_ram_y,y
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
        jmp update_enemies_handler_next
	rts
 
 
powerups_cycle: subroutine
.process_this_frame
	ldx enemy_ram_offset
        ldy enemy_oam_offset
        lda oam_ram_x,y
        sta collision_0_x
        lda oam_ram_y,y
        sbc #3
        sta collision_0_y
        lda #$0d
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
        ldy enemy_ram_ex,x
        jsr powerup_pickup_delegator
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
        jsr sfx_powerup_hit
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
        
        
        
        
powerup_pickup_table_lo:
	.byte #<powerup_pickup_mask
	.byte #<powerup_pickup_mushroom
	.byte #<powerup_pickup_plus_one
	.byte #<powerup_pickup_bomb
	.byte #<powerup_pickup_r_bag
	.byte #<powerup_pickup_health_25
	.byte #<powerup_pickup_health_50
	.byte #<powerup_pickup_health_100
powerup_pickup_table_hi:
	.byte #>powerup_pickup_mask
	.byte #>powerup_pickup_mushroom
	.byte #>powerup_pickup_plus_one
	.byte #>powerup_pickup_bomb
	.byte #>powerup_pickup_r_bag
	.byte #>powerup_pickup_health_25
	.byte #>powerup_pickup_health_50
	.byte #>powerup_pickup_health_100
powerup_pickup_delegator: subroutine
	; y = powerup type
        lda powerup_pickup_table_lo,y
        sta temp00
        lda powerup_pickup_table_hi,y
        sta temp01
        jmp (temp00)
        
        
        
powerup_pickup_mask: subroutine
        inc mask_shield
        inc mask_shield
        inc mask_shield
        jsr sfx_powerup_mask
	rts
        
        
powerup_pickup_mushroom: subroutine
	jsr sfx_powerup_mushroom
	lda #$7f
        sta shroom_counter
	rts
powerup_mushroom_update: subroutine
	lda shroom_counter
        beq .shroom_done
	lda wtf
        and #$03
        bne .shroom_done
        dec shroom_counter
        bne .audio_bend_up_or_down
.end_of_shroom
	; XXX this will load wrong colors during boss fights
        jsr palette_level_load
        jsr player_update_colors
        lda #$00
        sta shroom_mod
        rts
.audio_bend_up_or_down
	lda shroom_counter
        cmp #$3f
        bcc .down
.up
	inc shroom_mod
        rts
.down
	dec shroom_mod
.shroom_done
	rts
        
        
powerup_pickup_plus_one: subroutine
	inc player_lives
        jsr sfx_powerup_1up
	rts
        
        
powerup_pickup_bomb: subroutine
	; bomb_counter set inside sfx call
        ; 1hp enemy damage every other frame
	jsr sfx_powerup_bomb
	rts
powerup_bomb_update: subroutine
	lda bomb_counter
        beq .bomb_done
        dec bomb_counter
        lda sfx_noi_update_type
        bne .bomb_done
        lda #$04
        sta sfx_noi_update_type
.bomb_done
	rts
        
        
powerup_pickup_r_bag: subroutine
        lda #$ff
        sta r_bag_counter
        clc
        lda #$03
        adc player_autofire_s
        sta player_autofire_s
        lda #$20
        cmp player_autofire_s
        bcc .not_maxed_out
        lda player_autofire_s
.not_maxed_out
        sta player_autofire_s
	rts
        
        
powerup_pickup_health_25: subroutine
        jsr sfx_powerup_battery_25
        lda player_health
        clc
        adc #$40
        bcs powerup_player_max_energy
        sta player_health
	rts
        
powerup_pickup_health_50: subroutine
        jsr sfx_powerup_battery_50
        lda player_health
        clc
        adc #$80
        bcs powerup_player_max_energy
        sta player_health
	rts
        
powerup_pickup_health_100: subroutine
        jsr sfx_powerup_battery_100
powerup_player_max_energy:
	lda #$ff
        sta player_health
	rts

        