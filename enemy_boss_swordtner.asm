
; things the bat entities need to know
; boss_x  : x body position
; boss_y  :  y body position

; state_v0 : current mode
;	0 - bounce around and fire
;	1 - lunge at player and around to box
;	2 - aim and shake
; state_v1 : cycle counter
; state_v2 : velocity
; state_v4 : emiter type
; state_v5 : scratch for spawn loop
; state_v6 : alt face countdowner
; state_v7 : 2nd form true


; swordtner palette
; $07, $17, $3d
; $0c, $2d, $31

boss_swordtner_spawn: subroutine
        ; claim 4 more slots for rest of body
        lda #boss_assist_id
        sta $03c0
        sta $03c8
        sta $03d0
        sta $03d8
        ; claim 1 more slot for eyeballs
        sta $0340
        ; setup initial state
        jsr get_oam_offset_from_ram_offset
        lda #$20
        sta oam_ram_x,y
        sta oam_ram_y,y
        lda #$15
        sta enemy_ram_ex,x
        ; set eye color
        lda #$01
        sta boss_eyes_pal
        ; offset song position
        lda #$0e
        sta audio_pattern_pos
	rts
        
        ; SWORDTNER
        ; PROVERB
        ; HERE
        
arc_bounce_x:
	; if ex < $0c then ex = $0c - ex
	hex 0b 0b 0a 09 08 07 05 05 04 03 02 01
        ; if ex == $0c then ex = 0
        ; if ex > $0c then ex = $17 - (ex - $0d)
        hex 01 17 16 15 14 13 13 11 10 0f 0e 0d
arc_bounce_y:
        ; if ex == $00 then ex = 0
        ; if ex < $0c then ex = $18 - ex
        hex 01 17 16 15 14 13 13 11 10 0f 0e 0d
        ; if ex > $0c then ex = $24 - ex
	hex 0b 0b 0a 09 08 07 05 05 04 03 02 01
        
swordtner_metasprite_offset:
	byte	#$10, #$20, #$30, #$40
swordtner_metasprite_id:
	byte 	#$82, #$a2, #$a2, #$c2
        
swordtner_rng_bullet:
        jsr get_next_random
        and #$07
        clc
        adc #$24
        sta dart_sprite
        rts
        
        
        
boss_swordtner_cycle: subroutine
	; shrink width of hit box
	lda #$04
        sta collision_0_w
        adc collision_0_x
        sta collision_0_x
	; check for player collision with blade
        lda #$50
        sta collision_0_h
        jsr player_collision_detect
        beq .no_collision
        jsr enemy_gives_damage
        lda #$00
        sta state_v1
        lda #$01
        sta state_v0
        ; change facial experession
        lda #$20
        sta state_v6
.no_collision


	; hitbox is face of swordtner
        lda #$0f
        sta collision_0_h
        lda #$12
        adc collision_0_y
        sta collision_0_y
        inc boss_dmg_handle_true
        jsr enemy_handle_damage_and_death
        cmp #$00
        beq .dont_change_face
        lda #$10
        sta state_v6
.dont_change_face
        dec boss_dmg_handle_true
        
        
        ; check for 2nd Form
        lda state_v7
        bne .2nd_form_done
        lda enemy_ram_hp,x
        cmp #25
        bcs .2nd_form_done
        lda #100
        adc enemy_ram_hp,x
        sta enemy_ram_hp,x
        inc state_v7
.2nd_form_done
        
        
; both modes use this
	; x
        lda boss_x
        clc
        adc #$04
        sta dart_x_origin
        ; y
        lda boss_y
        clc
        adc #$0c
        sta dart_y_origin
      
      
; act on current mode
	lda state_v0
        clc
        adc #boss_swordtner_state_jump_table_offset
        jsr jump_to_subroutine
        
        
	; y
	lda oam_ram_y,y
        ; y check for poor range
.check_too_low
	cmp #$88
        bcc .check_too_high
        lda #$8a
        sta oam_ram_y,y
.check_too_high
        cmp #$08
        bcs .check_y_softer_bounce
        lda #$06
        sta oam_ram_y,y
.check_y_softer_bounce
        ; y check for bounce
        cmp #$08
        bcc .bounce_y
        cmp #$88
        bcs .bounce_y
        bcc .dont_bounce_y
.bounce_y
        ldy enemy_ram_ex,x
        lda arc_bounce_y,y
        sta enemy_ram_ex,x
        ldy enemy_oam_offset
.dont_bounce_y
      

.set_boss_x_y
        ; set boxx x,y
        lda oam_ram_x,y
        sta boss_x
        jsr sprite_4_set_x
        lda oam_ram_y,y
        sta boss_y
        jsr sprite_4_set_y
        
        


; SWORDTNER
; MAIN BODY

        ; handle sprite
        lda #$62
        jsr sprite_4_set_sprite
        
        
	ldx #$03
.next_meta_sprite
	lda swordtner_metasprite_offset,x
        clc
        adc enemy_oam_offset
        tay
        lda boss_x
        jsr sprite_4_set_x
        lda boss_y
        adc swordtner_metasprite_offset,x
        jsr sprite_4_set_y
        ; check for face animation
        cpx #$00
        bne .not_face_sprite
        lda state_v6
        beq .normal_sprite
        dec state_v6
        lda #$84
        bne .plot_sprite
.not_face_sprite
	; check for 2nd form
        lda state_v7
        beq .normal_sprite
        lda swordtner_metasprite_id,x
        clc
        adc #$02
        bne .plot_sprite
.normal_sprite
        lda swordtner_metasprite_id,x
.plot_sprite
        jsr sprite_4_set_sprite
        dex
        bpl .next_meta_sprite
        
        ldx enemy_ram_offset
        ldy enemy_oam_offset
        
	; palette
	lda #$01
        jsr sprite_4_set_palette
        beq .hit
        clc
        adc #$01
.hit
        ldy #$c0
        jsr sprite_4_set_palette_no_process
        ldy #$d0
        jsr sprite_4_set_palette_no_process
        ldy #$e0
        jsr sprite_4_set_palette_no_process
        ldy #$f0
        jsr sprite_4_set_palette_no_process
    
        
        ; move last sprite to higher spot
        ; make room for eyeballs
        ldx #$03
.migrate_sprite_loop
	lda $02fc,x
        sta $0240,x
        dex
        bpl .migrate_sprite_loop
        
        ;ldx enemy_ram_offset
        ;ldy enemy_oam_offset
        
        ; eyeballs setup
        ldy enemy_oam_offset
        lda oam_ram_x,y
        clc 
        adc #$04
        sta temp00
        lda oam_ram_y,y
        clc
        adc #$10
        sta temp01
        jsr enemy_boss_eyes
        

.done
	jmp update_enemies_handler_next





swordtner_inside_bouncy_box_x: subroutine
	; returns 0 in a if false
	lda oam_ram_x,y
        cmp #$10
        bcc .outside_bouncy_box_x
        cmp #$60
        bcs .outside_bouncy_box_x
        lda #$00
        bcc .inside_bouncy_box_x
.outside_bouncy_box_x
	lda #$ff
.inside_bouncy_box_x
        rts





swordtner_emit_enemies: subroutine
	lda #$02
        sta state_v5
.spawn_loop
        jsr get_enemy_slot_1_sprite
        bcs .done
        clc
        lda #spark_id
        adc state_v5
        jsr enemy_spawn_delegator
        jsr get_oam_offset_from_ram_offset
        lda dart_x_origin
        sta oam_ram_x,y
        lda dart_y_origin
        sta oam_ram_y,y
        dec state_v5
        bpl .spawn_loop
.done
	jsr sfx_shoot_bullet
	ldx enemy_ram_offset
        ldy enemy_oam_offset
	rts



swordtner_emit_projectiles: subroutine
        ; velocity
        lda #$02
        sta dart_velocity
        ; sprite
        lda #$fe
        ;lda #$00
        sta dart_sprite
        ; dir adjustor
        lda #$00
        sta dart_dir_adjust
        jsr swordtner_rng_bullet
        jsr dart_spawn
        lda #$ff
        sta dart_dir_adjust
        jsr swordtner_rng_bullet
        jsr dart_spawn
        lda #$01
        sta dart_dir_adjust
        jsr swordtner_rng_bullet
        jsr dart_spawn
        rts




; mode 0 - bounce around and fire
boss_swordtner_mode_0: subroutine

	; fix x position after player death
	lda oam_ram_x,y
        bne .dont_fix_x
        lda #$20
        sta oam_ram_x,y
        sta oam_ram_y,y
.dont_fix_x

.bounce_and_fire
   	; change face before firing
        lda audio_pattern_pos
        cmp #$09
        bne .no_face_change
        lda #$05
        sta state_v6
.no_face_change
	lda audio_pattern_pos
        cmp #8
        bcc .before_snare
        cmp #12
        bcs .after_snare
        jmp .movement_skip
        
.before_snare
        tax
        lda arctang_velocities_lo,x
        sta state_v2
        bne .bounce_movement

.after_snare
	lda #<arctang_velocity_6.66
        sta state_v2
	

; MOVEMENT
.bounce_movement
        ldx enemy_ram_offset
        sta arctang_velocity_lo 
        jsr arctang_enemy_update
        ; x
        jsr swordtner_inside_bouncy_box_x
        beq .dont_bounce_x
.bounce_x
        ldy enemy_ram_ex,x
        lda arc_bounce_x,y
        sta enemy_ram_ex,x
        ldy enemy_oam_offset
.dont_bounce_x
        
.movement_skip



        ; spawn/fire on boss fight music main snare
	lda audio_frame_counter
        cmp #5
        bne .dont_emit
        lda audio_pattern_pos
        cmp #10
        bne .dont_emit
        lda state_v1
        cmp #$02
        bne .dont_next_state
        inc state_v0
        lda #$00
        sta state_v1
        rts
.dont_next_state
	lda state_v4
        and #$01
        bne .emit_enemies
.emit_projectiles
	jsr swordtner_emit_projectiles
	jmp .inc_state
.emit_enemies
        jsr swordtner_emit_enemies
.inc_state
        inc state_v1
.dont_emit

	rts
        
        

; mode 1 - aim for player and warn of attack
boss_swordtner_mode_shake: subroutine
	lda state_v1
        bne .init_done
.init
	inc state_v1
	jsr enemy_get_direction_of_player
        clc
        adc #$01
        jsr arctang_bound_dir
        sta enemy_ram_ex,x
	lda arctang_velocities_lo+1
        sta state_v2
.init_done
	; x shake
        jsr shake_8
        adc boss_x
        jsr sprite_4_set_x
        ; y shake
        jsr shake_8
        adc boss_y
        jsr sprite_4_set_y
        ; check if done
        inc state_v1
        lda state_v1
        cmp #$10
        bne .done
        lda #$02
        sta state_v0
.done
	rts
        
        

; mode 2 - lunges at player
boss_swordtner_mode_2: subroutine
        inc state_v1
	lda state_v1
	cmp #$40
        bcc .lunge_keep_going
        jsr swordtner_inside_bouncy_box_x
        bne .lunge_keep_going
        ; next state
        inc state_v4
        lda #$00
        sta state_v0
        sta state_v1
.lunge_keep_going
	lda state_v2
        sta arctang_velocity_lo 
        jsr arctang_enemy_update
.lunge_done
	rts
        
        
        
        