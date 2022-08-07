
; skeet is a buggar that moves in curves
;
; ac used for both tiles and cycle counter
; pc 2bits x velocity / 2bits y velocity
; ex holds 4-way direction

skeet_att_table:
	;     r/u   l/u   l/d   r/d
        byte #$a2, #$d2, #$62, #$22 
skeet_vel_table:
	byte #0, #5, #6, #1, #6, #5

skeet_spawn: subroutine
	; set direction
        lda rng1
        and #$02
        bne .downward
.upward
	lda #$06
        bne .set_updown
.downward
	lda #18
.set_updown
        sta enemy_ram_ex,x
        ; set position
        jmp enemy_spawn_set_x_y_rng
        
        
skeet_cycle: subroutine
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
        ; reset direction?
        lda enemy_ram_ac,x
        bne .skip_reset
        lda #$40
        sta enemy_ram_ac,x
        jsr get_next_random
        bpl .dir_inc
.dir_dec
 	lda #$ff
        sta enemy_ram_pc,x
        bne .skip_reset
.dir_inc
 	lda #$01
        sta enemy_ram_pc,x
.skip_reset
	dec enemy_ram_ac,x
        lda enemy_ram_ac,x
        and #$03
        bne .skip_dir_change
        lda enemy_ram_ex,x
        clc
        adc enemy_ram_pc,x
        jsr arctang_bound_dir
        sta enemy_ram_ex,x
.skip_dir_change
	; velocity
        lda enemy_ram_ex,x
        lsr
        lsr
        tax
        lda skeet_vel_table,x
        tax
        lda arctang_velocities_lo,x
        sta arctang_velocity_lo
        ldx enemy_ram_offset
	jsr arctang_enemy_update
        ; sprite
        lda enemy_ram_ac,x
        lsr
        tax
        lda sine_table,x
        and #1
        clc
        adc #$4e ; base sprite tile
	ldx enemy_ram_offset
        sta oam_ram_spr,y
        ; attr
        lda enemy_ram_ex,x
        adc #$04
        lsr
        lsr
        lsr
        tax
        lda skeet_att_table,x
        ldx enemy_ram_offset
        jsr enemy_set_palette
        
	jmp update_enemies_handler_next
        
        