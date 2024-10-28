;Check Collide (x=xpos, y=ypos)
checkcollide:
	TXA
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	STA <$FF
	TYA
	SEC
	SBC #$28
	LSR A
	LSR A
	LSR A
	ASL A
	ASL A
	CLC
	ADC <$FF
	TAY
	TXA
	LSR A
	LSR A
	LSR A
	AND #%00000111
	TAX
	LDA $0500, y
	AND bitmask, x
	RTS

decimaladding: ;Formerly decimaladdinghell
	;Score to add at <$E0(Low)-<$E9(High) [BCD]
	LDX #$00
	STX <$F0
.decimaladdingloop:
	LDA <$20,X
	CLC
	ADC <$E0,X
	ADC <$F0
	LDY #$00
.dividebytenloop:
	CMP #$0A
	BCC .decimaladdingbreak
	INY
	SEC
	SBC #$0A
	BCS .dividebytenloop
.decimaladdingbreak:
	STY <$F0
	STA <$20,X
	INX
	CPX #$0A
	BNE .decimaladdingloop
	RTS
	
colliderect:
	;E0-E7, AX1,AX2,AY1,AY2,BX1,BX2,BY1,BY2
	;returns c flag
	LDA <$E0
	CMP <$E5
	BCS .crescape
	LDA <$E1
	CMP <$E4
	BCC .crescape
	LDA <$E2
	CMP <$E7
	BCS .crescape
	LDA <$E3
	CMP <$E6
	BCC .crescape
	SEC
	RTS
.crescape:
	CLC
	RTS
