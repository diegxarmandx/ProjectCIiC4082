.include "constants.inc"
.segment "ZEROPAGE"
.importzp player_x, player_y, frameCounter, animationCounter


.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX PPUCTRL
  STX PPUMASK
  STX $4010
  BIT PPUSTATUS
vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

  LDX #$00
	LDA #$FF
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam
  ; initialize zero-page values
	LDA #$80
	STA player_x
	LDA #$a0
	STA player_y

  
vblankwait2:
  BIT PPUSTATUS
  BPL vblankwait2
  JMP main
.endproc