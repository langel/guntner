

;;;;; VARIABLES

	seg.u ZEROPAGE
	org $0

nmi_lockout	byte

scroll_x_hi	byte
scroll_x_lo	byte
scroll_y	byte
scroll_page	byte
scroll_speed_lo	byte
scroll_speed_hi	byte
scroll_cache_lo	byte
scroll_cache_hi	byte
ppu_mask_emph	byte
bg_tile_default	byte
player_health	byte
player_lives	byte
player_heal_c	byte
attract_true	byte ; if set game in demo mode
player_demo_x	byte ; dest x for demo cornputer controlls
player_demo_y	byte ; dest y for same
player_demo_lr	byte
player_demo_ud	byte

player_x_hi	byte
player_x_lo	byte	
player_y_hi	byte
player_y_lo	byte
player_coll_x	byte ; player_x plus 2 because collision box
player_coll_y	byte ; player_y plus 3 because collision box
player_gun_str	byte
player_speed	byte ; 2 bit value 0..3 translates to 1..4
player_paused	byte

player_controls			byte
player_controls_debounced	byte

player_boundless	byte
player_autofire_c	byte
player_autofire_s	byte
player_damage		byte
player_damage_flash	byte


game_difficulty		byte



wtf		byte ; frame counter lo
ftw		byte ; frame counter hi
rng0		byte
rng1		byte
rng2		byte

title_rudy_pos		byte
options_rudy_pos	byte
options_music_on	byte
options_song_id		byte
options_sound_id	byte
options_rudy_color1	byte
options_rudy_color2	byte
scroll_to_counter	byte

starfield_state		byte
starfield_column	byte
starfield_page		byte
starfield_color0	byte
starfield_color1	byte
starfield_trans_frame	byte
starfield_msg_pos_lo	byte
starfield_msg_pos_hi	byte
starfield_msg_return_lo	byte
starfield_msg_return_hi byte

collision_0_x	byte
collision_0_y	byte
collision_0_w	byte
collision_0_h	byte
collision_1_x	byte
collision_1_y	byte
collision_1_w	byte
collision_1_h	byte

dashboard_message	byte

timer_frames_1s		byte
timer_frames_10s	byte
timer_seconds_1s	byte
timer_seconds_10s	byte
timer_minutes_1s	byte
timer_minutes_10s	byte

state_v0		byte
state_v1		byte
state_v2		byte
state_v3		byte
state_v4		byte
state_v5		byte
state_v6		byte
state_v7		byte
state_sprite0		byte
state_iframes		byte
state_iframe_length	byte

state_render_addr	byte
state_update_addr	byte


nametable_tile_planter_addr_lo	byte
nametable_tile_planter_addr_hi	byte

phase_state		byte
phase_current		byte
phase_level		byte
phase_kill_counter	byte
phase_table_ptr		byte
phase_spawn_type	byte
phase_spawn_long_c	byte
phase_arctang_counter	byte
phase_spawn_counter	byte
phase_interval_counter	byte
phase_end_game		byte

player_frag_counter	byte
player_death_flag	byte
player_death_counter	byte
you_dead_counter	byte

powerup_counter	byte
powerup_offset	byte

bomb_counter	byte ; counts down animation frames
r_bag_counter	byte ; counts down autoturbo fire frames
shroom_counter	byte ; counts down animation frames
shroom_mod	byte ; apu pitch offset
orbit_shield_speed	byte ; 0 = no skull shield
orbit_shield_pos	byte

dart_frame_max		byte
dart_x_origin		byte
dart_y_origin		byte
dart_velocity		byte
dart_sprite		byte
dart_dir_adjust		byte


enemy_ram_offset	byte
enemy_oam_offset	byte
enemy_slot_id		byte
enemy_dmg_accumulator	byte
boss_dmg_handle_true	byte
boss_death_happening	byte
boss_heart_stars	byte
boss_x		byte
boss_y		byte
boss_eyes_pal	byte

arc_sequence_id		byte
arc_sequence_lo		byte
arc_sequence_hi		byte
arc_sequence_length	byte

arctang_velocity_lo	byte
arctang_velocity_hi	byte


temp00	byte
temp01	byte
temp02	byte
temp03	byte


pal_fade_c		byte
pal_fade_offset		byte
pal_fade_target		byte
state_fade_in		byte
state_fade_out		byte
state_from_white	byte

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

player_color0	byte
player_color1	byte
player_color2	byte


apu_pu1_counter		byte
apu_pu1_envelope	byte
apu_pu1_last_hi		byte
apu_tri_counter		byte ; !!! this order for x offset
apu_pu2_counter		byte
apu_pu2_envelope	byte
apu_pu2_last_hi		byte
apu_noi_counter		byte ; !!! must update apu_env_run if moved
apu_noi_envelope	byte

; apu variables
apu_rng0		byte
apu_rng1		byte
apu_temp		byte
sfx_temp00		byte
sfx_temp01		byte

sfx_phase_next_counter	byte
; counters to mask other channel audio
sfx_pu1_counter		byte
sfx_pu2_counter		byte
sfx_noi_counter		byte
; table offsets for update subroutines
sfx_pu2_update_type	byte
sfx_noi_update_type	byte

audio_song_id		byte
audio_frame_counter     byte
audio_root_tone         byte
audio_pattern_pos	byte
audio_pattern_num       byte



bullet_x_vel	= $c6
bullet_y_vel	= $c7
