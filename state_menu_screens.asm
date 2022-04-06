
menu_screens_init: subroutine

        jsr WaitSync	; wait for VSYNC
        jsr render_disable
	jsr sprite_clear
        jsr state_sprite0_disable
        
	lda #$01
        jsr state_render_set_addr
	lda #$01
        jsr state_update_set_addr
        lda #$00
        sta scroll_x
        sta scroll_page
        jsr timer_reset
        jsr title_screen_set_rudy_y
        
; set bg tile palette attributes / colors
; $23c0 and $27c0
        ; page 1 attributes
	PPU_SETADDR $23c0
	lda #%10101010
        ldx #$c0
.23c0_loop
        sta PPU_DATA
        inx
        bne .23c0_loop
        ; page 2 attributes
	PPU_SETADDR $27c0
	lda #%10101010
        ldx #$c0
.27c0_loop
        sta PPU_DATA
        inx
        bne .27c0_loop
        
	jsr player_game_reset
        jsr dashboard_init
        jsr dashboard_update
        jsr dashboard_render
        
; G u n T n e R

; BIG TITLE
	PPU_SETADDR $2060
        ldy #$00
big_title_loop:
	lda guntner_title_name_table,y
	sta PPU_DATA
        iny
        bne big_title_loop

; hud bar on title screen
	PPU_SETADDR $22c0
        lda #$b9
        ldy #$20
.set_top_bar
	sta PPU_DATA
        dey
        bne .set_top_bar
        
; various stuff on screen        
        NMTP_SETADDR menu_screen_tile_data
        jsr nametable_tile_planter

; set rudy color blocks' tile attributes
	PPU_SETADDR $27dc
        lda #%11111111
        sta PPU_DATA
        
; set rudy stuff
`	jsr menus_position_rudy
        jsr set_player_sprite
        
        jsr palette_fade_in_init
        jsr apu_trigger_title_screen_chord
        
; turn ppu back on
        jsr WaitSync	; wait for VSYNC
	jsr render_enable
	rts



; vBLANK RENDER HANDLER
        
menu_screens_render: 
	; pretty much just for options screen
; show song id
	PPU_SETADDR $2512
	lda #$30
        sta PPU_DATA
	lda options_song_id
	clc
        adc #$30
        sta PPU_DATA
; show sound id
	PPU_SETADDR $2552
	lda #$30
        sta PPU_DATA
	lda options_sound_id
	clc
        adc #$30
        sta PPU_DATA
        jmp state_render_done
        
        
        
        
        
; SCROLL HANDLERS

scrollto_options_update: subroutine
	lda scroll_to_counter
        clc
        adc #$04
        sta scroll_to_counter
        tax
        lda sine_table,x
        sta scroll_x
        cpx #$40
        bne .done
        ; setup options
        lda #3
        jsr state_update_set_addr
        lda #1
        sta scroll_page
        lda #$00
        sta scroll_x
        ;jmp options_screen_init
.done
	jsr menus_position_rudy
	jmp state_update_done
        
        
        
scrollto_titles_update: subroutine
	lda #$00
        sta scroll_page
	lda scroll_to_counter
        sec
        sbc #$04
        sta scroll_to_counter
        tax
        lda sine_table,x
        sta scroll_x
        cpx #$c0
        bne .done
        ; setup options
        lda #1
        jsr state_update_set_addr
        lda #$00
        sta scroll_page
        jsr timer_reset
.done
	jsr menus_position_rudy
	jmp state_update_done



menus_position_rudy: subroutine
	lda scroll_x
        cmp #$00
        bne .do_eeet
        rts
.do_eeet
        cmp #$48
        bcs .coming_from_right
.going_to_the_left
	jsr title_screen_set_rudy_y
	lda #$3a
	sec
        sbc scroll_x
	jmp .plot_tiles
.coming_from_right
	jsr options_screen_set_rudy_y
	lda #$38
        sec
        sbc scroll_x
.plot_tiles
        sta oam_ram_rudy+3
        clc
        adc #$08
        sta oam_ram_rudy+7
	rts

        
title_screen_set_rudy_y: subroutine
	lda title_rudy_pos
        asl
        asl
        asl
        asl
        clc
        adc #$7f
        sta player_y_hi
        jmp set_player_sprite
        
        
options_screen_set_rudy_y: subroutine
	lda options_rudy_pos
        asl
        asl
        asl
        asl
        clc
        adc #$48
        sta player_y_hi
        jmp set_player_sprite

        
        
        
; STRINGS AND NAMETABLES
                
menu_screen_tile_data:
        .hex 21e8
	.byte "  Please  START "
        .byte #$00
        .hex 2228
        .byte "  Much  Options "
        .byte #$00
        .hex 22d7
	.byte " v2.1e "
        .byte #$00
        .hex 2304
	.byte "(c)MMXXII puke7, LoBlast"
        .byte #$00
	.hex 2448
	.byte "Options Screeen"
        .byte #$00
        .hex 250a
	.byte "song"
        .byte #$00
        .hex 254a
	.byte "sound"
        .byte #$00
        .hex 258a
	.byte "color1  "
        .hex 1d1d
        .byte #$00
        .hex 25ca
	.byte "color2  "
        .hex 1e1e
        .byte #$00
        .hex 260a
	.byte "Menu Return"
        .byte #$00
        .byte #$ff
        
                
guntner_title_name_table:
	.byte $c0,$c0,$c0,$c1,$c2,$c3,$c4,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2
	.byte $c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c5,$c0,$c0,$c0
	.byte $c0,$c0,$c0,$c6,$c7,$c8,$c9,$ca,$ca,$ca,$ca,$ca,$ca,$ca,$ca,$cb
	.byte $cc,$ca,$ca,$ca,$ca,$ca,$ca,$ca,$ca,$cb,$cc,$cd,$ce,$c0,$c0,$c0
	.byte $c0,$c0,$c0,$cf,$d0,$c0,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$d2
	.byte $d3,$d6,$d7,$d8,$d9,$da,$db,$dc,$dd,$d2,$d3,$de,$cf,$c0,$c0,$c0
	.byte $c0,$c0,$c0,$cf,$df,$e0,$e1,$d2,$d3,$e2,$d5,$e3,$e4,$e5,$d5,$d2
	.byte $d3,$e3,$e4,$e5,$d5,$d2,$e6,$e7,$d5,$d2,$e8,$e9,$ea,$c0,$c0,$c0
	.byte $c0,$c0,$c0,$cf,$d0,$e3,$d5,$d2,$d3,$e2,$d5,$e3,$d5,$e2,$d5,$d2
	.byte $d3,$e3,$d5,$e2,$d5,$d2,$eb,$ec,$ed,$d2,$d3,$e2,$ee,$c0,$c0,$c0
	.byte $c0,$c0,$c0,$cf,$d0,$e3,$d5,$ef,$f0,$f1,$f2,$f3,$ce,$f4,$d5,$d2
	.byte $d3,$f3,$ce,$f4,$d5,$ef,$f0,$f1,$f2,$d2,$f5,$f6,$cf,$c0,$c0,$c0
	.byte $c0,$c0,$c0,$cf,$f7,$f8,$d5,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$d2
	.byte $d3,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$e2,$cf,$c0,$c0,$c0
	.byte $c0,$c0,$c0,$f9,$fa,$fa,$fb,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$fc,$fa
	.byte $fa,$fd,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$fe,$fa,$fd,$c0,$c0
  
  
  
  
  
; TITLE SCREEN UPDATES

title_screen_update: subroutine
	; set rudy x
        lda #$38
        sta player_x_hi
        
        ; number of seconds before demo
	lda timer_seconds_1s
        ; add #$30 because timer based on numerical tiles
        cmp #$33
        ;cmp #$a3
        ;cmp #$30
        bne .sit_and_wait
.start_demo
        lda #1
        jsr palette_fade_out_init
.sit_and_wait
	lda player_up_d
        ora player_down_d
        ora player_left_d
        ora player_right_d
        ora player_select_d
        cmp #$00
        beq .dont_change_pos
        inc title_rudy_pos
        lda #%00000001
        and title_rudy_pos
        sta title_rudy_pos
        jsr timer_reset
        bne .do_nothing
.dont_change_pos
	lda player_start_d
        ora player_b_d
        ora player_a_d
        cmp #$00
        beq .do_nothing
        lda title_rudy_pos
        cmp #$01
        beq .goto_options
.start_game
        ;; disable start_d so game doesn't instantly pause
        lda #$00
        sta player_start_d
        sta player_a_d
        sta player_b_d
        ; init cut scene 00
        lda #3
        jsr palette_fade_out_init
        jsr clear_all_enemies
        jmp .do_nothing
.goto_options
	lda #2
        jsr state_update_set_addr
.do_nothing
	jsr title_screen_set_rudy_y
; except animate that color tho
        ; increase color
	inc title_screen_color
        lda title_screen_color
        lsr
        lsr
        lsr
        lsr
        lsr
        cmp #$0c
        bne .dont_reset_screen_color
        lda #$00
        sta title_screen_color
.dont_reset_screen_color
        adc #$01
        sta pal_bg_0_1
        sta pal_bg_2_1
	jmp state_update_done
        

  


  
; OPTION SCREEN UPDATES        

options_screen_update: subroutine
        
	jsr player_update_colors
	lda player_start_d
        beq .dont_start_game
        lda #$04 ; menu return pos
        cmp options_rudy_pos
        beq .dont_start_game
        lda #$00
        sta player_start_d
        jsr game_init
        lda #6
        jsr state_update_set_addr
        rts
        
.dont_start_game
	jsr options_screen_set_rudy_y
; check if option changes
	lda player_down_d
        cmp #$00
        beq .dont_change_option_down
        inc options_rudy_pos
.dont_change_option_down
	lda player_up_d
        cmp #$00
        beq .dont_change_option_up
        dec options_rudy_pos
.dont_change_option_up
; check option pos is in range
	lda options_rudy_pos
        cmp #$ff ; min value - 1
        bne .dont_wrap_up
        lda #$04
.dont_wrap_up
	cmp #$05 ; max value + 1
        bne .dont_wrap_down
        lda #$00
.dont_wrap_down
	sta options_rudy_pos
; show song id
	lda options_song_id
        cmp #100
        bne .song_id_no_reset
        lda #$00
        sta options_song_id
.song_id_no_reset
; show sound id
; play music if on
; XXX NMI game loop should auto-handle this?
	lda options_music_on
        beq .no_music
        jsr apu_game_music_frame
.no_music
; which option handler?
.options_case
        lda options_rudy_pos
        cmp #$00
        beq options_screen_song_handler
        cmp #$01
	beq options_screen_sfx_handler
        cmp #$02
        bne .not_color1
        jmp options_screen_color1_handler
.not_color1
        cmp #$03
        bne .not_color2
        jmp options_screen_color2_handler
.not_color2
	cmp #$04
       	bne .not_menu_return
        jmp options_menu_return
.not_menu_return
	jmp state_update_done
        rts
        
        

        
options_screen_song_handler: subroutine
	lda player_b_d
        beq .no_b
        lda #$00
        sta options_music_on
.no_b
	lda player_a_d
        beq .no_a
        lda #$01
        sta options_music_on
.no_a
	jmp state_update_done
        
        
options_screen_sfx_handler: subroutine
        lda player_right_d
        cmp #$00
        beq .dont_up_sound
        inc options_sound_id
.dont_up_sound
	lda player_left_d
        cmp #$00
        beq .dont_down_sound
    	dec options_sound_id
.dont_down_sound
	lda options_sound_id
        cmp #$ff
        bne .sound_id_no_reset
        lda #$06
        sta options_sound_id
.sound_id_no_reset
	cmp #$07
        bne .sound_id_not_maxed
        lda #$00
        sta options_sound_id
.sound_id_not_maxed
; trigger sound with button
	lda player_a_d
        ora player_b_d
        cmp #$00
        bne .trigger_sound
	jmp state_update_done
.trigger_sound
	ldx options_sound_id
        jsr sfx_test_delegator
	jmp state_update_done
        

options_screen_color1_handler: subroutine
	; starts at 14
	lda player_right_d
        beq .dont_increase
        inc player_color0
        lda #$1d
        cmp player_color0
        bne .dont_increase
        lda #$11
        sta player_color0
.dont_increase
	lda player_left_d
        beq .dont_decrease
        dec player_color0
        lda #$10
        cmp player_color0
        bne .dont_decrease
        lda #$1c
        sta player_color0
.dont_decrease
	jmp state_update_done

options_screen_color2_handler: subroutine
	; starts at 21
	lda player_right_d
        beq .dont_increase
        inc player_color1
        lda #$2d
        cmp player_color1
        bne .dont_increase
        lda #$20
        sta player_color1
.dont_increase
	lda player_left_d
        beq .dont_decrease
        dec player_color1
        lda #$1f
        cmp player_color1
        bne .dont_decrease
        lda #$2c
        sta player_color1
.dont_decrease
	jmp state_update_done
        
        
options_menu_return: subroutine
	lda player_a_d
        ora player_b_d
        ora player_start_d
        cmp #$00
        beq .do_nothing
        lda #4
        jsr state_update_set_addr
.do_nothing
	jmp state_update_done