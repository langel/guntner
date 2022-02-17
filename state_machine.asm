
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
	.word	state_render_do_nothing

STATE_UPDATE_FUNCTION_TABLE:
	.word	state_update_do_nothing



state_render_do_nothing:
	jmp state_render_done
        
state_update_do_nothing:
	jmp state_update_done