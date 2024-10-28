STATELOAD:
;Disable PPU & NMI
	LDA #$00
	STA $2001
	LDA #%00010000
  STA $2000
;Find the new state
	LDA $0300
	AND #%00111111
	TAX
	BEQ .titleload
	DEX
	BEQ .selectload
	DEX
	BEQ .playload
	DEX
	BNE .pauseloadskip
	JMP .pauseload
.pauseloadskip:
	JMP .gameover
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TITLELOAD
.titleload:
	LDX #$23
	STX $2006
	LDX #$C0
	STX $2006
	LDA #$00
	LDX #$40
.clearatableloop:
	STA $2007
	DEX
	BNE .clearatableloop
	LDX #$20
	STX $2006
	LDX #$00
	STX $2006
	JSR RLEDECOMPRESSION
	LDA #%11111110
  STA $2001
	JMP .returntoNMI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SELECTLOAD
.selectload:
	LDX #$21
	STX $2006
	LDX #$ED
	STX $2006
	LDA #$01
	JSR RLEDECOMPRESSION
;Load Cowboy Reset
	LDX #$00
.cowboyloop:
	LDA cowboystart,X
	STA $0200,X
	INX
	CPX #$10
	BNE .cowboyloop
	LDA #$03
	STA <$11
	LDA #%11111110
  STA $2001
	JMP .returntoNMI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PLAYLOAD
.playload:
	LDX #$20
	STX $2006
	STX $2006
	LDA #$02
	JSR RLEDECOMPRESSION
	LDA #$03
	JSR RLEDECOMPRESSION
	LDA #%11111110
  STA $2001
	LDA #$5E
	STA $0200
	LDA #$79
	STA $0203
	
	LDA #$04
	STA <$00
	
;Load Collision Map
	LDX #$00
.loadcollisionmaploop:
	LDA collisionmapdata,x
	STA $0500,x
	INX
	CPX #$60
	BNE .loadcollisionmaploop
	JMP .returntoNMI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PAUSELOAD
.pauseload:
	LDA #%11111111
  STA $2001
	JMP .returntoNMI
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Game Over
.gameover:
	LDX #$20
	STX $2006
	STX $2006
	LDA #$04
	JSR RLEDECOMPRESSION
	LDX #$09
.updatescoreloop:
	LDA $0020,x
	CLC
	ADC #$DD
	STA $2007
	DEX
	BPL .updatescoreloop
	LDA #$05
	JSR RLEDECOMPRESSION
	LDA #%11101110
  STA $2001
	JMP .returntoNMI
	
.returntoNMI:
;Toggle STATELOAD
	LDA $0300
	AND #%01111111
	STA $0300
	
;Turn on PPU & NMI
	
	LDA #$00
	STA $2006
	STA $2005
	STA $2005
	STA $2006
	JMP enableNMI