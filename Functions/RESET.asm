RESET:
	SEI
	CLD
	CLV
	LDX #$FF
	TXS
	INX
	STX $2000
	STX $2001
	BIT $2002
.vblankwait1:
	BIT $2002
	BPL .vblankwait1
	TXA
.clrmem:
	STA $0000, x
	STA $0100, x
	STA $0300, x
	LDA #$FE
	STA $0200, x
	LDA #$00
	STA $0400, x
	STA $0500, x
	STA $0600, x
	STA $0700, x
	INX
	BNE .clrmem
.vblankwait2:
	BIT $2002
	BPL .vblankwait2
	LDA #%10000000
	STA $0300
	LDA #%10010000
	STA $2000
	
;Load Palettes
	LDX #$3F
	LDY #$00
	LDA $2002
	STX $2006
	STY $2006
	LDX #$1F
.paletteloop:
	LDA palette, x
	STA $2007
	DEX
	BNE .paletteloop
	
	LDA #%10000000
	STA $0300
	
	JMP FOREVER