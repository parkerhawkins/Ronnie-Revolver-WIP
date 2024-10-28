  .inesprg 1
  .ineschr 1
  .inesmap 0
  .inesmir 1

	.bank 0
	.org $8000
	.include "functions\NMI.asm"
	.include "functions\RESET.asm"
	.include "functions\STATELOAD.asm"
	.include "functions\RLEDECOMPRESSION.asm"
	.include "data\bulkdata.asm"
	.include "functions\playermovement.asm"
	.include "functions\misc.asm"
	.include "functions\pathfinding.asm"
	.include "functions\slime.asm"
	.bank 1
	.org $A000

	.org $FFFA
  .dw NMI
  .dw RESET
  .dw 0 

	.bank 2
	.org $0000
	.incbin "ronnierevolver.chr"