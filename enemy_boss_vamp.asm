

; things the bat entities need to know
; boss_x  : center offset
; boss_y  : center offset
; state_v0 : state
; state_v1 : 
; state_v2 : vamp x osc offset
; state_v3 :
; state_v4 ; bat circle size
; state_v5 ; 

; XXX state var for bats being visible?

; states
; 0 : coming on screen from the left
; 1 : move up and down with throbbing circle
; 2 : circle becomes shield
; 3 : shield oscillation
; 4 : shield attacks player
; 5 : vampire sucks in bats
; 6 : vampire lunges at player and back
; 7 : vampire blows out bats

boss_vamp_bat_spawn: subroutine
	; a = animation counter for ex
	; x = bat slot in enemy ram
	lda #$09
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
	rts
        
        
boss_vamp_bat_cycle: subroutine
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_get_damage_this_frame
        cmp #$00
        bne .not_dead
.is_dead
	inc phase_kill_count
        
        lda enemy_ram_type,x
        jsr enemy_give_points
        
        ; change it into crossbones!
        jsr sfx_enemy_death
        lda #$01
	ldx enemy_ram_offset
        sta enemy_ram_type,x
        jmp .done
.not_dead
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
        sbc temp03 ; XXX this might need to be calculated per bat
	ldx enemy_ram_offset
        sta oam_ram_x,y
        ; update y pos
        lda temp01
        clc
        adc #$40
        ;clc
        ;adc enemy_ram_ac,x
        ;clc
        ;adc wtf
        tax
        lda temp02
        jsr sine_of_scale
        clc
        adc boss_y
        sec
        sbc temp03
	ldx enemy_ram_offset
        sta oam_ram_y,y
        ; interpret animation
        lda enemy_ram_ex,x
        lsr
        lsr
        and #%00000011
        cmp #$00
        bne .not_frame0
        lda #$39
        jmp .frame_done
.not_frame0
        cmp #$02
        bne .not_frame2
        lda #$3b
        jmp .frame_done
.not_frame2
	lda #$3a        	
.frame_done
        sta oam_ram_spr,y
        lda #$01
        jsr enemy_set_palette
.done
	jmp update_enemies_handler_next
	
        
BOSS_VAMP_STATE_TABLE: 
	.word boss_vamp_state_idle_update
        .word boss_vamp_state_suck_bats
        .word boss_vamp_state_attack
        .word boss_vamp_state_blow_bats
        
boss_vamp_update_delegator:
	lda state_v0
        asl
        tax
        lda BOSS_VAMP_STATE_TABLE,x
        sta temp00
        inx
        lda BOSS_VAMP_STATE_TABLE,x
        sta temp01
        jmp (temp00)
        
        
        
boss_vamp_state_idle_update: subroutine
	lda state_v4
	; calc x
        clc
        lda #$03
        adc state_v2
        sta state_v2 ; x sine
        lsr
        tay
	ldx enemy_ram_offset
        lda enemy_ram_x,x
        clc
        adc sine_4bits,y
        sta boss_x
        ldy enemy_oam_offset
	sta oam_ram_x,y
	sta oam_ram_x+8,y
	clc
	adc #$07
	sta oam_ram_x+4,y
	sta oam_ram_x+12,y
        lda boss_x
        clc
        adc #$05 ; add half of vampire size and subtract half of bat size?
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
        adc #$04 ; add half of vampire size and subtract half of bat size?
        sta boss_y
        rts
        
        
boss_vamp_state_suck_bats: subroutine
	dec state_v4
        bne .done
        inc state_v0
.done
	rts
        
        
boss_vamp_state_attack: subroutine
	inc state_v0
	rts
        
        
boss_vamp_state_blow_bats: subroutine
	inc state_v4
        lda #$40
        cmp state_v4
        bne .done
        lda #$00
        sta state_v0
.done
	rts

        
boss_vamp_spawn: subroutine
	lda #$08
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$60
        sta enemy_ram_x,x
        lda #$15
        sta enemy_ram_y,x 
        ; XXX not sure if we need this here
        lda #$0d
        sta temp00 ; target count of bat underlings; d = 13
        lda #$00
        sta temp01
        sta temp02
        lda #$40
        sta state_v4 ; minimum bat circle size
.bat_spawn_loop
	; a = animation counter / v1
	; x = slot in enemy ram 
        ; y = boss slot in ram  / v3
        ; stash boss slot in pattern counter
	;jsr get_enemy_slot_1_sprite
        ldx temp02
        lda temp01
        sta enemy_ram_ex,x
        clc
        adc #$14
        sta temp01
        lda #$08
        adc temp02
        sta temp02
	dec temp00
        beq .done
        jmp .bat_spawn_loop
.done
   	rts



boss_vamp_cycle: subroutine
        clc
        lda oam_ram_x,y
        adc #$01
        sta collision_0_x
        lda #$0d
        sta collision_0_w
        lda #$10
        sta collision_0_h
        jsr enemy_get_damage_this_frame
        cmp #$00
        bne .not_dead
.is_dead       
	inc phase_kill_count
	; give points
        lda #$ff
        lda enemy_ram_type,x
        jsr enemy_give_points
        ; change it into crossbones!
        jsr sfx_enemy_death
        lda #$01
        sta enemy_ram_type,x
        jmp sprite_4_cleanup_for_next
               
.not_dead    
        inc enemy_ram_ac,x
        bne .dont_inc_state
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
        ; update animation
        inc enemy_ram_ex,x
        ; respawn if slot is empty
        lda enemy_ram_type,x
        cmp #$00
        bne .dont_respawn_bat
        lda enemy_ram_ex,x
        jsr boss_vamp_bat_spawn
.dont_respawn_bat
        lda #$08
        clc
        adc temp00
        sta temp00
        cmp #$68
        bne .bat_update_loop
        
        jsr boss_vamp_update_delegator
        
; sprite tiles
        lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        and #$03
        cmp #$03
        bne .good_frame
        lda #$01
.good_frame
        asl
        clc
        adc #$9a
        ;lda #$9c
        jsr sprite_4_set_sprite
        ; palette
        lda #$02
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
        
.now_lets_add_eyes
	ldx #$fc
        lda #$a9
        sta oam_ram_spr,x
        lda #$01
        sta oam_ram_att,x
        ; find x
        lda oam_ram_x,y
        clc
        adc #$03
        sta oam_ram_x,x
        ; check if rudy is left of vampire
        lda oam_ram_x,y
        cmp player_x_hi
        bcc .looking_right
.looking_left
        lda #$99
        sta oam_ram_spr,x
	inc oam_ram_x,x
.looking_right
	; find y
        lda oam_ram_y,y
        sta oam_ram_y,x
        lda oam_ram_spr,y
        cmp #$9a
        bne .dont_adjust_for_open_mouth
        dec oam_ram_y,x
.dont_adjust_for_open_mouth
        lda oam_ram_y,x
        clc
        adc #$1c
        sec
        sbc player_y_hi
        bcc .looking_down
        clc
        adc #$cc
        bcs .looking_up
.looking_across
	lda oam_ram_spr,x
        cmp #$99
        beq .adjust_for_left_looking
	inc oam_ram_x,x
        jmp .done
.adjust_for_left_looking
	dec oam_ram_x,x
        jmp .done
.looking_up
	dec oam_ram_y,x
        jmp .done
.looking_down
	inc oam_ram_y,x
.done
	jmp update_enemies_handler_next
        