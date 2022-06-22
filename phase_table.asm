
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


	; phase 0 	: introduce level
        ; even phases	: galger spawns
        ; phases 7+d	: spawn until kill count done
        ; phase e	: boss fight
        ; phase f	: level outro
        
phase_enemy_table:
	; phase 1
	byte birb_id, 4
        byte 0
        ; phase 2
        byte galger_id, 12
        byte 0
        ; phase 3
        byte maggs_id, 2
        byte 0
        ; phase 4
        byte galger_id, 12
        byte 0
        ; phase 5
        byte birb_id, 4
        byte maggs_id, 4
        byte birb_id, 4
        byte 0
        ; phase 6
        byte galger_id, 12
        byte 0
        ; phase 7
        byte birb_id, 8
        byte skully_id, 1
        byte birb_id, 8
        byte maggs_id, 4
        byte 0
        ; phase 8
        byte galger_id, 12
        byte skully_id, 2
        byte 0
        ; phase f
        byte boss_scarab_id, 1
        byte 0
        

        
        