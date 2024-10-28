;A=Pointer Index
RLEDECOMPRESSION:
	ASL A
	TAY
	LDA compressedlevelpointers, Y
	STA <$08
	INY
	LDA compressedlevelpointers, Y
	STA <$09
	LDY #$00
	STY <$FF
rledecoderloop:
	LDA [$08],y
	BEQ consecutivedirective
	TAX
	INY
	LDA [$08],y
	INY
	STY <$FE
	LDY <$FF
repeatingvalueloop:
	STA $2007
	INY
	DEX
	BNE repeatingvalueloop
	STY <$FF
	LDY <$FE
	JMP rledecoderloop
consecutivedirective:
	INY
	LDA [$08],y
	BEQ rledecoderend
	LDX <$FF
	STA <$FD
	INC <$FD
consecutivedirectiveloop:
	INY
	DEC <$FD
	BEQ consecutivedirectiveend
	LDA [$08],y
	STA $2007
	INX
	JMP consecutivedirectiveloop
consecutivedirectiveend:
	STX <$FF
	JMP rledecoderloop
rledecoderend:
	RTS
	