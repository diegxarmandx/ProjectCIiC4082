.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00
  STA $2005
  STA $2005
  RTI
.endproc

.import reset_handler


.export main
.proc main

; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR


load_palettes:
    LDA palettes,X
    STA PPUDATA
    INX
    CPX #$20
    BNE load_palettes

; write sprite data
LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$ff ; # of sprites x 4 bytes
  BNE load_sprites

; First Tile
    LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0d
	STA PPUADDR
	LDX #$31
	STX PPUDATA

; Second tile
    LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0e
	STA PPUADDR
	LDX #$41
	STX PPUDATA

; third tile
    LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0f
	STA PPUADDR
	LDX #$51
	STX PPUDATA

;fourth tile
    LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$10
	STA PPUADDR
	LDX #$61
	STX PPUDATA

;fifth tile
    LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$11
	STA PPUADDR
	LDX #$81
	STX PPUDATA

;sixth tile

    LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$12
	STA PPUADDR
	LDX #$91
	STX PPUDATA


;seventh tile
    LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$13
	STA PPUADDR
	LDX #$a1
	STX PPUDATA

;eight tile
    LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$14
	STA PPUADDR
	LDX #$b1
	STX PPUDATA

; attribute table First Stage
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$c2
	STA PPUADDR
	LDA #%01000000
	STA PPUDATA

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK


forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $0f, $00, $16, $1a
.byte $0f, $2c, $24, $2b
.byte $0f, $2c, $24, $2b
.byte $0f, $2c, $24, $2b

.byte $0f, $3d, $21, $30
.byte $0f, $3d, $21, $30
.byte $0f, $3d, $21, $30
.byte $0f, $3d, $21, $30

sprites:
    ;going right

  .byte $10, $05, $00, $10  ; 
  .byte $18, $15, $00, $10  ; 
  .byte $10, $06, $00, $18  ; 
  .byte $18, $16, $00, $18  ; 

  .byte $10, $07, $00, $20  ; 
  .byte $18, $17, $00, $20  ; 
  .byte $10, $08, $00, $28 ; 
  .byte $18, $18, $00, $28  ; 

  .byte $10, $09, $00, $30  ; 
  .byte $18, $19, $00, $30  ; 
  .byte $10, $0a, $00, $38  ; 
  .byte $18, $1a, $00, $38  ; 

  ;going left

  .byte $20, $35, $00, $10  ; 
  .byte $28, $45, $00, $10  ; 
  .byte $20, $36, $00, $18  ; 
  .byte $28, $46, $00, $18  ; 

  .byte $20, $37, $00, $20  ; 
  .byte $28, $47, $00, $20  ; 
  .byte $20, $38, $00, $28  ; 
  .byte $28, $48, $00, $28  ; 

  .byte $20, $39, $00, $30  ; 
  .byte $28, $49, $00, $30  ; 
  .byte $20, $3a, $00, $38  ; 
  .byte $28, $4a, $00, $38  ; 

  ;going up

  .byte $30, $95, $00, $10  ; 
  .byte $38, $a5, $00, $10  ; 
  .byte $30, $96, $00, $18  ; 
  .byte $38, $a6, $00, $18  ; 

  .byte $30, $97, $00, $20  ; 
  .byte $38, $a7, $00, $20  ; 
  .byte $30, $98, $00, $28  ; 
  .byte $38, $a8, $00, $28  ; 

  .byte $30, $99, $00, $30  ; 
  .byte $38, $a9, $00, $30  ; 
  .byte $30, $9a, $00, $38  ; 
  .byte $38, $aa, $00, $38  ; 

  ;going down

  .byte $40, $65, $00, $10  ; 
  .byte $48, $75, $00, $10  ; 
  .byte $40, $66, $00, $18  ; 
  .byte $48, $76, $00, $18  ; 

  .byte $40, $67, $00, $20  ; 
  .byte $48, $77, $00, $20  ; 
  .byte $40, $68, $00, $28  ; 
  .byte $48, $78, $00, $28  ; 

  .byte $40, $69, $00, $30  ; 
  .byte $48, $79, $00, $30  ; 
  .byte $40, $6a, $00, $38  ; 
  .byte $48, $7a, $00, $38  ; 



.segment "CHR"
.incbin "graphics.chr"