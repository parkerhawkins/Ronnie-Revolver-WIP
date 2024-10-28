NMI:
	PLA
	PLA
	PLA
	
;Disable NMI
	LDA $2002
	LDA #%00010000
  STA $2000
	
;Detect State Change
	BIT $0300
	BPL .stateloadskip
	JMP STATELOAD
.stateloadskip
	
	
;Copy RAM to OAM
	CLV
	CLC
	;LDA <$0F (OG Flicker Strat)
	LDA #$00
	LSR A
	ROR A
	ROR A
  STA $2003
  LDA #$02
  STA $4014
	
;Update Screen bar
	BIT $0300
	BVC .updatescreenbarskip
	LDX #$20
	STX $2006
	LDX #$73
	STX $2006
	LDX #$09
.updatescreenbarloop:
	LDA $0020,x
	CLC
	ADC #$DD
	STA $2007
	DEX
	BPL .updatescreenbarloop
	LDA #$00
	STA $2006
	STA $2005
	STA $2005
	STA $2006
.updatescreenbarskip:

;Frame count for oam offsets
	LDX <$0F
	DEX
	BPL .framecountoamoffsetsskip
	LDX #$03
.framecountoamoffsetsskip:
	STX <$0F

;Frame count for walking animation
	LDX <$10
	DEX
	BPL .framecountwalkinganimationskip
	LDX #$06
	LDA <$0E
	EOR #%00000001
	STA <$0E
	JSR animateslimewalking
.framecountwalkinganimationskip:
	STX <$10
	
;3 Frame async timer
	DEC <$03
	BPL .timer3frameskip
	LDA #$02
	STA <$03
.timer3frameskip

;Decrement Shooting Cooldown
	LDA <$0D
	BEQ .shootingcooldownskip
	DEC <$0D
.shootingcooldownskip:

;Decrement Pause Cooldown
	LDA $0301
	BEQ .pausecooldownskip
	DEC $0301
.pausecooldownskip:

;Load Controller Input
	LDA <$01
	STA <$02
	LDA #$01
	STA $4016
	STA <$01
	LSR A
	STA $4016
.ControllerInputLoop:
	LDA $4016
	LSR A
	ROL <$01
	BCC .ControllerInputLoop

;Detect game over
	LDA $0300
	CMP #$04
	BNE .gameoverskip
	LDA #$01
	LDA <$01
	AND #%00010000
	BEQ .refreshskip
	JMP RESET
.refreshskip:
	JMP enableNMI
.gameoverskip:


;Used for Pause toggle
	LDA <$01
	AND #%00010000
	BNE .pausetogglebitskip
	STA <$11
.pausetogglebitskip

;Render Hearts
	LDA $0300
	AND #%00001111
	CMP #$02
	BNE .renderheartskip
	
	JSR createslime ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	LDX #$05
	STX <$F0
	LDX <$00
	INX
	STX <$F1
	LDA #$00
	STA <$F2
.renderheartsloop:
	LDA <$F2
	CLC
	ADC #$09
	STA <$F2
	DEC <$F0
	BMI .renderheartskip
	DEC <$F1
	BMI .renderblankheart
	LDA <$F0
	ASL A
	ASL A
	TAX
	LDA #$17
	STA $0220,X
	LDA #$15
	CLC
	ADC <$F2
	STA $0223,X
	LDA #$0F
	STA $0221,X
	LDA <$06
	BEQ .rendernormalhearts
	LDA <$38
	BEQ .rendernormalhearts
	LDA #$03
	STA $0222,X
	JMP .renderheartsloop
.rendernormalhearts:
	LDA #$02
	STA $0222,X
	JMP .renderheartsloop
.renderblankheart:
	LDA <$F0
	ASL A
	ASL A
	TAX
	LDA #$FE
	STA $0220,X
	STA $0221,X
	STA $0222,X
	STA $0223,X
	JMP .renderheartsloop
.renderheartskip:

;Pause Check
	LDA $0300
	AND #%00111111
	CMP #$02
	BNE .pausecheckskip
	LDA <$01
	AND #%00010000
	BEQ .pausecheckskip
	LDA $0301
	BNE .pausecheckskip
	LDA #%10000011
	STA $0300
	LDA #$01
	STA <$11
	JMP enableNMI
.pausecheckskip:

;Pause Menu Stuff
	LDA $0300
	CMP #$03
	BNE .resumeskip
	LDA <$11
	BNE .resumeskip2
	LDA <$01
	AND #%00010000
	BEQ .resumeskip2
	LDA #$42
	STA $0300
	LDA #$10
	STA $0301
	LDA $2002
	LDA #%11111110
  STA $2001
.resumeskip2:
	JMP enableNMI
.resumeskip:

;Opposing Input Check
	LDA <$01
	AND #%00001010
	LSR A
	AND <$01
	BEQ .opposinginputcheckskip
	LDA <$01
	EOR <$02
	AND #%11110000
	EOR <$02
	STA <$01
.opposinginputcheckskip:
	
;Title Screen Start Detector
	LDA $0300
	BNE .titlescreenwaitskip
	LDA <$01
	AND #%00010000
	BEQ .titlescreenwaitinternalskip
	LDA #%10000001
	STA $0300
.titlescreenwaitinternalskip:
	JMP enableNMI
.titlescreenwaitskip:

;Select Screen Operations
	LDX $0300
	DEX
	BNE .selectscreenopskip
	LDA <$01
	AND #%11000011
	ORA #%01000000
	STA <$01
;Detect Mode
	LDA $02FF
	SEC
	SBC #$3D
	CMP #$7C
	BCC .selectscreenopskip
	BVC .selectscreenopskipright
	LDA #$01
	STA <$06
	LDA #%11000010
	STA $0300
	LDA #$FE
	STA $02FC
	STA $02FD
	STA $02FE
	STA $02FF
	LDA #$00
	STA <$0A
	JMP enableNMI
.selectscreenopskipright:
	BPL .selectscreenopskip
	LDA #$00
	STA <$06
	LDA #%11000010
	STA $0300
	LDA #$FE
	STA $02FC
	STA $02FD
	STA $02FE
	STA $02FF
	LDA #$00
	STA <$0A
	JMP enableNMI
.selectscreenopskip:

;Diagonal Input Check
	LDA <$01
	AND #%00001111
	BEQ .notdiagonalinput
	SEC
	SBC #$01
	AND <$01
	BEQ .notdiagonalinput
	LDA <$05
	STA <$04
	JMP .diagonalcheckskip
.notdiagonalinput:
	LDA <$01
	AND #%00001111
	STA <$04
.diagonalcheckskip:
	LDA <$04
	STA <$05
	LDY #$00
	LDA <$04
	BEQ .gundirectionbytelog2plus1skip
.gundirectionbytelog2plus1:
	INY
	LSR <$04
	BCC .gundirectionbytelog2plus1
.gundirectionbytelog2plus1skip:
	STY <$04

;Cowboy Directional Animation
	TYA
	CLC
	ROL A
	TAY
	LDA cowboydirectionanimationtable, Y
	STA $0209
	INY
	LDA cowboydirectionanimationtable, Y
	STA $020D

;Cowboy color adjust
	LDX #$00
	LDA #$00
	STA <$F0
	LDY <$38
	BEQ .ccaloop
	LDA #$02
	STA <$F0
.ccaloop:
	LDA $0202,X
	AND #%11111100
	ORA <$F0
	STA $0202,X
	INX
	INX
	INX
	INX
	CPX #$10
	BNE .ccaloop

;Walking
	BIT <$01
	BVS .walkskip
	LDA <$01
	AND #%00001111
	BEQ .walkskip
	STA <$FA
	LSR <$FA
	BCC .skiprightsr
	JSR moveplayerright
.skiprightsr:
	LSR <$FA
	BCC .skipleftsr
	JSR moveplayerleft
.skipleftsr:
	LSR <$FA
	BCC .skipdownsr
	JSR moveplayerdown
.skipdownsr:
	LSR <$FA
	BCC .walkskip
	JSR moveplayerup
.walkskip:

;Walking Animation
	LDA <$04
	BEQ walkanimationskip
	BIT <$01
	BVS walkanimationskip
	LDX <$0E
	BEQ altwalkcycle
	INC $0209
	JMP walkanimationskip
altwalkcycle:
	INC $020D
walkanimationskip:

;Cowboy Cordination
	LDX #$00
	JSR spritecordination

;Gun Animation
	CLC
	LDA <$04
	ROL A
	ROL A
	TAY
	LDA gunanimationtable, Y
	ADC $0200
	STA $0210
	INY
	LDA gunanimationtable, Y
	STA $0211
	INY
	LDA gunanimationtable, Y
	STA $0212
	INY
	LDA gunanimationtable, Y
	CLC
	ADC $0203
	STA $0213

;Player Shoot
	BIT <$01
	BPL playershootskip
	LDA <$04
	BEQ playershootskip
	LDA <$0D
	BNE playershootskip
	LDA <$0A
	BNE playershootskip   ;Disable for fire resets
	LDA <$04
	STA <$0A
	ASL A
	TAY
	DEY
	DEY
	LDA $0210
	CLC
	ADC bulletoriginoffsets, Y
	STA $02FC
	INY
	LDA $0213
	CLC
	ADC bulletoriginoffsets, Y
	STA $02FF
	LDA #$0E
	STA $02FD
	LDA #$00
	STA $02FE
	LDA #$28  ;Shooting Cooldown Period
	STA <$0D
playershootskip:

;Move Bullet
	CLV
	LDA <$0A
	BEQ movebulletskip
	TAY
	DEY
	BNE .rightskip
	INC $02FF
	INC $02FF
	INC $02FF
	BVC movebulletskip
.rightskip:
	DEY
	BNE .leftskip
	DEC $02FF
	DEC $02FF
	DEC $02FF
	BVC movebulletskip
.leftskip:
	DEY
	BNE .downskip
	INC $02FC
	INC $02FC
	INC $02FC
	BVC movebulletskip
.downskip:
	DEC $02FC
	DEC $02FC
	DEC $02FC
	BVC movebulletskip
movebulletskip:

;Slime hurt cooldown decrement (and player hit)
	LDX #$04
.slimehurtloop:
	DEC <$34,X
	BPL .slimehurtzeroskip
	INC <$34,X
.slimehurtzeroskip
	DEX
	BPL .slimehurtloop

;Detect Bullet-Map Collisions
	LDX $02FF
	LDY $02FC
	JSR checkcollide
	BEQ .bulletcollideskip1
	JMP .deletebullet
.bulletcollideskip1:
	LDX $02FF
	LDY $02FC
	INX
	INY
	JSR checkcollide
	BEQ .bulletcollideskip
.deletebullet:
	LDA #$FE
	STA $02FC
	STA $02FD
	STA $02FE
	STA $02FF
	LDA #$00
	STA <$0A
.bulletcollideskip:

	JSR playerslimecollision

;Detect Bullet-Slime COllisions
	LDX #$FF
	STX <$D0
.detectbulletslimecollisionloop:
	INC <$D0
	LDX <$D0
	CPX #$04
	BEQ .detectbulletslimecollisionescape
	LDA <$34,X
	BEQ .bulletslimecollisionnormal
	TXA
	ASL A
	ASL A
	TAX
	LDA #$02
	STA $0242,X
	JMP .detectbulletslimecollisionloop
.bulletslimecollisionnormal:
	TXA
	ASL A
	ASL A
	TAX
	LDA #$01
	STA $0242,X
	LDA $0241,X
	CMP #$FE
	BEQ .detectbulletslimecollisionloop
	JSR detectbulletslimecollision
	JMP .detectbulletslimecollisionloop
.detectbulletslimecollisionescape:

;Move Slime
	LDA <$03
	BEQ .moveslimeskip
	JSR moveslime
.moveslimeskip:
	
;Death Animation:
	LDX #$04
	STX <$F3
.slimedeathanimationloop:
	LDX <$F3
	DEX
	STX <$F3
	BMI .slimedeathescape 
	LDA <$30,X
	BNE .slimedeathanimationloop
	LDA <$34,X
	STA <$F2
	BEQ .slimedeathanimationloop
	;Slime is dying
	TXA
	ASL A
	ASL A
	TAX
	LDA <$F2
	CMP #$0C
	BCC .slimedeath1skip
	INC <$60
	LDA #$22
	STA $0241,X
	JMP .slimedeathanimationloop
.slimedeath1skip:
	CMP #$07
	BCC .slimedeath2skip
	LDA #$23
	STA $0241,X
	JMP .slimedeathanimationloop
.slimedeath2skip:
	CMP #$02
	BCC .slimedeath3skip
	LDA #$24
	STA $0241,X
	JMP .slimedeathanimationloop
.slimedeath3skip:
	LDA #$FE
	STA $0240,X
	STA $0241,X
	STA $0242,X
	STA $0243,X
	JMP .slimedeathanimationloop
.slimedeathescape:

;Enable NMI
enableNMI:
	LDA $2002
	LDA #%10010000
	STA $2000
FOREVER:
	JMP FOREVER