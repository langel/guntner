
;;;;; SUBROUTINES

ClearRAM: subroutine
	lda #0		; A = 0
        tax		; X = 0
.clearRAM
	sta $0,x	; clear $0-$ff
        cpx #$fe	; last 2 bytes of stack?
        bcs .skipStack	; don't clear it
	sta $100,x	; clear $100-$1fd
.skipStack
	sta $200,x	; clear $200-$2ff
	sta $300,x	; clear $300-$3ff
	sta $400,x	; clear $400-$4ff
	sta $500,x	; clear $500-$5ff
	sta $600,x	; clear $600-$6ff
	sta $700,x	; clear $700-$7ff
        inx		; X = X + 1
        bne .clearRAM	; loop 256 times
        rts


do_nothing: subroutine
	rts

; disable PPU drawing and NMI
render_enable:
        lda #MASK_BG|MASK_SPR
        sta PPU_MASK	
        lda #CTRL_NMI|CTRL_BG_1000
        sta PPU_CTRL	
	rts
        
render_disable:
	lda #$00
        sta PPU_MASK	
        sta PPU_CTRL	
	rts

; wait for VSYNC to start
WaitSync:
	bit PPU_STATUS
	bpl WaitSync
        rts
        

;;;;; RANDOM NUMBERS

get_next_random: subroutine
	lda rng0
        jsr NextRandom
        sta rng0
        rts

NextRandom subroutine
	lsr
        bcc .NoEor
        eor #$d4
.NoEor:
	rts
; Get previous random value
PrevRandom subroutine
	asl
        bcc .NoEor
        eor #$a9
.NoEor:
        rts


tile_empty 		EQM $03

nametables_clear:
	; tiles
	ldx #$07
        ldy #$00
        PPU_SETADDR $2000
        lda #tile_empty
.page_loop
.byte_loop
        sta PPU_DATA
	iny
        bne .byte_loop
        dex
        bpl .page_loop
        ; attributes
        ldy #0
        PPU_SETADDR $23c0
        ldx #$c0
.nm1_attr_loop
	sty PPU_DATA
        inx
        bne .nm1_attr_loop
        PPU_SETADDR $27c0
        ldx #$c0
.nm2_attr_loop
	sty PPU_DATA
        inx
        bne .nm2_attr_loop
        rts
        
        
sprite_clear:
        lda #$ff
        ldx #$00
.clear_sprite_ram
	sta oam_ram_y,x	; PPU OAM sprite data
        inx
        bne .clear_sprite_ram
	rts
 
ppu_mess_emph: subroutine
        lda rng2
        and #%11100000
        sta ppu_mask_emph
        rts
        
; HEX views
get_char_hi: subroutine
	; a = value in / hex char out
        lsr
        lsr
        lsr
        lsr
        clc
        adc #char_set_offset
        rts
get_char_lo: subroutine
	; a = value in / hex char out
        and #$0f
        clc
        adc #char_set_offset
        rts
        
        
;;;;; namtetable_tile_planter
;;;;; data set address <address> - set 16-bit PPU address

	MAC NMTP_SETADDR
        lda #>{1}	; upper byte
        sta nametable_tile_planter_addr_hi
        lda #<{1}	; lower byte
        sta nametable_tile_planter_addr_lo
        ENDM
        
nametable_tile_planter:
	ldy #$00
        lda (nametable_tile_planter_addr_lo),y	; upper byte
.tileset_loop
        sta PPU_ADDR
        iny
        lda (nametable_tile_planter_addr_lo),y	; lower byte
        sta PPU_ADDR
        iny
.string_loop
        lda (nametable_tile_planter_addr_lo),y	; read string
        iny
        cmp #$00
        beq .terminate_string
        sta PPU_DATA
        bne .string_loop
.terminate_string
	lda (nametable_tile_planter_addr_lo),y	; look for ff
        cmp #$ff
        bne .tileset_loop
        rts
        
        
        
dashboard_messages:
	;" Y 0 u  D 3 A D "
	hex 03970360037d03038503630382038503
	;" G A M E O V Er "
	hex 03870382038d0386038f039403867a03
	;"gg ConGraTiON gg"
	hex 707003847776877a6a93728f8e037070
	;" please unpause "
	hex 0378746e6a7b6e037d76786a7d7b6e03
	;"GooDlucK Hav3fuN"
	hex 87777785747d6c8b03886a7e636f7d8e

difficulty_messages:
	;" Weiner Burgh "
	hex 03956e72766e7a03837d7a707103
	;" Kids' Gloves "
	hex 038b726d7b9e038774777e6e7b03
	;"Mega Gooderest"
	hex 8d6e706a038777776d6e7a6e7b7c
	;"A-OK #1 Expert"
	hex 82ab8f8b039f61038680786e7a7c


menu_screen_tile_data:
	; "Please  START"
	hex 21ea
	hex 90746e6a7b6e03039293829193
	byte #$00
	; "Much  Options"
	hex 222a
	hex 8d7d6c7103038f787c7277767b
	byte #$00
	; " ax1147 "
	hex 22d5
	hex 036a806161646703
	byte #$00
	; "   Publisher's Line Here  "
	hex 2303
	hex 030303907d6b74727b716e7a9e7b038c72766e03886e7a6e0303
	byte #$00
	; "(C)opyright MMXXII LoBlast"
	hex 2323
	hex 9c849d7778817a7270717c038d8d96968989038c7783746a7b7c
	byte #$00
	; " Options Screen "
	hex 2423
	hex 038f787c7277767b03926c7a6e6e7603
	byte #$00
	; "Menu  Return"
	hex 24ca
	hex 8d6e767d0303916e7c7d7a76
	byte #$00
	; "Song"
	hex 250a
	hex 92777670
	byte #$00
	; "Sound"
	hex 254a
	hex 92777d766d
	byte #$00
	; "Color 1   " + cfcf
	hex 258a
	hex 847774777a0361030303cfcf
	byte #$00
	; "Color 2   " + c0c0
	hex 25ca
	hex 847774777a0362030303c0c0
	byte #$00
	; "Difficulties"
	hex 260a
	hex 85726f6f726c7d747c726e7b
	byte #$00
	byte #$ff


cut_scene_intro_tile_data:
	; "MY DINGLE"
	hex 2171
	hex 8d970385898e878c86
	byte #$00
	; "is very sick and there are"
	hex 21a3
	hex 727b037e6e7a81037b726c73036a766d037c716e7a6e036a7a6e
	byte #$00
	; "life saving drugs very far"
	hex 21e3
	hex 74726f6e037b6a7e727670036d7a7d707b037e6e7a81036f6a7a
	byte #$00
	; "away. Please drive through"
	hex 2223
	hex 6a7f6a81990390746e6a7b6e036d7a727e6e037c717a777d7071
	byte #$00
	; "the 13th dimension quickly"
	hex 2263
	hex 7c716e0361637c71036d72756e767b72777603797d726c737481
	byte #$00
	; "so my dingle is saved!"
	hex 22a3
	hex 7b77037581036d727670746e03727b037b6a7e6e6d9b
	byte #$00
	byte #$ff


cut_scene_ending_bad_tile_data:
	; "Why did you bring me "
	hex 21c2
	hex 957181036d726d0381777d036b7a72767003756e03
	byte #$00
	; "a dead dingle?"
	hex 2210
	hex 6a036d6e6a6d036d727670746e9a
	byte #$00
	; "You took too long!"
	hex 2287
	hex 97777d037c777773037c777703747776709b
	byte #$00
	byte #$ff


cut_scene_ending_ok_tile_data:
	; "The dingle is now in a coma."
	hex 21c2
	hex 93716e036d727670746e03727b0376777f037276036a036c77756a99
	byte #$00
	; "It may recover."
	hex 2229
	hex 897c03756a81037a6e6c777e6e7a99
	byte #$00
	; "You could have been faster."
	hex 2283
	hex 97777d036c777d746d03716a7e6e036b6e6e76036f6a7b7c6e7a99
	byte #$00
	byte #$ff


cut_scene_ending_good_tile_data:
	; "What a happy,healthy DINGLE!"
	hex 21c2
	hex 95716a7c036a03716a78788198716e6a747c71810385898e878c869b
	byte #$00
	; "J O O D    J O R B!!"
	hex 2226
	hex 8a038f038f0385030303038a038f039103839b9b
	byte #$00
	; "You seem to be so expedient!"
	hex 2282
	hex 97777d037b6e6e75037c77036b6e037b77036e80786e6d726e767c9b
	byte #$00
	byte #$ff


cut_scene_ending_time_tile_data:
	; "Your Time was "
	hex 2305
	hex 97777d7a039372756e037f6a7b03
	byte #$00
	byte #$ff

char_set_offset		EQM $60
char_set_0		EQM $60
char_set_1		EQM $61
char_set_2		EQM $62
char_set_3		EQM $63
char_set_4		EQM $64
char_set_5		EQM $65
char_set_6		EQM $66
char_set_7		EQM $67
char_set_8		EQM $68
char_set_9		EQM $69
char_set_a		EQM $6a
char_set_b		EQM $6b
char_set_c		EQM $6c
char_set_d		EQM $6d
char_set_e		EQM $6e
char_set_f		EQM $6f
char_set_g		EQM $70
char_set_h		EQM $71
char_set_i		EQM $72
char_set_k		EQM $73
char_set_l		EQM $74
char_set_m		EQM $75
char_set_n		EQM $76
char_set_o		EQM $77
char_set_p		EQM $78
char_set_q		EQM $79
char_set_r		EQM $7a
char_set_s		EQM $7b
char_set_t		EQM $7c
char_set_u		EQM $7d
char_set_v		EQM $7e
char_set_w		EQM $7f
char_set_x		EQM $80
char_set_y		EQM $81
char_set_A		EQM $82
char_set_B		EQM $83
char_set_C		EQM $84
char_set_D		EQM $85
char_set_E		EQM $86
char_set_G		EQM $87
char_set_H		EQM $88
char_set_I		EQM $89
char_set_J		EQM $8a
char_set_K		EQM $8b
char_set_L		EQM $8c
char_set_M		EQM $8d
char_set_N		EQM $8e
char_set_O		EQM $8f
char_set_P		EQM $90
char_set_R		EQM $91
char_set_S		EQM $92
char_set_T		EQM $93
char_set_V		EQM $94
char_set_W		EQM $95
char_set_X		EQM $96
char_set_Y		EQM $97
char_set_comma		EQM $98
char_set_period		EQM $99
char_set_question		EQM $9a
char_set_bang		EQM $9b
char_set_paren_open		EQM $9c
char_set_paren_close		EQM $9d
char_set_apostrophe		EQM $9e
char_set_hash		EQM $9f
char_set_dash		EQM $ab
char_set_colon		EQM $ac
char_set_space		EQM $3