

; boss_x : x origin of sine pattern
; boss_y : y origin of sine pattern
; state_v0 : bottom lip position
; state_v1 : bottom lip animation counter
; state_v2 : sprites y pos temp
; state_v3 : y bounce sine direction
; state_v4 : sprite x position
; state_v5 : sprite y position


boss_moufs_spawn: subroutine
        lda #do_nothing_id
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
	rts
        
sprite_3_set_sprite: subroutine
	; a = left tile id
        ; y = oam ram offset
	sta oam_ram_spr,y
        clc
        adc #$01
	sta oam_ram_spr+$04,y
        adc #$01
	sta oam_ram_spr+$08,y
        rts
        
sprite_3_set_x: subroutine
	; a = x pos
        ; y = oam ram offset
	sta oam_ram_x,y
	clc
	adc #$08
	sta oam_ram_x+$04,y
	adc #$08
	sta oam_ram_x+$08,y
	adc #$08
	sta oam_ram_x+$0c,y
	rts
        
sprite_3_set_y: subroutine
	; a = y pos
        ; y = oam ram offset
	sta oam_ram_y,y
	sta oam_ram_y+$04,y
	sta oam_ram_y+$08,y
	rts
  
  
boss_moufs_cycle: subroutine

	; sine bounce moevemtn
        ; ac does x axis
	inc enemy_ram_ac,x
        ; pc does y axis
        lda state_v3
        and #$01
        bne .y_increase
.y_decrease
        dec enemy_ram_pc,x
        jmp .y_change_done
.y_increase
        inc enemy_ram_pc,x
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
        lda #$02
        sta oam_ram_att+$40
        sta oam_ram_att+$44
        
        
        
        ; LIPPPPS
        
        lda state_v5
        sta state_v2

	; row 1
	lda #$86
        jsr sprite_3_set_sprite
	lda state_v4
        jsr sprite_3_set_x
	lda state_v2
        jsr sprite_3_set_y
        lda #$01
        jsr sprite_4_set_palette
        
        ; row 2
        ldy #$c0
        
        lda state_v2
        adc #$08
        sta state_v2
        
	lda #$96
        jsr sprite_3_set_sprite
	lda state_v4
        jsr sprite_3_set_x
	lda state_v2
        jsr sprite_3_set_y
        lda #$01
        jsr sprite_4_set_palette
        
        ; row 3
        ldy #$e0
        
        lda state_v2
        adc #$05
        sta state_v2
        
	lda #$a6
        jsr sprite_3_set_sprite
        ; x
	lda state_v4
        jsr sprite_3_set_x
        ; y
	lda state_v2
        lda state_v1
        lsr
        tax
        lda sine_2bits,x
        ldx enemy_ram_offset
        clc
	adc state_v2
        jsr sprite_3_set_y
        ; palette
        lda #$01
        jsr sprite_4_set_palette
        
        
        inc state_v1
        inc state_v1
        inc state_v1
        
        ; row 4
        ldy #$d0
        
        lda state_v2
        adc #$04
        sta state_v2
        
	lda #$b6
        jsr sprite_3_set_sprite
        ; x
	lda state_v4
        jsr sprite_3_set_x
        ; y
	lda state_v2
        lda state_v1
        lsr
        tax
        lda sine_3bits,x
        sta state_v0
        ldx enemy_ram_offset
        clc
	adc state_v2
        jsr sprite_3_set_y
        ; palette
        lda #$01
        jsr sprite_4_set_palette
        
        
        inc state_v1
        inc state_v1
        
        ; fire time?
        lda state_v0
        cmp #$07
        bne .done
        lda wtf
        and #$07
        bne .done
        
.dart_fire
        lda state_v4
        clc
        adc #$0a
        sta collision_0_x
        lda state_v5
        clc
        adc #$0f
        sta collision_0_y
        jsr dart_spawn
        cpx #$ff
        beq .done
        lda #<arctang_velocity_2.5
        sta enemy_ram_pc,x
        lda #$02
        sta oam_ram_att,y
        lda #$fe
        sta oam_ram_spr,y
        ldx enemy_ram_offset
        ldy enemy_oam_offset
        

.done
        
	
	jmp update_enemies_handler_next
