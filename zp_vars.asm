

;;;;; VARIABLES

	seg.u ZEROPAGE
	org $0

nmi_lockout	byte

sprite_0_y	byte
scroll_x	byte
scroll_page	byte
scroll_y	byte
scroll_speed	byte
scroll_speed_m	byte
bg_tile_default	byte
player_health	byte
player_lives	byte
player_heal_c	byte
demo_true	byte ; if set game in demo mode
player_demo_x	byte ; dest x for demo cornputer controlls
player_demo_y	byte ; dest y for same
player_demo_lr	byte
player_demo_ud	byte

player_x_hi	byte
player_x_lo	byte
player_y_hi	byte
player_y_lo	byte
player_coll_y	byte ; player_x plus 2 because collision box
player_gun_str	byte
bullet_cooldown byte ; count frames until next bullet
player_speed	byte ; 2 bit value 0..3 translates to 1..4
player_paused	byte
player_controls	byte
player_right	byte
player_right_d	byte
player_left	byte
player_left_d	byte
player_down	byte
player_down_d	byte
player_up	byte
player_up_d	byte
player_start	byte
player_start_d	byte
player_select	byte
player_select_d	byte
player_b	byte
player_b_d	byte
player_a	byte
player_a_d	byte
player_dir_bits	byte ; matches controller
player_boundless	byte

wtf		byte
rng0		byte
rng1		byte
rng2		byte

starfield_col	byte
starfield_rng	byte
starfield_page	byte
starfield_col0	byte
starfield_col1	byte

collision_0_x	byte
collision_0_y	byte
collision_0_w	byte
collision_0_h	byte
collision_1_x	byte
collision_1_y	byte
collision_1_w	byte
collision_1_h	byte

; 24 bit max value : 16777215
score_000000xx	byte
score_0000xx00	byte
score_00xx0000	byte
score_xx000000	byte

timer_frames_1s		byte
timer_frames_10s	byte
timer_seconds_1s	byte
timer_seconds_10s	byte
timer_minutes_1s	byte
timer_minutes_10s	byte

state_sprite0	byte
state_fade_in	byte
state_fade_out	byte
state_tripmode	byte
state_iframes	byte

state_render_addr_lo	byte
state_render_addr_hi	byte
state_update_addr_lo	byte
state_update_addr_hi	byte

nametable_tile_planter_addr_lo	byte
nametable_tile_planter_addr_hi	byte

enemy_temp_addr_lo	byte
enemy_temp_addr_hi	byte
enemy_ram_offset	byte
enemy_oam_offset	byte
enemy_slot_id		byte
enemy_slot_1_next	byte
enemy_slot_2_next	byte
enemy_slot_4_next	byte
enemy_temp_temp		byte
enemy_dmg_accumulator	byte
boss_x		byte
boss_y		byte
boss_v0		byte
boss_v1		byte
boss_v2		byte
boss_v3		byte
boss_v4		byte
boss_v5		byte

player_color0	byte
player_color1	byte
player_color2	byte
player_damage		byte
player_death_flag	byte

player_bullet_collision_temp_x	byte

you_dead_counter	byte

phase_kill_count	byte
phase_current		byte
phase_state		byte
phase_temp_addr_lo	byte
phase_temp_addr_hi	byte
phase_end_game		byte

temp00	byte
temp01	byte

pal_fade_c	byte
pal_fade_offset	byte
pal_fade_target	byte
pal_uni_bg	byte
pal_bg_0_1	byte
pal_bg_0_2	byte
pal_bg_0_3	byte
pal_bg_1_1	byte
pal_bg_1_2	byte
pal_bg_1_3	byte
pal_bg_2_1	byte
pal_bg_2_2	byte
pal_bg_2_3	byte
pal_bg_3_1	byte
pal_bg_3_2	byte
pal_bg_3_3	byte
pal_spr_0_1	byte
pal_spr_0_2	byte
pal_spr_0_3	byte
pal_spr_1_1	byte
pal_spr_1_2	byte
pal_spr_1_3	byte
pal_spr_2_1	byte
pal_spr_2_2	byte
pal_spr_2_3	byte
pal_spr_3_1	byte
pal_spr_3_2	byte
pal_spr_3_3	byte

sfx_frame_id		byte
sfx_counter		byte
audio_noise_mode	byte
audio_noise_pitch	byte
audio_noise_volume	byte
; XXX these are for music
; XXX could user better names?
audio_frame_counter     byte
audio_root_tone         byte
audio_pattern_pos	byte
audio_pattern_num       byte

title_screen_color	byte
title_rudy_pos		byte

options_rudy_pos	byte
options_music_on	byte
options_song_id		byte
options_sound_id	byte
options_rudy_color1	byte	
options_rudy_color2	byte

scroll_to_counter	byte
