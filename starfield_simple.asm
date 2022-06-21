
STARFIELD_MASK		EQM %00111111 ; star probability
STARFIELD_COL0_START	EQM $00
STARFIELD_COL1_START	EQM $07

starfield_tile		EQM $0f
starempty_tile		EQM $20
starfield_sprite	EQM $6b

starfield_msg_cache	= $03e0	; 32 bytes for string data

star_cache		= $d0
star_oam_start		EQM $40
star_oam_end		EQM <(star_oam_start+$80)



starfield_twinkle_reset: subroutine
	lda #STARFIELD_COL0_START
        sta starfield_col0
        lda #STARFIELD_COL1_START
        sta starfield_col1
	rts
        
        
   
starfield_init: subroutine
; set starfield state
	lda #$00
        sta starfield_state
; set bg tile palette attributes / colors
; $23c0 and $27c0
        ; page 1 attributes
	PPU_SETADDR $23c0
	lda #%00010100
        ldx #$d8
.23c0_loop
        sta PPU_DATA
        inx
        bne .23c0_loop
        ; COLOR SPLIT
        ; set split color attr for top row
	PPU_SETADDR $23e8
	lda #%11110001
        ldx #$f8
.27e8_loop
        sta PPU_DATA
        inx
        bne .27e8_loop
        ; page 2 attributes
	PPU_SETADDR $27c0
	lda #%00010100
        ldx #$d8
.27c0_loop
        sta PPU_DATA
        inx
        bne .27c0_loop
        ; make sure sprite0 has something to collide with
        jsr starfield_draw_dash_top_bar_nametable0
; draw stars on nametable 1
        lda #CTRL_INC_32
        sta PPU_CTRL
        ;stx starfield_page
	ldx #$00
.draw_stars_loop
        stx starfield_col
        jsr get_next_random
        jsr starfield_cache_next_col
	lda #$20
        sta PPU_ADDR
        lda starfield_col
        sta PPU_ADDR
        ldy #$16
.transfer_loop
	lda star_cache,y
        sta PPU_DATA
        dey
        bne .transfer_loop
        inx
        cpx #$20
        bne .draw_stars_loop
        lda #0
        sta PPU_CTRL
	rts
        

        
starfield_render: subroutine
	; copy tiles to PPU VRAM during vblank
;update_starfield_column
        lda #CTRL_INC_32
        sta PPU_CTRL
        ; set base PPU address
	lda starfield_page
        sta PPU_ADDR
        lda starfield_col
        sta PPU_ADDR
; rip from cache to PPU
        ldy #$16
.col_loop
	lda star_cache,y
        sta PPU_DATA
        dey
        bne .col_loop
        ; put that shit back to sequential order
        lda #0
        sta PPU_CTRL
        jsr dashboard_render
        jmp state_render_done
        
        
starfield_update: subroutine
; will not work with scroll speeds above 8
	; precalculate all starfield things post sprite 
	jsr starfield_scroll
        ; twinkle them stars with palette stuff
        jsr starfield_twinkle_colors
        jsr starfield_twinkle_bg
	; XXX hook this up with tile changing later
        ; probably hearts after killing a boss
        ; XXX starfield_tile
        ; #$0f star
        ; #$90 heart
starfield_cache_next_col:
        ; setup rng for star probability
        lda rng0
        lsr
        and #STARFIELD_MASK
        sta temp00
      	ldy #$00
.col_assign_tile_loop
	cpy temp00
        bne .empty_tile
.star_tile
	lda #starfield_tile
        jmp .cache_tile
.empty_tile
	lda #starempty_tile 
.cache_tile
	sta star_cache,y
        iny
        cpy #$16
        bne .col_assign_tile_loop
        rts


death_scroll_speed: subroutine
        lda scroll_speed
        beq .scroll_slow_done
        lda wtf
        and #$07
        bne .scroll_slow_done
        ; slow down stars
	dec scroll_speed
.scroll_slow_done
	rts
        
        
starfield_draw_dash_top_bar_nametable0: subroutine
        ; fill page 1 bar for sprite 0 collisions
	PPU_SETADDR dash_page1_top_bar
        lda #dash_top_bar_tile
        ldy #$20
.tile_dash_set_page1
        sta PPU_DATA
        dey
        bpl .tile_dash_set_page1
        rts
           
        
        
starfield_scroll: subroutine        
	; update scroll pos
	lda scroll_x
        sec
        sbc scroll_speed
        bcs .samepage
        inc scroll_page
.samepage
	sta scroll_x
 	; find starfield column for updating       
        lsr
        lsr
        lsr
        sta starfield_col
        ; set nametable for column updating
        lda scroll_page
        and #$01
        bne .scroll_page
        lda #$20
        sta starfield_page
   	jmp .scroll_page_done
.scroll_page
	lda #$24
        sta starfield_page
.scroll_page_done
        rts
        


starfield_twinkle_colors: subroutine
        lda starfield_col0
        jsr palette_next_rainbow_color
        sta starfield_col0
        lda starfield_col1
        jsr palette_next_rainbow_color
        sta starfield_col1
	rts
        
        
starfield_twinkle_bg: subroutine
	lda starfield_col0
        sta pal_bg_0_1
        clc
        adc #$21
        sta pal_bg_0_2
        adc #$0d
        sta pal_bg_0_3
        lda starfield_col1
        sta pal_bg_1_1
        clc
        adc #$21
        sta pal_bg_1_2
        adc #$0d
        sta pal_bg_1_3
	rts