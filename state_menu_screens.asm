; zp vars

;title_rudy_pos		EQU $181

;options_rudy_pos	EQU $182
;options_music_on	EQU $183
;options_song_id		EQU $184
;options_sound_id	EQU $185
;options_rudy_color1	EQU $186
;options_rudy_color2	EQU $187

;scroll_to_counter	EQU $188


menu_screens_init: subroutine

        jsr render_disable
        jsr nametables_clear
	jsr sprite_clear
        jsr state_sprite0_disable
        
	lda #state_render_jump_table_offset+1
        sta state_render_addr
        lda #state_update_jump_table_offset+1
	sta state_update_addr
        jsr state_clear ; a = 0
        sta scroll_x_hi
        sta scroll_page
        sta ppu_mask_emph ; reset mask
        jsr timer_reset
        jsr title_screen_set_rudy_y
        ; setup colors
        ldx #18
        ldy #0
        jsr palette_load
	lda #$0f
        sta pal_uni_bg
        ; setup everything else
	jsr player_game_reset
        jsr song_stop
        jsr dashboard_init
        jsr dashboard_update
        jsr dashboard_render
        
; copylines pal att
	PPU_SETADDR $23c0
        ldx #$37
.copylines_pal_loop
	txa
        cmp #$30
        bcs .bookbinder_gray
        txa
        and #$30
        bne .on8
.bookbinder_gray
        lda #%00001010
        bne .plot_pal
.on8
	lda #$00000000
.plot_pal
	sta PPU_DATA
        dex
        bpl .copylines_pal_loop
        
; G u n T n e R

; BIG TITLE
	PPU_SETADDR $2060
        ldy #$00
big_title_loop:
	lda guntner_title_name_table,y
	sta PPU_DATA
        iny
        bne big_title_loop

; pinline on title screen
	PPU_SETADDR $22c0
        lda #$b1
        ldy #$20
.pinline_footer
	sta PPU_DATA
        dey
        bne .pinline_footer

; pinline on options screen
	PPU_SETADDR $2420
        lda #$b1
        ldy #$20
.pinline_header
	sta PPU_DATA
        dey
        bne .pinline_header
        
; various stuff on screen        
        NMTP_SETADDR menu_screen_tile_data
        jsr nametable_tile_planter
        
; set rudy stuff
`	jsr menus_position_rudy
        jsr set_player_sprite
        
        jsr palette_fade_in_init
        jsr sfx_rng_chord
        
; turn ppu back on
	jsr render_enable
	rts



; vBLANK RENDER HANDLER
        
menu_screens_render: 
	; pretty much just for options screen
; show song id
	PPU_SETADDR $2514
	lda #char_set_offset
        sta PPU_DATA
	lda options_song_id
        jsr get_char_lo
        sta PPU_DATA
; show sound id
	PPU_SETADDR $2554
	lda options_sound_id
        jsr get_char_hi
        sta PPU_DATA
	lda options_sound_id
        jsr get_char_lo
        sta PPU_DATA
; show difficulty
	PPU_SETADDR $2649
        lda #0
        clc
        ldy game_difficulty
	beq .diff_offset_found
.diff_offset_finder
        adc #14
        dey
        bne .diff_offset_finder
.diff_offset_found
	tay
        ldx #0
.diff_place_loop
        lda difficulty_messages,y
        sta PPU_DATA
        inx
        iny
        cpx #14
        bne .diff_place_loop
        jmp state_render_done
        
        
        
        
        
; SCROLL HANDLERS

scrollto_options_update: subroutine
	lda scroll_to_counter
        clc
        adc #$04
        sta scroll_to_counter
        tax
        lda sine_table,x
        sta scroll_x_hi
        cpx #$40
        bne .done
        ; setup options
        lda #state_update_jump_table_offset+3
	sta state_update_addr
        lda #1
        sta scroll_page
        lda #$00
        sta scroll_x_hi
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
        sta scroll_x_hi
        cpx #$c0
        bne .done
        ; setup options
        lda #state_update_jump_table_offset+1
	sta state_update_addr
        lda #$00
        sta scroll_page
        jsr timer_reset
.done
	jsr menus_position_rudy
	jmp state_update_done



menus_position_rudy: subroutine
	lda scroll_x_hi
        bne .do_eeet
        rts
.do_eeet
        cmp #$48
        bcs .coming_from_right
.going_to_the_left
	jsr title_screen_set_rudy_y
	lda #$3a
	sec
        sbc scroll_x_hi
	jmp .plot_tiles
.coming_from_right
	jsr options_screen_set_rudy_y
	lda #$38
        sec
        sbc scroll_x_hi
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
        adc #$37
        sta player_y_hi
        jmp set_player_sprite

        
        
        
; STRINGS AND NAMETABLES
                
        
                
guntner_title_name_table:  ; 256 bytes
	byte $03,$03,$03,$c1,$c2,$c3,$c4,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2
	byte $c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c2,$c5,$03,$03,$03
	byte $03,$03,$03,$c6,$c7,$c8,$c9,$ca,$ca,$ca,$ca,$ca,$ca,$ca,$ca,$cb
	byte $cc,$ca,$ca,$ca,$ca,$ca,$ca,$ca,$ca,$cb,$cc,$cd,$ce,$03,$03,$03
	byte $03,$03,$03,$cf,$d0,$03,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$d2
	byte $d3,$d6,$d7,$d8,$d9,$da,$db,$dc,$dd,$d2,$d3,$de,$cf,$03,$03,$03
	byte $03,$03,$03,$cf,$df,$e0,$e1,$d2,$d3,$e2,$d5,$e3,$e4,$e5,$d5,$d2
	byte $d3,$e3,$e4,$e5,$d5,$d2,$e6,$e7,$d5,$d2,$e8,$e9,$ea,$03,$03,$03
	byte $03,$03,$03,$cf,$d0,$e3,$d5,$d2,$d3,$e2,$d5,$e3,$d5,$e2,$d5,$d2
	byte $d3,$e3,$d5,$e2,$d5,$d2,$eb,$ec,$ed,$d2,$d3,$e2,$ee,$03,$03,$03
	byte $03,$03,$03,$cf,$d0,$e3,$d5,$ef,$f0,$f1,$f2,$f3,$ce,$f4,$d5,$d2
	byte $d3,$f3,$ce,$f4,$d5,$ef,$f0,$f1,$f2,$d2,$f5,$f6,$cf,$03,$03,$03
	byte $03,$03,$03,$cf,$f7,$f8,$d5,$03,$03,$03,$03,$03,$03,$03,$03,$d2
	byte $d3,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$e2,$cf,$03,$03,$03
	byte $03,$03,$03,$f9,$fa,$fa,$fb,$03,$03,$03,$03,$03,$03,$03,$fc,$fa
	byte $fa,$fd,$03,$03,$03,$03,$03,$03,$03,$03,$03,$fe,$fa,$fd,$03,$03
  
  
title_screen_super_secret_code:
	byte $08,$08,$04,$04,$02,$01,$02,$01,$40,$80
  
  
; TITLE SCREEN UPDATES

title_screen_update: subroutine
	; set rudy x
        lda #$38
        sta player_x_hi
        
        ; number of seconds before demo
	lda timer_seconds_1s
        ; add #$30 because timer based on numerical tiles
        cmp #char_set_0+3
        ;cmp #$a3
        ;cmp #$30
        bne .sit_and_wait
.start_demo
        lda #1
        jsr palette_fade_out_init
.sit_and_wait
	; check for super secret code
	ldy state_v0
        bmi .super_secret_code_done
        lda player_controls
        and #$cf
        cmp state_v2
        beq .super_secret_code_done
        sta state_v2
        cmp #$00
        beq .super_secret_code_done
        cmp title_screen_super_secret_code,y
        beq .super_secret_code_next
        lda #$ff
        sta state_v0
        bmi .super_secret_code_done
.super_secret_code_next
	iny
        sty state_v0
        cpy #$0a
        bcc .super_secret_code_done
        lda #$01
        sta state_v1
.super_secret_code_done
        lda #BUTTON_UP|BUTTON_DOWN|BUTTON_LEFT|BUTTON_RIGHT
        and player_controls_debounced
        beq .dont_change_pos
        inc title_rudy_pos
        lda #%00000001
        and title_rudy_pos
        sta title_rudy_pos
        jsr timer_reset
        bne .do_nothing
.dont_change_pos
	lda #BUTTON_START
        ldy state_v0
        cpy #$ff
        bne .button_check
        ora #BUTTON_B|BUTTON_A
.button_check
	and player_controls_debounced
        beq .do_nothing
        lda title_rudy_pos
        cmp #$01
        beq .goto_options
.start_game:
	jsr menu_start_game
        jmp .do_nothing
        
.goto_options
        lda #state_update_jump_table_offset+2
	sta state_update_addr
.do_nothing
	jsr title_screen_set_rudy_y
; except animate that color tho
        ; increase color
        lda wtf
        and #$f
        bne .dont_next_title_color
        lda pal_bg_0_1
        jsr palette_next_rainbow_color
        sta pal_bg_0_1
.dont_next_title_color
	jmp state_update_done
        

menu_start_game: subroutine
	lda player_controls
        and #BUTTON_SELECT
        beq .not_cheater_boundless
        inc player_boundless
.not_cheater_boundless
        ;; disable start_d so game doesn't instantly pause
        lda #$00
        sta player_controls
        sta player_controls_debounced
        ; init cut scene 00
        lda #3
        jsr palette_fade_out_init
	rts
  


  
; OPTION SCREEN UPDATES        

options_screen_update: subroutine
        lda shroom_counter
        bne .skip_player_colors
	jsr player_update_colors
.skip_player_colors
	lda player_controls
        and #BUTTON_START
        beq .dont_start_game
        lda #$c0 ; set scroll to title screen
	sta scroll_to_counter
.start_game:
	jsr menu_start_game
	jmp state_update_done
        
.dont_start_game
	jsr options_screen_set_rudy_y
; check if option changes
	lda player_controls_debounced
        and #BUTTON_DOWN
        beq .dont_change_option_down
        inc options_rudy_pos
.dont_change_option_down
	lda player_controls_debounced
        and #BUTTON_UP
        beq .dont_change_option_up
        dec options_rudy_pos
.dont_change_option_up
; check option pos is in range
	lda options_rudy_pos
        cmp #$ff ; min value - 1
        bne .dont_wrap_up
        lda #$05
.dont_wrap_up
	cmp #$06 ; max value + 1
        bne .dont_wrap_down
        lda #$00
.dont_wrap_down
	sta options_rudy_pos
        
; which option handler?
options_screen_handler
        clc
        adc #options_screen_state_jump_table_offset
        jmp jump_to_subroutine

       
options_menu_return: subroutine
	lda player_controls_debounced
        and #BUTTON_B|BUTTON_A
        beq .do_nothing
        lda #state_update_jump_table_offset+4
	sta state_update_addr
.do_nothing
	jmp state_update_done
        

options_min_max:
	byte $00, $08	; song
        byte $00, $13	; sfx
        byte $10, $1c	; color1
        byte $20, $2c	; color2
        byte $00, $03	; difficulty
        
options_handle_change: subroutine
	; a = current value
        ; y = table offset
        sta temp00
        lda player_controls_debounced
        and #BUTTON_RIGHT
        beq .dont_increase
        inc temp00
        lda options_min_max+1,y
        cmp temp00
        bcs .done
        lda options_min_max,y
        sta temp00
.dont_increase
        lda player_controls_debounced
        and #BUTTON_LEFT
        beq .dont_decrease
        dec temp00
        bmi .go_max
        lda temp00
        cmp options_min_max,y
        bcs .done
.go_max
	lda options_min_max+1,y
        sta temp00
.dont_decrease
.done
	lda temp00
	rts
        
options_screen_song_handler: subroutine
	lda options_song_id
        ldy #0
        jsr options_handle_change
        sta options_song_id
; trigger song with button
	lda player_controls_debounced
        and #BUTTON_B
        beq .no_b
        jsr song_stop
.no_b
	lda player_controls_debounced
        and #BUTTON_A
        beq .no_a
        lda options_song_id
        jsr song_start
.no_a
	jmp state_update_done
        
        
options_screen_sfx_handler: subroutine
	lda options_sound_id
        ldy #2
        jsr options_handle_change
        sta options_sound_id
; trigger sound with button
	lda player_controls_debounced
        and #BUTTON_B|BUTTON_A
        bne .trigger_sound
	jmp state_update_done
.trigger_sound
	lda options_sound_id
        jsr sfx_test_delegator
	jmp state_update_done
        

options_screen_color1_handler: subroutine
	lda player_color0
        ldy #4
        jsr options_handle_change
	sta player_color0
	jmp state_update_done


options_screen_color2_handler: subroutine
	lda player_color1
        ldy #6
        jsr options_handle_change
	sta player_color1
	jmp state_update_done
        
        
options_screen_difficulty_handler: subroutine
        lda game_difficulty
        ldy #8
        jsr options_handle_change
	sta game_difficulty
	jmp state_update_done