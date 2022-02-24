
; flight path built on sine table circles

; quadrants clockwise : x val , y val
; 0 or 12-3 : $00-$40 , $c0-$00
; 1 or 3-6  : $40-$80 , $00-$40
; 2 or 6-9  : $80-$c0 , $40-$80
; 3 or 9-12 : $c0-$00 , $80-$c0

; state sequence -- comes in from top
; x,y origin ; quandrant(s) ; diameter x,y ; x,y origin diff
;  88,-48    ;       1      ; 96, 96       ;
; 124, 32    ;     2-3      ; 24, 16       ; +38, +80
; 120, 32    ;     0-1      ; 32, 32       ;  -4, 0
; 104, 16    ;     2-3      ; 64, 48       ; -16, -16
; 104, 16    ;     0-1      ; 64, 60
;  88, 76    ; 3 in reverse ; 96, 52



galger_spawn: subroutine
	; x is set by enemy spawner
	lda #$0f
        sta enemy_ram_type,x 
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
        
        lda #$00
        sta enemy_ram_x,x
        sta enemy_ram_y,x
        rts
        
        lda #$00
        sta enemy_ram_ex,x
        lda #88
        sta enemy_ram_x,x
        lda #208
        sta enemy_ram_y,x
        
        ; XXX animation and pattern counters?
        lda #$00
        sta enemy_ram_ac,x ; animation counter
        lda #$40
        sta enemy_ram_pc,x ; pattern counter

	rts
        


galger_cycle: subroutine
        inc enemy_ram_pc,x
        
        ; set x position
        lda enemy_ram_pc,x
        tax
        lda #$5f
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_x,x
        sta oam_ram_x,y
        
        ; set y position
        lda enemy_ram_pc,x
        clc
        adc #$c0
        tax
        lda #96
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_y,x
        sta oam_ram_y,y
        ; current sprite
        lda #$69
        sta oam_ram_spr,y
        ; do palette
        lda #$03
        jsr enemy_set_palette
	jmp update_enemies_handler_next
        

        lda #$08
        sta collision_0_w
        lda #$08
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
        sta enemy_ram_type,x
        jmp .done
.not_dead
        ; update pattern
        inc enemy_ram_pc,x
        inc enemy_ram_pc,x
        
        lda enemy_ram_ex,x
        cmp #$00
        bne .not_state1
        jmp .state1
.not_state1
        cmp #$01
        bne .not_state2
        jmp .state2
.not_state2
        cmp #$02
        bne .not_state3
        jmp .state3
.not_state3
        cmp #$03
        bne .not_state4
        jmp .state4
.not_state4
        jmp .done
        
.state1
        ; set x position
        lda enemy_ram_pc,x
        tax
        lda #48
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_x,x
        sta oam_ram_x,y
        
        ; set y position
        lda enemy_ram_pc,x
        clc
        adc #$c0
        tax
        lda #48
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_y,x
        sta oam_ram_y,y
        
        ; end of state?
        lda enemy_ram_pc,x
        cmp #$80
        bne .state1_done
  	; setup state 2
        inc enemy_ram_ex,x
        lda enemy_ram_x,x
        clc
        adc #38
        sta enemy_ram_x,x
        lda enemy_ram_y,x
        clc
        adc #80
        sta enemy_ram_y,x
.state1_done   
        jmp .done
        

.state2
        ; set x position
        lda enemy_ram_pc,x
        tax
        lda #12
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_x,x
        sta oam_ram_x,y
        
        ; set y position
        lda enemy_ram_pc,x
        clc
        adc #$c0
        tax
        lda #8
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_y,x
        sta oam_ram_y,y
        
        ; end of state?
        lda enemy_ram_pc,x
        cmp #$00
        bne .state2_done
        ; setup state 3
        inc enemy_ram_ex,x
        lda enemy_ram_x,x
        sec
        sbc #$04
        sta enemy_ram_x,x
.state2_done      
        jmp .done
        
        
.state3
        ; set x position
        lda enemy_ram_pc,x
        tax
        lda #16
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_x,x
        sta oam_ram_x,y
        
        ; set y position
        lda enemy_ram_pc,x
        clc
        adc #$c0
        tax
        lda #16
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_y,x
        sta oam_ram_y,y
        
        ; end of state?
        lda enemy_ram_pc,x
        cmp #$80
        bne .state3_done
        ; setup state 4
        inc enemy_ram_ex,x
        lda enemy_ram_x,x
        sec
        sbc #16
        sta enemy_ram_x,x
        lda enemy_ram_y,x
        sec
        sbc #16
        sta enemy_ram_y,x
.state3_done
        jmp .done
        
        
.state4
        ; set x position
        lda enemy_ram_pc,x
        tax
        lda #32
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_x,x
        sta oam_ram_x,y
        
        ; set y position
        lda enemy_ram_pc,x
        clc
        adc #$c0
        tax
        lda #24
        jsr sine_of_scale
        ldx enemy_ram_offset
        clc
        adc enemy_ram_y,x
        sta oam_ram_y,y
        
        ; end of state?
        lda enemy_ram_pc,x
        cmp #$80
        jmp .state4_done
        ; setup state 5
        inc enemy_ram_ex,x
        lda enemy_ram_x,x
        sec
        sbc #$04
        sta enemy_ram_x,x
.state4_done
        jmp .done
        
        
.done
        ; current sprite
        lda #$69
        sta oam_ram_spr,y
        ; do palette
        lda #$03
        jsr enemy_set_palette
	
	jmp update_enemies_handler_next