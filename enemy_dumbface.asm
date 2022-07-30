
                    
dumbface_spawn: subroutine
	; x is set by enemy spawner
        lda rng0
        sta enemy_ram_ac,x ; animation counter
        jsr enemy_spawn_random_y_pos
        sta enemy_ram_y,x ; y pos
   	rts
        
        
dumbface_cycle: subroutine
        lda #$10
        sta collision_0_w
        sta collision_0_h
        jsr enemy_handle_damage_and_death
        
	inc enemy_ram_x,x
        lda enemy_ram_x,x
        jsr sprite_4_set_x
        
        lda enemy_ram_ex,x
        and #$01
        bne .going_down
.going_up
	dec enemy_ram_y,x
        bne .updown_done
        inc enemy_ram_ex,x
        jmp .updown_done
.going_down
	inc enemy_ram_y,x
        lda enemy_ram_y,x
        cmp #$ad
        bne .updown_done
        inc enemy_ram_ex,x
.updown_done
        lda enemy_ram_y,x
        jsr sprite_4_set_y
        
        inc enemy_ram_ac,x
	lda enemy_ram_ac,x
        lsr
        lsr
        lsr
        and #$03
        asl
        
        clc
        adc #$c8
        jsr sprite_4_set_sprite
        lda #$01
        jsr sprite_4_set_palette
.done
	jmp update_enemies_handler_next