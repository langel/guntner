
scrollto_options_handler: subroutine
	lda scroll_to_counter
        clc
        adc #$04
        sta scroll_to_counter
        tax
        lda sine_table,x
        sta scroll_y
        cpx #$40
        bne .done
        ; setup options
        lda #$01
        sta game_mode
        sta scroll_page
        jmp options_screen_init
.done
	rts
        
scrollto_titles_handler: subroutine
	lda scroll_to_counter
        sec
        sbc #$04
        sta scroll_to_counter
        tax
        lda sine_table,x
        sta scroll_y
        cpx #$c0
        bne .done
        ; setup options
        lda #$00
        sta game_mode
        sta scroll_page
        jmp title_screen_init
.done
	rts