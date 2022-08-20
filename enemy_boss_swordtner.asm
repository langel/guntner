
; things the bat entities need to know
; boss_x  : x body position
; boss_y  :  y body position

; state_v2 : velocity
; state_v3 : state counter

; state_v6 : alt face countdowner
; state_v7 : 2nd form true

sword_up_dir	EQM	5
sword_down_dir	EQM	23

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
        ; cache direction velocities
        ldx #$01
        lda arctang_velocities_lo,x
        sta state_v2 ; current velocity
	rts
        
        ; SWORDTNER
        ; PROVERB
        ; HERE
        
arc_bounce_x:
	; if ex < $0c then ex = $0c - ex
	hex 0c 0b 0a 09 08 07 06 05 04 03 02 01
        ; if ex == $0c then ex = 0
        ; if ex > $0c then ex = $17 - (ex - $0d)
        hex 00 17 16 15 14 13 12 11 10 0f 0e 0d
arc_bounce_y:
        ; if ex == $00 then ex = 0
        ; if ex < $0c then ex = $18 - ex
        hex 00 17 16 15 14 13 12 11 10 0f 0e 0d
        ; if ex > $0c then ex = $24 - ex
	hex 0c 0b 0a 09 08 07 06 05 04 03 02 01
        
swordtner_metasprite_offset:
	byte	#$10, #$20, #$30, #$40
swordtner_metasprite_id:
	byte 	#$82, #$a2, #$a2, #$c2
        
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
        ldy enemy_oam_offset
        lda #$b0
        adc oam_ram_x,y
        sta oam_ram_x,y
        ; change facial experession
        lda #$20
        sta state_v6
.no_collision

	; hitbox is face of swordtner
        lda #$10
        sta collision_0_h
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
      
      
      	; state counter range 0..99
        ; sword moves until 60
        ; fires at 75
      
      	; state counter
      	inc state_v3
        lda state_v3
        cmp #100
        bne .dont_reset_state_counter
        lda #$00
        sta state_v3
.dont_reset_state_counter
        cmp #75
        bne .dont_fire
.fire
	; XXX copied from moufs
        ; XXX should be its own function
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
        ; velocity
        lda #$01
        sta dart_velocity
        ; sprite
        lda #$fe
        ;lda #$00
        sta dart_sprite
        ; dir adjustor
        lda #$00
        sta dart_dir_adjust
        jsr dart_spawn
        lda #$ff
        sta dart_dir_adjust
        jsr dart_spawn
        lda #$01
        sta dart_dir_adjust
        jsr dart_spawn
.dont_fire
        
        lda state_v3
        cmp #60
        bcs .movement_skip

; MOVEMENT
	lda state_v2
        sta arctang_velocity_lo 
        jsr arctang_enemy_update
        ; x
	lda oam_ram_x,y
        cmp #$10
        bcc .bounce_x
        cmp #$60
        bcs .bounce_x
        bcc .dont_bounce_x
.bounce_x
        ldy enemy_ram_ex,x
        lda arc_bounce_x,y
        ldy enemy_oam_offset
        sta enemy_ram_ex,x
        ;inc enemy_ram_ex,x
.dont_bounce_x
	; y
	lda oam_ram_y,y
        cmp #$04
        bcc .bounce_y
        cmp #$88
        bcs .bounce_y
        bcc .dont_bounce_y
.bounce_y
        ldy enemy_ram_ex,x
        lda arc_bounce_y,y
        ldy enemy_oam_offset
        sta enemy_ram_ex,x
        ;dec enemy_ram_ex,x
.dont_bounce_y
        
.movement_skip
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
	lda #$02
        jsr sprite_4_set_palette
        beq .hit
        sec
        sbc #$01
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
