locatesector:
	;Takes X and Y as arguments respectively and returns sector as A
	LDA #$00
	STA <$F3
	STA <$F4
	CPX #$7F ;Midway
	BCC .xsplitskip
	ORA #%00000001
.xsplitskip:
	CPY #$87 ;Midway
	BCC .ysplitskip
	ORA #%00000010
.ysplitskip:
	;Find inner box
	CPY #$47
	BCC .innerboxskip
	CPY #$C7
	BCS .innerboxskip
	CPX #$1F
	BCC .innerboxskip
	CPX #$DF
	BCS .innerboxskip
	RTS
.innerboxskip:
	STA <$F0
	STX <$F1
	STY <$F2
	AND #%00000001
	BEQ .xslantoffsetskip
	LDA <$F1
	SEC
	SBC #$40
	STA <$F1
.xslantoffsetskip
	LDA <$F2
	SEC
	SBC #$28
	STA <$F2
	CMP <$F1
	BCC .fourthquadrantskip
	LDA #$01
	STA <$F3
.fourthquadrantskip:
	LDA <$F1
	ADC <$F2
	BCS .firstquadrantskip
	CMP #$C0
	BCS .firstquadrantskip
	LDA #$01
	STA <$F4
.firstquadrantskip:
	LDA <$F3
	EOR <$F4
	BNE .xorskip
	LDA <$F0
	ORA #%00001000
	RTS
.xorskip:
	LDA <$F0
	ORA #%00000100
	RTS