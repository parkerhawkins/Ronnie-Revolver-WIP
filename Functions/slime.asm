createslime:
	LDX #$FF
.slimeopenslotloop:
	INX
	LDA <$30,X
	BNE .slimeopenslotloop
	LDA <$34,X
	BNE .slimeopenslotloop
	CPX #$04
	BCS .noslimesreturn
	LDA #$03
	STA <$30,X
	TXA
	ASL A
	ASL A
	TAX
	LDA #$8D
	STA $0240,X
	INX
	LDA #$20
	STA $0240,X
	INX
	LDA #$01
	STA $0240,X
	INX
	LDA #$7C
	STA $0240,X
.noslimesreturn:
	RTS
	
animateslimewalking:
	LDX #$FD
.animateslimewalkingloop:
	INX
	INX
	INX
	INX
	CPX #$11
	BCS .escapeslimewalkingloop
	LDA $0240,X
	CMP #$FE
	BEQ .animateslimewalkingloop
	CMP #$21
	BCC .secondaryactionslimewalking
	DEC $0240,X
	JMP .animateslimewalkingloop
.secondaryactionslimewalking:
	INC $0240,X
	JMP .animateslimewalkingloop
.escapeslimewalkingloop:
	RTS
	
	
;Very confusing- request a personal explanation at parkerhawkins882@yahoo.com
moveslime:
	LDA $020C
	TAY
	LDA $020F
	TAX
	JSR locatesector
	STA <$D2
	ASL A
	TAX
	LDA vectorfieldpointers,X
	STA <$D0
	INX
	LDA vectorfieldpointers,X
	STA <$D1
	LDX #$FC
	STX <$D3
.moveslimebigloop:
	LDX <$D3
	INX
	INX
	INX
	INX
	STX <$D3
	CPX #$10
	BNE .moveslimebigloopescapeskip
	JMP .moveslimebigloopescape
.moveslimebigloopescapeskip:
	LDA $0241,X
	CMP #$FE
	BEQ .moveslimebigloop
	TXA
	LSR A
	LSR A
	TAX
	LDA <$34,X
	BNE .moveslimebigloop
	LDX <$D3
	JSR detectcollisionwithotherslimes
	BCS .moveslimebigloop
	LDX <$D3
	LDA $0240,X
	CLC
	ADC #$04
	TAY
	LDA $0243,X
	CLC
	ADC #$04
	TAX
	JSR locatesector
	STA <$F4
	CMP <$D2
	BEQ .freewillfastpass
	LDX <$D3
	JSR detectiftouchingwall
	BEQ .nofreewill
.freewillfastpass:
	LDX <$D3
	LDA $0240,X
	CLC
	ADC #$04
	CMP $020C
	BCC .targetsectordown
	BEQ .targetsectorcleary
	JSR moveslimeup
	JMP .targetsectorcleary
.targetsectordown:
	JSR moveslimedown
.targetsectorcleary:
	LDX <$D3
	LDA $0243,X
	CLC
	ADC #$04
	CMP $020F
	BCC .targetsectorright
	BEQ .targetsectorclearx
	JSR moveslimeleft
	JMP .targetsectorclearx
.targetsectorright:
	JSR moveslimeright
.targetsectorclearx:
	JMP .moveslimebigloop
.nofreewill:
	LDY <$F4
	LDX <$D3
	.db $B1,$D0 ;LDA (D0),Y   (Takes direction from vectorfield)
	STA <$D4
	CMP #$00
	BNE .rightupmoveskip
	JSR moveslimeright
	LDX <$D3
	JSR moveslimeup
	JMP .moveslimebigloop
.rightupmoveskip:
	DEC <$D4
	BNE .leftupmoveskip
	JSR moveslimeleft
	LDX <$D3
	JSR moveslimeup
	JMP .moveslimebigloop
.leftupmoveskip:
	DEC <$D4
	BNE .rightdownmoveskip
	JSR moveslimeright
	LDX <$D3
	JSR moveslimedown
	JMP .moveslimebigloop2
.rightdownmoveskip:
	DEC <$D4
	BNE .moveslimebigloop2
	JSR moveslimeleft
	LDX <$D3
	JSR moveslimedown
.moveslimebigloop2:
	JMP .moveslimebigloop
.moveslimebigloopescape:
	RTS
		

	
moveslimeright:
	;Takes x as the slimes address *4
	STX <$F0
	INC $0243,X
	LDA $0243,X
	CLC
	ADC #$06
	TAY
	LDA $0240,X
	CLC
	ADC #$03
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notcolliderighttop
	LDX <$F0
	DEC $0243,X
.notcolliderighttop:
	LDX <$F0
	LDA $0243,X
	CLC
	ADC #$06
	TAY
	LDA $0240,X
	CLC
	ADC #$07
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notcolliderightbottom
	LDX <$F0
	DEC $0243,X
.notcolliderightbottom:
	RTS
	
moveslimeleft:
	;Takes x as the slimes address *4
	STX <$F0
	DEC $0243,X
	LDA $0243,X
	CLC
	ADC #$01
	TAY
	LDA $0240,X
	CLC
	ADC #$03
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notcollidelefttop
	LDX <$F0
	INC $0243,X
.notcollidelefttop:
	LDX <$F0
	LDA $0243,X
	CLC
	ADC #$01
	TAY
	LDA $0240,X
	CLC
	ADC #$07
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notcollideleftbottom
	LDX <$F0
	INC $0243,X
.notcollideleftbottom:
	RTS
	
moveslimedown:
	;Takes x as the slimes address *4
	STX <$F0
	INC $0240,X
	LDA $0243,X
	CLC
	ADC #$01
	TAY
	LDA $0240,X
	CLC
	ADC #$07
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notcollidebottomleft
	LDX <$F0
	DEC $0240,X
.notcollidebottomleft:
	LDX <$F0
	LDA $0243,X
	CLC
	ADC #$06
	TAY
	LDA $0240,X
	CLC
	ADC #$07
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notcollidebottomright
	LDX <$F0
	DEC $0240,X
.notcollidebottomright:
	RTS
	
moveslimeup:
	;Takes x as the slimes address *4
	STX <$F0
	DEC $0240,X
	LDA $0243,X
	CLC
	ADC #$01
	TAY
	LDA $0240,X
	CLC
	ADC #$03
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notcollidetopleft
	LDX <$F0
	INC $0240,X
.notcollidetopleft:
	LDX <$F0
	LDA $0243,X
	CLC
	ADC #$06
	TAY
	LDA $0240,X
	CLC
	ADC #$03
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notcollidetopright
	LDX <$F0
	INC $0240,X
.notcollidetopright:
	RTS
	
detectiftouchingwall:
	;Take x same as move
	STX <$F0
	LDA $0243,X
	CLC
	ADC #$FF
	TAY
	LDA $0240,X
	CLC
	ADC #$FF
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notrightwall
	LDA #$00
	RTS
.notrightwall:
	LDX <$F0
	LDA $0243,X
	CLC
	ADC #$09
	TAY
	LDA $0240,X
	CLC
	ADC #$09
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notleftwall
	LDA #$00
	RTS
.notleftwall:
	LDX <$F0
	LDA $0243,X
	CLC
	ADC #$FF
	TAY
	LDA $0240,X
	CLC
	ADC #$09
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notupwall
	LDA #$00
	RTS
.notupwall:
	LDX <$F0
	LDA $0243,X
	CLC
	ADC #$09
	TAY
	LDA $0240,X
	CLC
	ADC #$FF
	STY <$F1
	LDX <$F1
	TAY
	JSR checkcollide
	BEQ .notdownwall
	LDA #$00
	RTS
.notdownwall:
	LDA #$FF
	RTS
	
detectbulletslimecollision:
	LDA #$FF
	STA <$FA
	LDA $0240,X
	CLC
	ADC #$01
	CMP $02FC
	BCS .bulletslimereturnnull
	CLC
	ADC #$06
	CMP $02FC
	BCC .bulletslimereturnnull
	LDA $0243,X
	CLC
	ADC #$01
	CMP $02FF
	BCS .bulletslimereturnnull
	CLC
	ADC #$06
	CMP $02FF
	BCC .bulletslimereturnnull
	LDA #$FE
	STA $02FC
	STA $02FD
	STA $02FE
	STA $02FF
	LDA #$00
	STA <$0A
	TXA
	LSR A
	LSR A
	TAX
	STX <$F8
	LDA #$10
	STA <$34,X
	DEC <$30,X
	LDA #$00
	LDX #$09
.cleardecimaladdloop:
	STA <$E0,X
	DEX
	BPL .cleardecimaladdloop
	LDX <$F8
	LDA <$30,X
	BEQ .killpoints
	LDA #$05
	STA <$E0
	JSR decimaladding
	JMP .bulletslimereturnnull
.killpoints:
	LDA #$02
	STA <$E1
	JSR decimaladding
.bulletslimereturnnull:
	RTS
	
	
playerslimecollision:
	LDX #$04
	STX <$F0
	LDY $0200
	INY
	STY <$E2
	TYA
	CLC
	ADC #$0C
	STA <$E3
	LDY $0203
	INY
	STY <$E0
	TYA
	CLC
	ADC #$0C
	STA <$E1
.playerslimeloop:
	DEC <$F0
	BMI .playerslimeescape
	LDX <$F0
	LDA <$30,X
	BEQ .playerslimeloop
	LDA <$38
	BNE .playerslimeloop
	TXA
	ASL A
	ASL A
	TAX
	LDA $0240,X
	CLC
	ADC #$01
	STA <$E6
	ADC #$06
	STA <$E7
	LDA $0243,X
	CLC
	STA <$E4
	ADC #$07
	STA <$E5
	JSR colliderect
	BCC .playerslimeloop
	LDX <$F0
	LDA #$10
	STA <$34,X
	LDA #$00
	STA <$30,X
	LDA #$18
	STA <$38
	LDA <$06
	BNE .playerslimeescape
	DEC <$00
	BPL .playerslimeescape
	LDA #%10000100
	STA $0300
.playerslimeescape:
	RTS
	
detectcollisionwithotherslimes:
	;Takes x*4
	;Return C
	CLC
	LDA $0240,X
	ADC #$02
	STA <$E2
	ADC #$04
	STA <$E3
	LDA $0243,X
	ADC #$02
	STA <$E0
	ADC #$04
	STA <$E1
	LDY #$00
.detectcollisionwithotherslimesloop:
	INX
	INX
	INX
	INX
	CPX #$10
	BEQ .dcwose
	CLC
	LDA $0240,X
	ADC #$02
	STA <$E6
	ADC #$04
	STA <$E7
	LDA $0243,X
	ADC #$02
	STA <$E4
	ADC #$04
	STA <$E5
	JSR colliderect
	BCC .detectcollisionwithotherslimesloop
	RTS
.dcwose:
	CLC
	RTS