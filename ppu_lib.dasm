
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


nametables_clear:
	ldx #$00
        ldy #$00
        PPU_SETADDR $2000
        lda #$ff ; empty tile
.page_loop
.byte_loop
        sta PPU_DATA
	iny
        bne .byte_loop
        inx
        cpx #$08
        bne .page_loop
        rts
        
        
sprite_clear:
        lda #$ff
        ldx #$00
.clear_sprite_ram
	sta oam_ram_y,x	; PPU OAM sprite data
        inx
        bne .clear_sprite_ram
	rts
        
        
; HEX views
get_char_hi: subroutine
	; a = value in / hex char out
        lsr
        lsr
        lsr
        lsr
        clc
        ; XXX this should be a defined constant
        adc #char_set_offset
        rts
get_char_lo: subroutine
	; a = value in / hex char out
        and #$0f
        clc
        ; XXX this should be a defined constant
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
        
char_set_offset		EQM $30
char_set_0		EQM $30
char_set_1		EQM $31
char_set_2		EQM $32
char_set_3		EQM $33
char_set_4		EQM $34
char_set_5		EQM $35
char_set_6		EQM $36
char_set_7		EQM $37
char_set_8		EQM $38
char_set_9		EQM $39
char_set_a		EQM $3a
char_set_b		EQM $3b
char_set_c		EQM $3c
char_set_d		EQM $3d
char_set_e		EQM $3e
char_set_f		EQM $3f
char_set_g		EQM $40
char_set_h		EQM $41
char_set_i		EQM $42
char_set_j		EQM $43
char_set_k		EQM $44
char_set_l		EQM $45
char_set_m		EQM $46
char_set_n		EQM $47
char_set_o		EQM $48
char_set_p		EQM $49
char_set_q		EQM $4a
char_set_r		EQM $4b
char_set_s		EQM $4c
char_set_t		EQM $4d
char_set_u		EQM $4e
char_set_v		EQM $4f
char_set_w		EQM $50
char_set_x		EQM $51
char_set_y		EQM $52
char_set_z		EQM $53
char_set_A		EQM $54
char_set_B		EQM $55
char_set_C		EQM $56
char_set_D		EQM $57
char_set_E		EQM $58
char_set_F		EQM $59
char_set_G		EQM $5a
char_set_H		EQM $5b
char_set_I		EQM $5c
char_set_J		EQM $5d
char_set_K		EQM $5e
char_set_L		EQM $5f
char_set_M		EQM $60
char_set_N		EQM $61
char_set_O		EQM $62
char_set_P		EQM $63
char_set_Q		EQM $64
char_set_R		EQM $65
char_set_S		EQM $66
char_set_T		EQM $67
char_set_U		EQM $68
char_set_V		EQM $69
char_set_W		EQM $6a
char_set_X		EQM $6b
char_set_Y		EQM $6c
char_set_Z		EQM $6d
char_set_space		EQM $6e
char_set_comma		EQM $6f
char_set_period		EQM $70
char_set_question		EQM $71
char_set_bang		EQM $72
char_set_paren_open		EQM $73
char_set_paren_close		EQM $74
char_set_colon		EQM $75
char_set_semicolon		EQM $76