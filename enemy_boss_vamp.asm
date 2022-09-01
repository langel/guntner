

; things the bat entities need to know
; boss_x  : center offset
; boss_y  : center offset
; state_v0 : state
; state_v1 : spawn x to target
; state_v2 : x sine position
; state_v3 : mouth position ( 0 = closed ; < 8 midframe ; > 8 open )
; state_v4 : bat circle size / other states counter
; state_v5 : bat visibility
; state_v6 : rng target
; state_v7 : mouth frame current
; enemy_ram_pc : mouth frame target
; enemy_ram_ac : idle_update counter
; enemy_ram_ex : arctang direction



boss_vamp_bat_spawn: subroutine
	; x = bat slot in enemy ram
	lda #boss_vamp_bat_id
        sta enemy_ram_type,x
        rts
        
        
boss_vamp_bat_cycle: subroutine
	; bats visible?
	lda state_v5
        beq .bats_not_visible
        ; collision detection
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
        ; update x pos
        lda enemy_ram_ex,x
        sta temp01 ; position on circle
        lda state_v4
        cmp enemy_ram_ac,x
        bcc .use_vamp_circle_size
        lda enemy_ram_ac,x
        inc enemy_ram_ac,x
        inc enemy_ram_ac,x
        inc enemy_ram_ac,x
.use_vamp_circle_size
	sta temp02 ; size of circle
        lsr
        sta temp03 ; half of circle size
        lda temp02
        ldx temp01
        jsr sine_of_scale
        clc
        adc boss_x
        sec
        sbc temp03 
	ldx enemy_ram_offset
        sta oam_ram_x,y
        ; update y pos
        lda temp01
        clc
        adc #$40
        tax
        lda temp02
        jsr sine_of_scale
        clc
        adc boss_y
        sec
        sbc temp03
	ldx enemy_ram_offset
        sta oam_ram_y,y
        ; interpret animation frame
        lda enemy_ram_ex,x
        lsr
        lsr
        and #%00000011
	clc
        adc #$38
        sta oam_ram_spr,y
        ; palette
        lda $03be ; use vamp hc
        sta enemy_ram_hc,x
        lda #$02
        jsr enemy_set_palette
.done
	jmp update_enemies_handler_next
        
.bats_not_visible
	lda #$ff
        sta oam_ram_y,y
        bne .done
        
	
        
        ; I VANT TO
        ; SUCK YOUR
        ; BLEEDS !!       
boss_vamp_spawn: subroutine

        lda #boss_assist_id
        sta $03d8
        ; set eye color
        lda #$02
        sta boss_eyes_pal
        ; set spawn x
        lda #$a0
        sta state_v2
        ; set spawn y
        lda #$15
        sta enemy_ram_y,x 
        ; bats are visible
        lda #$01
        sta state_v5
        ; minimum bat circle size
        lda #$40
        sta state_v4 
        ; rando target
        lda #$80
        sta state_v6
        ; target count of bat underlings; 
        ; #$0d = 13 but we `bpl loopin`
        ldy #$0c
        sta temp00 
        ; set temp counters to 0
        lda #$00
        sta temp01
        sta temp02
.bat_spawn_loop
	; a = animation counter / v1
	; x = slot in enemy ram 
        lda temp01
        ldx temp02
        sta enemy_ram_ex,x
        clc
        adc #$14
        sta temp01
        lda #$08
        adc temp02
        sta temp02
	dey 
        bpl .bat_spawn_loop
.done
   	rts



boss_vamp_cycle: subroutine
        lda #$0d
        sta collision_0_w
        lda #$10
        sta collision_0_h
        
        inc boss_dmg_handle_true
        jsr enemy_handle_damage_and_death
        dec boss_dmg_handle_true
; IS DEAD?
        lda boss_death_happening
        beq .not_dead
        cmp #$02
        beq .bats_spawned
        inc state_v5 ; bats are visible
        lda #$56
        sta state_v4 ; bat circle size
        sta state_v7 ; mouf open
        ; track bats are gonna spawn
        inc boss_death_happening
        lda oam_ram_x,y
        sta boss_x
        lda oam_ram_y,y
        sta boss_y
        ; reset enemy handler so bats show
	jmp update_enemies_reset
.bats_spawned
.not_dead
        
; MOUTH HANDLER
; state_v7 : mouth frame current
; enemy_ram_pc : mouth frame target
	lda state_v7
        cmp enemy_ram_pc,x
        beq .mouth_is_fine
        bcs .mouth_close
.mouth_open
	inc state_v7
        bne .mouth_is_fine
.mouth_close
	dec state_v7
.mouth_is_fine

; STATE behavior     
        jsr boss_vamp_update_state_delegator
        ldx enemy_ram_offset
        
	; SPRITE tiles
        lda state_v7
        lsr
        lsr
        lsr
        and #$03
        cmp #$03
        bne .good_frame
        lda #$02
.good_frame
        asl
        clc
        adc #$9a
        jsr sprite_4_set_sprite
        
        ; palette
        lda #$01
        jsr sprite_4_set_palette
        bne .not_hit
        lda #$80
        sta state_v7
.not_hit
        
        ; eyeballs
        lda oam_ram_x,y
        clc
        adc #$03
        sta temp00
        lda oam_ram_y,y
        sta temp01
        lda oam_ram_spr,y
        cmp #$9e
        bne .dont_adjust_for_open_mouth
        dec temp01
.dont_adjust_for_open_mouth
	jsr enemy_boss_eyes

	jmp update_enemies_handler_next



        
boss_vamp_update_state_delegator:
	lda state_v0
        clc
        adc #boss_vamp_state_jump_table_offset
        sta temp00
        jmp jump_to_subroutine
        
        
        
        
        
boss_vamp_calc_boss_x_y: subroutine
	; calc x
        lda state_v2 ; x sine
        lsr
        tay
        lda enemy_ram_x,x
        clc
        adc sine_6bits,y
        sta boss_x
        ldy enemy_oam_offset
        jsr sprite_4_set_x
        lda boss_x
        clc
        adc #$04 ; add half of vampire size and subtract half of bat size?
        sta boss_x
	; calc y
        lda enemy_ram_ac,x
        tax
	lda sine_table,x
	lsr
	ldx enemy_ram_offset
	clc
        adc enemy_ram_y,x
        sta boss_y
        jsr sprite_4_set_y
        lda boss_y
        clc
        adc #$0a ; add half of vampire size and subtract half of bat size?
        sta boss_y
	rts
        

        
boss_vamp_state_idle_update: subroutine
	; update x home pos
        lda enemy_ram_x,x
        cmp #$40
        bcs .dont_inc_x
        inc enemy_ram_x,x
        inc state_v1
.dont_inc_x
.done_with_x
	; update x pos sine offset
        clc
        lda #$03
        adc state_v2
        sta state_v2
        jsr boss_vamp_calc_boss_x_y
.next_state_check
        inc enemy_ram_ac,x
        lda enemy_ram_ac,x
        cmp state_v6
        bne .dont_inc_state
.setup_next_state
	lda rng0
        sta state_v6
        inc state_v0
.dont_inc_state
        lda enemy_ram_ac,x
        asl
        asl
        cmp #$80
        bcs .shrink_bat_circle
.grow_bat_circle
	inc state_v4
        jmp .bat_circle_adjust_done
.shrink_bat_circle
	dec state_v4
.bat_circle_adjust_done
	; BAT UPDATE LOOP
        lda #$00
        sta temp00
.bat_update_loop
	ldx temp00
        ; update circle position
        inc enemy_ram_ex,x
        ; respawn if slot is empty
        lda enemy_ram_type,x
        bne .dont_respawn_bat
        jsr boss_vamp_bat_spawn
        lda #$20
        sta state_v7
.dont_respawn_bat
        lda #$08
        clc
        adc temp00
        sta temp00
        cmp #$68
        bne .bat_update_loop
        rts
        
        
boss_vamp_state_suck_bats: subroutine
	; open mouth
	lda #$40
        sta enemy_ram_pc,x
        lda #$10
        sta state_v7
	lda state_v4
        sec
        sbc #$05
        sta state_v4
        bcs .done
.setup_next_state
        inc state_v0 ; next state
        lda #$00
        sta state_v4
        dec state_v5 ; hide bats
        lda oam_ram_x,y
        sta boss_x
        lda oam_ram_y,y
        sta boss_y
.done
	rts
        
        
boss_vamp_state_shake: subroutine
	; close mouth
        lda #$00
        sta enemy_ram_pc,x
	; x shake
        jsr shake_8
        adc boss_x
        jsr sprite_4_set_x
        ; y shake
        jsr shake_8
        adc boss_y
        jsr sprite_4_set_y
        ; counter
	inc state_v4
        lda #15
        cmp state_v4
        bcs .done
.setup_next_state
	; next state
	inc state_v0
        ; reset v4 counter
        lda #$00
        sta state_v4
        ; load arctang dir into v6
        jsr enemy_get_direction_of_player
        sta enemy_ram_ex,x
.done
	rts
        
boss_vamp_state_lunge: subroutine
        lda #<arctang_velocity_6.66
        sta arctang_velocity_lo
	jsr arctang_enemy_update
        ldy enemy_oam_offset
        lda oam_ram_x,y
        jsr sprite_4_set_x
        lda oam_ram_y,y
        jsr sprite_4_set_y
	inc state_v4
        lda #$14
        cmp state_v4
        bcs .done
.setup_next_state
	lda enemy_ram_ex,x
        sec
        sbc #12
        bcs .valid_range
        adc #24
.valid_range
	sta enemy_ram_ex,x
	inc state_v0
.done
	rts
        
boss_vamp_state_retreat: subroutine
        lda #<arctang_velocity_6.66
        sta arctang_velocity_lo
	jsr arctang_enemy_update
        ldy enemy_oam_offset
        lda oam_ram_x,y
        jsr sprite_4_set_x
        lda oam_ram_y,y
        jsr sprite_4_set_y
	dec state_v4
        bne .done
.setup_next_state
	inc state_v0
        lda #$00
        sta state_v4
        inc state_v5 ; show bats
        lda state_v1 ; x home on the way to #$60
        sta enemy_ram_x,x
        lda #$15
        sta enemy_ram_y,x 
        jsr boss_vamp_calc_boss_x_y
	; open mouth then close
; state_v7 : mouth frame current
; enemy_ram_pc : mouth frame target
	lda #$00
        sta enemy_ram_pc,x
        lda #$20
        sta state_v7
.done
	rts
        
        
boss_vamp_state_blow_bats: subroutine
	inc state_v4
	inc state_v4
	inc state_v4
        lda #$40
        cmp state_v4
        bcs .done
.setup_next_state
        lda #$00
        sta state_v0
.done
	rts

 