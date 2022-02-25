

dart_spawn: subroutine
	lda #$10
        sta enemy_ram_type,x
        tay
        lda ENEMY_HITPOINTS_TABLE,y
        sta enemy_ram_hp,x 
	; y = parent enemy_ram_offset
        ; only works if called by a parent cycle routine
        ldy enemy_oam_offset
        lda oam_ram_x,y
        sta enemy_ram_x,x
        lda oam_ram_y,y
        sta enemy_ram_y,x
	rts
        
        
dart_cycle: subroutine
        lda enemy_ram_x,x
        clc
        adc #$03
        bcc .dont_despawn
        lda #$00
        sta enemy_ram_type,x
        jmp .done
.dont_despawn
        sta enemy_ram_x,x
        sta oam_ram_x,y
        lda enemy_ram_y,x
        sta oam_ram_y,y
	lda #$6a
        sta oam_ram_spr,y
        lda #0
        jsr enemy_set_palette
.done	
	jmp update_enemies_handler_next
