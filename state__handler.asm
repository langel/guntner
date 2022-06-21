
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




; more problems...

; star update is based on starfield state

STATE_INIT_FUNCTION_TABLE:
	.word	menu_screens_init		; 0
        .word	attract_init			; 1
        .word	game_init			; 2
        .word	cut_scene_00_init		; 3
        
state_init_call:
	; a = function table slot
        asl
        tax
	lda STATE_INIT_FUNCTION_TABLE,x
        ; XXX maybe don't use boss variable space?
        sta temp00
        inx
	lda STATE_INIT_FUNCTION_TABLE,x
        sta temp01
        jmp (temp00)
	

STATE_RENDER_FUNCTION_TABLE:
	.word	state_render_do_nothing		; 0
        .word	menu_screens_render		; 1
        ;.word	starfield_bg_render		; 2
        .word	starfield_render		; 3
        .word 	state_render_do_nothing ; placeholder
        ;.word	starfield_sprmsg_render		; 4
        .word	dashboard_render		; 5

STATE_UPDATE_FUNCTION_TABLE:
	.word	state_update_do_nothing		; 0
        .word	title_screen_update		; 1
        .word	scrollto_options_update		; 2
        .word	options_screen_update		; 3
        .word	scrollto_titles_update		; 4
        .word	attract_update			; 5
        .word	game_update			; 6
        .word	sandbox_update			; 7
        .word	cut_scene_update_generic	; 8
        ;.word	sandbox2_update			; 9
        ;.word	starfield_sprmsg_update		; a



state_render_do_nothing:
	jmp state_render_done
        
state_update_do_nothing:
	jmp state_update_done
        
        

state_render_set_addr:
	; a = function table slot
        asl
        tax
	lda STATE_RENDER_FUNCTION_TABLE,x
        sta state_render_addr_lo
        inx
	lda STATE_RENDER_FUNCTION_TABLE,x
        sta state_render_addr_hi
        rts
        
state_update_set_addr:
	; a = function table slot
        asl
        tax
	lda STATE_UPDATE_FUNCTION_TABLE,x
        sta state_update_addr_lo
        inx
	lda STATE_UPDATE_FUNCTION_TABLE,x
        sta state_update_addr_hi
        rts

state_sprite0_enable:
        lda #$01
        sta oam_ram_x
        lda sprite_0_y
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