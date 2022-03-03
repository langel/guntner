
; can we move in 16 different directions?
; 1
; darts are being fired from sandbox2 spawn currently
; only 8 on screen at a time
; enemy_ram_offset is $a0 .. $d8
; 2
; put enemy direction in enemy_ram_ex
; use enemy_ram_pc and a mask to calculate movement

; 3
; a way to handle velocity
; could call a function multiple times per frame
; have the direction in enemy_ram_ex
; call function that forwards enemy_ram_ex and moves enemy

; 4?
; pack x subpixel bits into top of pc
; pack y subpixel bits into bottom of pc

; straight : 90deg ; 3px in that direction per frame
; diagonal ; 45deg ; 2px in both directions per frame
; inbetween ; 22.5deg ; 
; inbetween ; 11.25deg ;

enemy_forward_ex_trajectory: subroutine
	; x = enemy_ram_offset
	inc enemy_ram_pc,x
        lda enemy_ram_ex,x
        rts


ARCTANG_TRANSLATION_LOOKUP_TABLE:


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
        clc
        adc #$05
        sta enemy_ram_x,x
        lda oam_ram_y,y
        clc
        adc #$02
        sta enemy_ram_y,x
        ; 1
        ; use x to find direction
        txa
        sec
        sbc #$a0
        lsr
        lsr
        lsr
        sta enemy_ram_ex,x
        ; reset pattern counter
        lda #0
        sta enemy_ram_pc,x
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
