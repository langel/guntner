
; === STATE MACHINE ===



; nmi order of operations :

; jmp() to state renderer 
; 	most likely starfield mode
;	jmp to dashboard
;	jmp back
; OAM DMA
; palette transfer
; set scroll pos

; jmp() to state logic
; jmp back

; check flag sprite0 and if set :
; 	wait for sprite 0
;	set scroll pos
;	(palette hackery?)

; apu manage
; starfield manage jmp()?
; palette manage



; init functions order of operations :

; 	disable rendering and nmi
;	(halt audio?)
;	update vram
;	wait for vsync/vblank
;	reenable rendering and nmi


state_clear:
	ldx #$07
        lda #$00
.loop
        sta state_v0,x
        dex
        bpl .loop
	rts



state_render_do_nothing:
	jmp state_render_done
        
state_update_do_nothing:
	jmp state_update_done
        


state_sprite0_enable:
        lda #$01
        sta oam_ram_x
        lda #sprite_0_y
	sta oam_ram_y
        lda #$ff
        sta oam_ram_spr
        lda #$20
        sta oam_ram_att
        lda #$ff
        sta state_sprite0
        rts
        
state_sprite0_disable:
	lda #$ff
        sta oam_ram_y
        lda #$00
        sta state_sprite0
        rts