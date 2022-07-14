; phase type constants
phase_zero_id		EQM	#$00	; "good luck" / "congration"
phase_galger_id		EQM	#$01
phase_spawns_id		EQM	#$02
phase_longspawn_id	EQM	#$03
phase_bossfight_id	EQM	#$04

phase_type_table:
	byte #phase_zero_id		; 0
        byte #phase_galger_id		; 1
        byte #phase_spawns_id		; 2
        byte #phase_galger_id		; 3
        byte #phase_spawns_id		; 4
        byte #phase_galger_id		; 5
        byte #phase_longspawn_id	; 6
        byte #phase_galger_id		; 7
        byte #phase_spawns_id		; 8
        byte #phase_galger_id		; 9
        byte #phase_galger_id		; a
        byte #phase_spawns_id		; b
        byte #phase_galger_id		; c
        byte #phase_longspawn_id	; d
        byte #phase_galger_id		; e
        byte #phase_bossfight_id	; f
        
   
phase_handlers_lo:
	byte #<phase_zero
        byte #<phase_galger
        byte #<phase_spawns
        byte #<phase_spawn_long
        byte #<phase_boss_fight
phase_handlers_hi:
	byte #>phase_zero
        byte #>phase_galger
        byte #>phase_spawns
        byte #>phase_spawn_long
        byte #>phase_boss_fight



; OLD DEMO PHASES
; 1: 1 birb
; 2: 2 maggs
; 3: 2 starglasses
; 4: 1 skully
; 5: 2 starglasses, 2 maggs, 4 birbs
; 6: 8 birbs, 4 maggs
; 7: 12 birbs, 3 skullys
; 8: 12 birbs, 1 skully, 2 maggs
; 9: 16 birbs, 6 skullys, 4 maggs, 2 starglasses



level_enemy_table:
	; level 1
        byte starglasses_id, starglasses_id, dumbface_id
        byte 0
        ; level 2
        byte 0
        ; level 3
        byte 0
        ; level 4
        byte 0

level_boss_table:
	byte boss_scarab_id
	byte boss_vamp_id
	byte boss_scarab_id
	byte boss_vamp_id

        
phase_enemy_table:
	; === LEVEL 00 =========
	; phase 02
	byte birb_id, 4
        byte 0
        ; phase 04
        byte maggs_id, 2
        byte 0
        ; phase 08
        byte birb_id, 3
        byte maggs_id, 3
        byte birb_id, 6
        byte 0
        ; phase 0b
        byte maggs_id, 3
        byte birb_id, 8
        byte maggs_id, 4
        byte birb_id, 12
        byte skully_id, 1
        byte 0
	; === LEVEL 01 =========
        ; phase 12
        byte 0
        ; phase 14
        byte 0
        ; phase 18
        byte 0
        ; phase 1b
        byte 0
	; === LEVEL 02 =========
        ; phase 22
        byte 0
        ; phase 24
        byte 0
        ; phase 28
        byte 0
        ; phase 2b
        byte 0
	; === LEVEL 03 =========
        ; phase 32
        byte 0
        ; phase 34
        byte 0
        ; phase 38
        byte 0
        ; phase 3b
        byte 0
        

        
        