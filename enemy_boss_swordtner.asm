
; things the bat entities need to know
; boss_x  : topleft offset
; boss_y  : topleft offset
; state_v0 : up velocity
; state_v1 : down velocity
; state_v4 : x body position
; state_v5 : y body position

sword_up_dir	EQM	5
sword_down_dir	EQM	23

; swordtner palette
; $07, $17, $3d
; $0c, $2d, $31

boss_swordtner_spawn: subroutine
	; claim highest 4 sprite slot for control
	;ldx #boss_scarab_id
        ;stx $03b8
        ; claim 4 more slots for rest of body
        lda #do_nothing_id
        sta $03c0
        sta $03c8
        sta $03d0
        sta $03d8
        ; claim 1 more slot for eyeballs
        sta $0340
        ; cache direction velocities
        ldx #$04
        lda arctang_velocities_lo,x
        sta state_v0 ; up velocity
        sta arctang_velocity_lo ; current velocity
        ldx #$00
        lda arctang_velocities_lo,x
        sta state_v1 ; down velocity
        ; setup initial state
        ldx enemy_ram_offset
        lda #sword_up_dir
        sta enemy_ram_ex,x
	rts
        
        ; SWORDTNER
        ; PROVERB
        ; HERE
        
        
swordtner_metasprite_offset:
	byte	#$10, #$20, #$30, #$40
swordtner_metasprite_id:
	byte 	#$82, #$a2, #$a2, #$c2
        
boss_swordtner_cycle: subroutine
        lda #$10
        sta collision_0_w
        sta collision_0_h
        
        inc boss_dmg_handle_true
        ;jsr enemy_handle_damage_and_death
        dec boss_dmg_handle_true

; MOVEMENT
	lda state_v2
        ldx enemy_ram_offset
        jsr enemy_update_arctang_path
        lda oam_ram_x,y
        sta state_v4
        jsr sprite_4_set_x
        lda oam_ram_y,y
        sta state_v5
        jsr sprite_4_set_y
        
        lda state_v5
        cmp #$10
        bcs .check_down_dir
        lda #sword_down_dir
        sta enemy_ram_ex,x
        lda state_v1
        sta arctang_velocity_lo
        bne .done_change_dir
.check_down_dir
        cmp #$80
        bcc .done_change_dir
        lda #sword_up_dir
        sta enemy_ram_ex,x
        lda state_v0
        sta arctang_velocity_lo
.done_change_dir


; SWORDTNER
; MAIN BODY

	; sprite
        lda #$62
        jsr sprite_4_set_sprite
        
        
	ldx #$03
.next_meta_sprite
	lda swordtner_metasprite_offset,x
        clc
        adc enemy_oam_offset
        tay
        lda state_v4
        jsr sprite_4_set_x
        lda state_v5
        adc swordtner_metasprite_offset,x
        jsr sprite_4_set_y
        lda swordtner_metasprite_id,x
        jsr sprite_4_set_sprite
        dex
        bpl .next_meta_sprite
        
        ldx enemy_ram_offset
        
        
	; palette
	lda #$02
        ldy enemy_oam_offset
        jsr sprite_4_set_palette
        clc
        adc #$01
        ldy #$c0
        jsr sprite_4_set_palette
        ldy #$d0
        jsr sprite_4_set_palette
        ldy #$e0
        jsr sprite_4_set_palette
        ldy #$f0
        jsr sprite_4_set_palette
        
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
