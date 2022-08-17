

; boss_x : x origin of sine pattern
; boss_y : y origin of sine pattern
; state_v0 : bottom lip position
; state_v1 : bottom lip animation counter
; state_v2 : 
; state_v3 : y bounce sine direction
; state_v4 : sprite x position
; state_v5 : sprite y position
; state_v6 : upper lip up sprite offset


boss_moufs_spawn: subroutine
        lda #boss_assist_id
        ; eyeballs
        sta $0340
        sta $0348
        ; lip rows
        sta $03c0
        sta $03c8
        sta $03d0
        lda #$40
        sta enemy_ram_x,x
        sta state_v4
        sta enemy_ram_y,x
        sta state_v5
        lda #$08
        sta boss_x
        lda #$20
        sta boss_y
        lda #chomps_id
        ldx #$90
        jsr enemy_spawn_delegator
        lda #chomps_id
        ldx #$98
        jsr enemy_spawn_delegator
	rts
        
        
  
moufs_oam_offset_table:
	byte $b0, $c0, $e0, $d0
moufs_sprite_offset_table:
	byte $00, $10, $20, $30
moufs_y_offset_table:
	byte $00, $08, $0d, $10
        
  
boss_moufs_cycle: subroutine
        lda state_v4
        sta collision_0_x
        lda state_v5
        sta collision_0_y
        lda #$14
        sta collision_0_w
        lda #$20
        sta collision_0_h
        
        inc boss_dmg_handle_true
        jsr enemy_handle_damage_and_death
        dec boss_dmg_handle_true

	; set upper lip default sprite
        lda #$00
        sta state_v6
        
	; sine bounce movement
        ; ac does x axis
	inc enemy_ram_ac,x
        ; pc does y axis
        lda state_v3
        and #$01
        bne .y_increase
.y_decrease
	; arc backwards
        dec enemy_ram_pc,x
        lda enemy_ram_pc,x
        cmp #$b3
        bcs .y_change_done
        inc state_v6
        jmp .y_change_done
.y_increase
	; arc forwards
        inc enemy_ram_pc,x
        lda enemy_ram_pc,x
        cmp #$ce
        bcc .y_change_done
        inc state_v6
.y_change_done
        ldy enemy_ram_pc,x
        lda sine_table,y
        ldy enemy_oam_offset
        cmp #$80
        bne .dont_change_dir
        inc state_v3
.dont_change_dir
        ; x
        lda enemy_ram_ac,x
        clc
        adc #$40
        lsr
        tax
        lda sine_6bits,x
        clc
        adc boss_x
        sta state_v4
        ldx enemy_ram_offset
	; y
        lda enemy_ram_pc,x
        tax
        lda sine_table,x
        clc
        adc boss_y
        sta state_v5
        ldx enemy_ram_offset
        
        ; palette
        lda #$01
        jsr sprite_4_set_palette
        sta temp01
        
        
        ; EYEBALLLZ
        lda player_y_hi
        cmp state_v5
        bcs .look_down
.look_up
	lda #$c6
        bne .look_set_sprites
.look_down
	lda #$d6
.look_set_sprites
        sta oam_ram_spr+$40
        sta oam_ram_spr+$44
        inc oam_ram_spr+$44
        
        lda state_v4
        sta oam_ram_x+$40
        clc
        adc #$11
        sta oam_ram_x+$44
        lda state_v5
        sbc #$04
        sta oam_ram_y+$40
        sta oam_ram_y+$44
        lda temp01
        beq .hit
        lda #$02
.hit
        sta oam_ram_att+$40
        sta oam_ram_att+$44
        
        
        
        ; LIPPPPS
        
        
        
        ; y row 3
        lda state_v1
        lsr
        tax
        lda sine_2bits,x
        sta temp02
        
        inc state_v1
        inc state_v1
        inc state_v1
        
        ; y row 4
        lda state_v1
        lsr
        tax
        lda sine_3bits,x
        sta state_v0
        sta temp03
        
        inc state_v1
        inc state_v1
        inc state_v1
        
	; row 1 sprite
        ldy #$b0
        lda state_v6
        beq .lip_up
.lip_down
	lda #$65
        sta state_v6
        bne .upper_lip_set_sprite
.lip_up
	lda #$86
        sta state_v6
.upper_lip_set_sprite
        
        
        
        ldx #$00
.mouf_sprites_loop
	ldy moufs_oam_offset_table,x
	; sprite
	; a = left tile id
        ; y = oam ram offset
        cpx #$02
        bcs .sprite_normal
.sprite_custom
	lda state_v6
        bne .sprite_chosen
.sprite_normal
        lda #$86
.sprite_chosen
	clc
        adc moufs_sprite_offset_table,x
	sta oam_ram_spr,y
        clc
        adc #$01
	sta oam_ram_spr+$04,y
        adc #$01
	sta oam_ram_spr+$08,y
	; x
        ; a = x pos
        ; y = oam ram offset
        lda state_v4
	sta oam_ram_x,y
	clc
	adc #$08
	sta oam_ram_x+$04,y
	adc #$08
	sta oam_ram_x+$08,y
	adc #$08
	sta oam_ram_x+$0c,y
        ; y
	; a = y pos
        ; y = oam ram offset
        lda state_v5
        clc
        adc moufs_y_offset_table,x
        cpx #$02
        bcc .no_y_adjustments
        cpx #$03
        beq .bottom_sprite
.almost_bottom_sprite
        adc temp02
        bne .no_y_adjustments
.bottom_sprite
	adc temp03
.no_y_adjustments
	sta oam_ram_y,y
	sta oam_ram_y+$04,y
	sta oam_ram_y+$08,y
        ; pal / attr
        lda temp01
        jsr sprite_4_set_palette_no_process
        ; check next
        inx
        cpx #$04
        bne .mouf_sprites_loop
        
        
        ldx enemy_ram_offset

        
        
        ; fire time?
        lda state_v0
        cmp #$07
        bne .done
        lda wtf
        and #$07
        bne .done
        
.dart_fire
	; x
        lda state_v4
        clc
        adc #$0a
        sta dart_x_origin
        ; y
        lda state_v5
        clc
        adc #$0f
        sta dart_y_origin
        ; velocity
        lda enemy_ram_pc,x
        sbc #$80
        lsr
        lsr
        lsr
        lsr
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

.done
        
	
	jmp update_enemies_handler_next
