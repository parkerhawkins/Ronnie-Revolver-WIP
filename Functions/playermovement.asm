;4 Part Sprite Cordination x=first sprite
spritecordination:
	CLC
	LDA $0200,X
	STA $0204,X
	ADC #$08
	STA $0208,X
	STA $020C,X
	LDA $0203,X
	STA $020B,X
	ADC #$08
	STA $0207,X
	STA $020F,X
	RTS

;Go Right
moveplayerright:
	INC $0203
	LDA $0203
	CLC
	ADC #$0A
	TAX
	LDA $0200
	CLC
	ADC #$06
	TAY
	JSR checkcollide
	BEQ .notcolliderighttop
	DEC $0203
.notcolliderighttop:
	LDA $0203
	CLC
	ADC #$0A
	TAX
	LDA $0200
	CLC
	ADC #$08
	TAY
	JSR checkcollide
	BEQ .notcolliderightmiddle
	DEC $0203
.notcolliderightmiddle:
	LDA $0203
	CLC
	ADC #$0A
	TAX
	LDA $0200
	CLC
	ADC #$10
	TAY
	JSR checkcollide
	BEQ .notcolliderightbottom
	DEC $0203
.notcolliderightbottom:
	RTS

;Go Left
moveplayerleft:
	DEC $0203
	LDA $0203
	CLC
	ADC #$05
	TAX
	LDA $0200
	CLC
	ADC #$06
	TAY
	JSR checkcollide
	BEQ .notcollidelefttop
	INC $0203
.notcollidelefttop:
	LDA $0203
	CLC
	ADC #$05
	TAX
	LDA $0200
	CLC
	ADC #$08
	TAY
	JSR checkcollide
	BEQ .notcollideleftmiddle
	INC $0203
.notcollideleftmiddle:
	LDA $0203
	CLC
	ADC #$05
	TAX
	LDA $0200
	CLC
	ADC #$10
	TAY
	JSR checkcollide
	BEQ .notcollideleftbottom
	INC $0203
.notcollideleftbottom:
	RTS
	
;Go Down
moveplayerdown:
	INC $0200
	LDA $0203
	CLC
	ADC #$05
	TAX
	LDA $0200
	CLC
	ADC #$10
	TAY
	JSR checkcollide
	BEQ .notcollidedownleft
	DEC $0200
.notcollidedownleft:
	LDA $0203
	CLC
	ADC #$0A
	TAX
	LDA $0200
	CLC
	ADC #$10
	TAY
	JSR checkcollide
	BEQ .notcollidedownright
	DEC $0200
.notcollidedownright:
	RTS

;Go Up
moveplayerup:
	DEC $0200
	LDA $0203
	CLC
	ADC #$05
	TAX
	LDA $0200
	CLC
	ADC #$06
	TAY
	JSR checkcollide
	BEQ .notcollideupleft
	INC $0200
.notcollideupleft:
	LDA $0203
	CLC
	ADC #$0A
	TAX
	LDA $0200
	CLC
	ADC #$06
	TAY
	JSR checkcollide
	BEQ .notcollideupright
	INC $0200
.notcollideupright:
	RTS