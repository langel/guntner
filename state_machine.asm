
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


STATE_RENDER_FUNCTION_TABLE:
	.word	state_render_do_nothing		; 0
        .word	menu_screens_render		; 1
        .word	starfield_render		; 2

STATE_UPDATE_FUNCTION_TABLE:
	.word	state_update_do_nothing		; 0
        .word	title_screen_update		; 1
        .word	scrollto_options_update		; 2
        .word	options_screen_update		; 3
        .word	scrollto_titles_update		; 4



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
