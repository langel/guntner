

sine_table:
	hex 808386898c8f9295
	hex 989b9ea2a5a7aaad
	hex b0b3b6b9bcbec1c4
	hex c6c9cbced0d3d5d7
	hex dadcdee0e2e4e6e8
	hex eaebedeef0f1f3f4
	hex f5f6f8f9fafafbfc
	hex fdfdfefefeffffff
	hex fffffffffefefefd
	hex fdfcfbfafaf9f8f6
	hex f5f4f3f1f0eeedeb
	hex eae8e6e4e2e0dedc
	hex dad7d5d3d0cecbc9
	hex c6c4c1bebcb9b6b3
	hex b0adaaa7a5a29e9b
	hex 9895928f8c898683
	hex 807c797673706d6a
	hex 6764615d5a585552
	hex 4f4c494643413e3b
	hex 393634312f2c2a28
	hex 2523211f1d1b1917
	hex 151412110f0e0c0b
	hex 0a09070605050403
	hex 0202010101000000
	hex 0000000001010102
	hex 0203040505060709
	hex 0a0b0c0e0f111214
	hex 1517191b1d1f2123
	hex 25282a2c2f313436
	hex 393b3e414346494c
	hex 4f5255585a5d6164
	hex 676a6d707376797c
        
        
        
; XXX !important
;     reduce cycle counts by keeping these
;     tables on the same page
ARCTANG_REGION_TO_X_VELOCITY_TABLE:
	byte 0, 1, 2, 3, 4, 5
        byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
        byte 6, 5, 4, 3, 2, 1
ARCTANG_REGION_TO_Y_VELOCITY_TABLE:
        byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
        byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
ARCTANG_REGION_X_PLUS_OR_MINUS_TABLE:
	; 1 = plus
        ; 0 = minus
        byte 1, 1, 1, 1, 1, 1
        byte 0, 0, 0, 0, 0, 0
        byte 0, 0, 0, 0, 0, 0
        byte 1, 1, 1, 1, 1, 1
ARCTANG_REGION_Y_PLUS_OR_MINUS_TABLE:
	; 1 = plus
        ; 0 = minus
        byte 0, 0, 0, 0, 0, 0
        byte 0, 0, 0, 0, 0, 0
        byte 1, 1, 1, 1, 1, 1
        byte 1, 1, 1, 1, 1, 1


arctang_velocity_tables:
	; region id = angle degrees
        ; 0 = 0
        ; 1 = 15
        ; 2 = 30
        ; 3 = 45
        ; 4 = 60
        ; 5 = 75
        ; 6 = 90
arctang_velocity_6.66:
	byte 168, 6
        byte 109, 6
        byte 193, 5
        byte 119, 4
        byte  84, 3
        byte 183, 1
        byte   0, 0
arctang_velocity_4.5:
	byte 127, 4
        byte  88, 4
        byte 229, 3
        byte  46, 3
        byte  64, 2
        byte  42, 1
        byte   0, 0
arctang_velocity_3.33:
	byte  85, 3
        byte  56, 3
        byte 227, 2
        byte  91, 2
        byte 171, 1
        byte 221, 0
        byte   0, 0
arctang_velocity_2.5:
	byte 127, 2
        byte 104, 2
        byte  43, 2
        byte 197, 1
        byte  64, 1
        byte 166, 0
        byte   0, 0
arctang_velocity_1.75:
	byte 191, 1
        byte 176, 1
        byte 131, 1
        byte  61, 1
        byte 223, 0
        byte 115, 0
        byte   0, 0
arctang_velocity_1.25:
	byte  64, 1
	byte  53, 1
        byte  20, 1
        byte 225, 0
        byte 161, 0
        byte  81, 0
        byte   0, 0
arctang_velocity_0.75:
	byte 191, 0
        byte 184, 0
        byte 166, 0
        byte 135, 0
        byte  96, 0
        byte  49, 0
        byte   0, 0
arctang_velocity_0.33:
	byte  84, 0
        byte  81, 0
        byte  73, 0
        byte  59, 0
        byte  42, 0
        byte  22, 0
        byte   0, 0
arctang_velocities_lo:
	byte #<arctang_velocity_6.66
	byte #<arctang_velocity_4.5
	byte #<arctang_velocity_3.33
	byte #<arctang_velocity_2.5
	byte #<arctang_velocity_1.75
	byte #<arctang_velocity_1.25
	byte #<arctang_velocity_0.75
	byte #<arctang_velocity_0.33
