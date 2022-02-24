

;boss_x		byte
;boss_y		byte
;boss_hp		byte
;boss_v0		byte
;boss_v1		byte
;boss_v2		byte
;boss_v3		byte
;boss_v4		byte
;boss_v5		byte

; things the bat entities need to know
; boss_x  : center offset
; boss_y  : center offset
; boss_v0 : state
; boss_v1 : 
; boss_v2 : vamp x osc offset
; boss_v3 :
; boss_v4 ; bat circle size
; boss_v5 ; bat half circle size / offset to center

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
	; a = animation counter
	; x = bat slot in enemy ram
        ; y = boss slot in enemy ram
        ; stash boss slot in pattern counter
        sta enemy_ram_ac,x
	lda #$09
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda enemy_ram_y,y
        tya
        sta enemy_ram_pc,x
        txa
        lsr
        clc
        adc #$20
        sta enemy_ram_ex,x
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
        lda enemy_ram_ac,x
        tax
        lda boss_v4
        jsr sine_of_scale
        clc
        adc boss_x
        sec
        sbc boss_v5
	ldx enemy_ram_offset
        sta enemy_ram_x,x
        sta oam_ram_x,y
        ; update y pos
        lda enemy_ram_ac,x
        clc
        adc enemy_ram_ac,x
        adc wtf
        tax
        lda boss_v4
        jsr sine_of_scale
        clc
        adc boss_y
        sec
        sbc boss_v5
	ldx enemy_ram_offset
        sta enemy_ram_x,x
        sta oam_ram_y,y
        ; update animation
        inc enemy_ram_ac,x
        lda enemy_ram_ac,x
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
        txa
        lsr
        clc
        adc #$20
        sta enemy_ram_ex,x
        PPU_SETADDR $3F15
        lda #$12
        sta PPU_DATA
        PPU_SETADDR $3F19
        lda #$15
        sta PPU_DATA
        lda #$00
        sta PPU_DATA
        lda #$37
        sta PPU_DATA
        ; XXX not sure if we need this here
        lda #$0d
        sta boss_v0 ; target count of bat underlings; d = 13
        lda #$00
        sta boss_v1
        txa
        tay
        sty boss_v3
        lda #$10
        sta boss_v4 ; minimum bat circle size
.bat_spawn_loop
	; a = animation counter / v1
	; x = slot in enemy ram 
        ; y = boss slot in ram  / v3
        ; stash boss slot in pattern counter
	jsr get_enemy_slot_1_sprite
        tax
        lda boss_v1
        clc
        adc #$14
        sta boss_v1
        ldy boss_v3
        jsr boss_vamp_bat_spawn
	dec boss_v0
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
        lda #$40
        lda boss_v0
        lda enemy_ram_ac,x
        asl
        asl
        cmp #$80
        bcs .shrink_bat_circle
.grow_bat_circle
	inc boss_v4
        jmp .bat_circle_adjust_done
.shrink_bat_circle
	dec boss_v4
.bat_circle_adjust_done
	lda boss_v4
        sta boss_v5 ; half of bat circle size
	; calc x
        inc boss_v2 ; x sine
        inc boss_v2 ; x sine
        inc boss_v2 ; x sine
        lda boss_v2
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
	; tiles
        lda #$27
        jsr sprite_4_set_sprite
        ; palette
        lda #$02
        jsr enemy_set_palette
        sta oam_ram_att+4,y
        sta oam_ram_att+8,y
        sta oam_ram_att+12,y
.now_lets_add_eyes
	ldx #$fc
        lda #$36
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
        lda #$26
        sta oam_ram_spr,x
	inc oam_ram_x,x
.looking_right
	; find y
        lda oam_ram_y,y
        sta oam_ram_y,x
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
        cmp #$26
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
        