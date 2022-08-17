
                    
skully_spawn: subroutine
	; x is set by enemy spawner
        lda rng0
        sta enemy_ram_ac,x ; animation counter
        jsr enemy_spawn_random_y_pos
        sta enemy_ram_y,x ; y pos
   	rts



;;;; HANDLING SKULLY
skully_cycle: subroutine
        lda #$10
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
        ldx enemy_ram_offset
        ldy enemy_oam_offset
        lda #$01 ; set mirror flag
        sta enemy_ram_ex,x
        ; let's find what frame we're on
        lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        lsr
        lsr
        asl
        ; accumulator is now in 0..7 range except x2
        ; sprite
	jsr sprite_4_set_sprite
        ; x pos
        lda enemy_ram_x,x
        jsr sprite_4_set_x
        ; y pos
        lda enemy_ram_y,x
        jsr sprite_4_set_y
	; update spinning counter
	lda #$07
        clc
        adc enemy_ram_ac,x
        sta enemy_ram_ac,x
        ; move skully
        jsr skully_handle_movement
	; palette
        lda #$03
        jsr sprite_4_set_palette
.skully_done
	jmp update_enemies_handler_next
        
        
skully_handle_movement: subroutine
	lda attract_true
        bne .demoshit
        lda #$69
        lda enemy_ram_pc,x
        cmp #$40
        bne .not_chasing
        ; CHASE MODE
        dec enemy_ram_x,x
        lda wtf
        and #$03
        bne .done
        lda enemy_ram_y,x
        clc
        adc #$09
        cmp player_y_hi
        beq .done
        bcc .down
.up
	dec enemy_ram_y,x
        rts
.down
	inc enemy_ram_y,x
        rts
.not_chasing
        ; ZOOM MODE
        lda #$20
        sta enemy_ram_pc,x
        lda #$04
        clc
        adc enemy_ram_x,x
        sta enemy_ram_x,x
        cmp #240
        bcc .demoshit
        lda #$40
        sta enemy_ram_pc,x
	rts
.demoshit
        ; DEMO MODE
        inc enemy_ram_x,x
.done
	rts
   