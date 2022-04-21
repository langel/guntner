
; skeet is a buggar that moves in curves
;
; ac used for both tiles and cycle counter
; pc 2bits x velocity / 2bits y velocity
; ex holds 4-way direction

skeet_spawn: subroutine
	; x is set by enemy spawner
	lda #$0a
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        lda #$00
        sta enemy_ram_x,x ; x pos
        sta enemy_ram_pc,x ; pattern counter
        sta enemy_ram_ac,x ; animation counter
        jsr get_next_random
        lsr
        and #%00000011
        cmp #$00
        beq .spawn_left
        cmp #$01
        beq .spawn_top
        cmp #$02
        beq .spawn_right
.spawn_bottom
	lda rng0
        sta enemy_ram_x,x
        lda #$b0
        sta enemy_ram_y,x
        lda #$00
        jmp .dir_picked
.spawn_left
        lda #$00
        sta enemy_ram_x,x
	lda rng0
        sta enemy_ram_y,x
        lda #$01
        jmp .dir_picked
.spawn_top
	lda rng0
        sta enemy_ram_x,x
        lda #$00
        sta enemy_ram_y,x
        lda #$02
        jmp .dir_picked
.spawn_right
        lda #$f0
        sta enemy_ram_x,x
	lda rng0
        sta enemy_ram_y,x
        lda #$03
.dir_picked
        sta enemy_ram_ex,x
	rts
        
        
skeet_cycle: subroutine
        lda #$08
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
	; animation
        lda enemy_ram_ac,x
        clc
        adc #$02
        sta enemy_ram_ac,x
        cmp #$40
        bne .dont_reset_ac
        ; reset ac and pick new direction
        lda #$00
        sta enemy_ram_ac,x
        jsr get_next_random
        and #%00000001
        cmp #$00
        bne .dir_sub
.dir_add
        inc enemy_ram_ex,x
        lda enemy_ram_ex,x
        cmp #$05
        bne .ac_reset_done
        lda #$00
        sta enemy_ram_ex,x
        jmp .ac_reset_done
.dir_sub
        dec enemy_ram_ex,x
        lda enemy_ram_ex,x
        cmp #$ff
        bne .ac_reset_done
        lda #$00
        sta enemy_ram_ex,x
.ac_reset_done
.dont_reset_ac
        lda enemy_ram_ac,x
        lsr
        tax
        lda sine_table,x
        and #%0000001
        clc
        adc #$4e ; base sprite tile
	ldx enemy_ram_offset
        ldy enemy_oam_offset
        sta oam_ram_spr,y
        ; load up the sine off
        lda enemy_ram_ac,x
        tay
        ; work out the direction
        lda enemy_ram_ex,x
        cmp #$00
        beq .go_right_up
        cmp #$01
        beq .go_right_down
        cmp #$02
        beq .go_left_down
.go_left_up
	lda enemy_ram_x,x
        sec
        sbc $0700,y
	sta enemy_ram_x,x
	lda enemy_ram_y,x
        sec
        sbc $0740,y
	sta enemy_ram_y,x
        lda #$d2
        ldy enemy_oam_offset
        jsr enemy_set_palette
        bcc .go_done
.go_right_up
	lda enemy_ram_x,x
        clc
        adc $0700,y
	sta enemy_ram_x,x
	lda enemy_ram_y,x
        sec
        sbc $0740,y
	sta enemy_ram_y,x
        lda #$d2
        lda #$a2
        ldy enemy_oam_offset
        jsr enemy_set_palette
        bcc .go_done
.go_right_down
	lda enemy_ram_x,x
        clc
        adc $0700,y
	sta enemy_ram_x,x
        inc enemy_ram_y,x
        ldy enemy_oam_offset
        lda #$22
        jsr enemy_set_palette
        bcc .go_done
.go_left_down
	lda enemy_ram_x,x
        sec
        sbc $0700,y
	sta enemy_ram_x,x
        inc enemy_ram_y,x
        ldy enemy_oam_offset
        lda #$62
        jsr enemy_set_palette
.go_done
        lda enemy_ram_x,x
        sta oam_ram_x,y
        lda enemy_ram_y,x
        jsr enemy_fix_y_visible
        sta enemy_ram_y,x
        sta oam_ram_y,y       
.done
	jmp update_enemies_handler_next
        
        
        