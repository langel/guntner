
STARFIELD_MASK		EQM %00111111 ; star probability
STARFIELD_COL0_START	EQM $00
STARFIELD_COL1_START	EQM $07

starfield_sprite	EQM $6b
star_pattern		EQM $a0

starfield_msg_cache	= $03e0	; 32 bytes for string data

star_cache		= $d0
star_oam_start		EQM $40
star_oam_end		EQM <(star_oam_start+$80)



starfield_twinkle_reset: subroutine
	lda #STARFIELD_COL0_START
        sta starfield_color0
        lda #STARFIELD_COL1_START
        sta starfield_color1
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
        stx starfield_column
        jsr get_next_random
        jsr starfield_cache_next_col
	lda #$20
        sta PPU_ADDR
        lda starfield_column
        sta PPU_ADDR
        ldy #$15
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
        lda starfield_column
        sta PPU_ADDR
; rip from cache to PPU
        ldy #$15
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
	lda #star_pattern
        lda starfield_column
        and #$03
        clc
        adc #star_pattern
        jmp .cache_tile
.empty_tile
	lda #tile_empty
.cache_tile
	sta star_cache,y
        iny
        cpy #$16
        bne .col_assign_tile_loop
        rts


death_scroll_speed: subroutine
        lda scroll_speed_hi
        beq .scroll_slow_done
        lda scroll_speed_lo
        sec
        sbc #13
        sta scroll_speed_lo
        bcs .scroll_slow_done
        dec scroll_speed_hi
        lda scroll_speed_hi
        bne .scroll_slow_done
        lda #0
        sta scroll_speed_lo
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
        lda scroll_x_lo
        sec
        sbc scroll_speed_lo
        sta scroll_x_lo
        lda scroll_x_hi
        sbc scroll_speed_hi
        sta scroll_x_hi
        bcs .samepage
        inc scroll_page
.samepage
 	; find starfield column for updating       
        lsr
        lsr
        lsr
        sta starfield_column
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
	; color 0
        lda starfield_color0
        jsr palette_next_rainbow_color
        sta starfield_color0
        sta pal_bg_0_1
        clc
        adc #$21
        sta pal_bg_0_2
        adc #$0d
        sta pal_bg_0_3
        ; color 1
        lda starfield_color1
        jsr palette_next_rainbow_color
        sta starfield_color1
        sta pal_bg_1_1
        adc #$21
        sta pal_bg_1_2
        adc #$0d
        sta pal_bg_1_3
	rts
        

