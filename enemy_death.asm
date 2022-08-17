
        
        
crossbones_cycle: subroutine
        inc enemy_ram_ac,x
        lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        sta enemy_ram_y,x
        lda oam_ram_y,y
        sec
        sbc enemy_ram_y,x
        cmp #sprite_0_y
        bcs .crossbones_death
        sta oam_ram_y,y
        lda #$c1
        sta oam_ram_spr,y
        lda #$03
        sta oam_ram_att,y
        bne .crossbones_done
.crossbones_death
	lda sfx_noi_counter
        bne .die_already
        jsr sfx_ghost_snare
.die_already
        jsr enemy_clear
.crossbones_done
	jmp update_enemies_handler_next
        
        
        
        
        
        
        
clear_all_enemies: subroutine
	; clears all enemy ram
	ldx #$f0
        lda #$00
.enemy_loop
	dex
	sta enemy_ram_type,x
        bne .enemy_loop
        ; clears all enemy sprites
        lda #$ff
	ldx #$20
.sprite_loop
	sta $0200,x
        inx
        bne .sprite_loop
        rts
        
        
        
enemy_clear: subroutine
        ; clear OAM data
        ldy enemy_oam_offset
        lda #$ff
        ldx #$03
.enemy_oam_loop
	sta oam_ram_y,y
        iny
        dex
        bne .enemy_oam_loop
        ; clear enemy data
	ldx enemy_ram_offset
        lda #$00
	ldy #$06 ; 7 would clear _ex
.enemy_ram_loop
        sta enemy_ram_type,x
        inx
        dey
        bne .enemy_ram_loop
        ; enemy_ram_ex is allowed to carry over
        ; entities using _ex should set it on spawn
        rts
        
        
        
enemy_death_handler: subroutine
        ; requires 
        ;	enemy_ram_offset
        ;	enemy_oam_offset 
        
	; don't handle a non entity
        ldx enemy_ram_offset
	lda enemy_ram_type,x
        beq .done
        
	; handle point bonus
        asl
        asl
        clc
        adc #$03
        tay ; enemy points counter
        ldx #$03 ; score bytes counter
        clc
.score_loop
        lda enemy_player_points_table,y
        adc score_000000xx,x
        sta score_000000xx,x
        dey
	dex
	bpl .score_loop
        
	; track deaths of phase spawns
        ldy enemy_slot_id
        lda phase_spawn_table,y
        beq .not_phase_spawn
        lda #$00
        sta phase_spawn_table,y
	dec phase_kill_counter
.not_phase_spawn
        
        ldx enemy_ram_offset
        ldy enemy_oam_offset
; 4 sprite cleanup
	cpx #$a0
        bcc .dont_cleanup_4_sprite
	lda #$04 ; move first sprite over 4 pixels
        clc
	adc oam_ram_x,y
        sta oam_ram_x,y
	lda #$04 ; move first sprite down 4 pixels
        clc
        adc oam_ram_y,y
        sta oam_ram_y,y
        ; move other sprites off screen
	lda #$ff
        sta oam_ram_y+4,y
        sta oam_ram_y+8,y
        sta oam_ram_y+12,y
        bne .check_for_powerup_drop
.dont_cleanup_4_sprite

; 2 sprite cleanup
	cpx #$80
        bcc .dont_cleanup_2_sprite
	lda #$ff
        sta oam_ram_y+4,y
.dont_cleanup_2_sprite

.check_for_powerup_drop
; starglasses 
        lda enemy_ram_type,x
        cmp #starglasses_id
        bne .not_starglasses
        ; spawn powerup
        jmp powerup_from_starglasses
.not_starglasses

        jsr sfx_enemy_death
        ; change it into crossbones!
        lda #crossbones_id
        sta enemy_ram_type,x
        sta enemy_ram_ac,x
.done
        rts
