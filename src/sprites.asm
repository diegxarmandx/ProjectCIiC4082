.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
frameCount: .res 1
animationCount: .res 1

frameCount2: .res 1
animationCount2: .res 1

frameCount3: .res 1
animationCount3: .res 1

frameCount4: .res 1
animationCount4: .res 1

.exportzp frameCount, animationCount
.exportzp frameCount2, animationCount2
.exportzp frameCount3, animationCount3
.exportzp frameCount4, animationCount4



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

JSR drawRight
JSR drawLeft
JSR drawUp
JSR drawDown


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



; Right movement
.proc drawRight
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount
  LDA animationCount
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frameCount
  AND #$1e      ; When it hits 30 reset to 0 the frame counter
  CMP #$0a      ; Check which frame of animation to use
  BCC frame_1   ; If less than 10, use the first frame
  CMP #$14      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 20, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$09    ; Use tile number for the third frame of animation
  STA $0201
  LDA #$19
  STA $0205
  LDA #$0a
  STA $0209
  LDA #$1a
  STA $020d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$07      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$17
  STA $0205
  LDA #$08
  STA $0209
  LDA #$18
  STA $020d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$05      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$15
  STA $0205
  LDA #$06
  STA $0209
  LDA #$16
  STA $020d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; Increment frame counter
  INC frameCount

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Left movement
.proc drawLeft
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount2
  LDA animationCount2
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frameCount2
  AND #$1e      ; When it hits 30 reset to 0 the frame counter
  CMP #$0a      ; Check which frame of animation to use
  BCC frame_1   ; If less than 10, use the first frame
  CMP #$14      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 20, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$39      ; Use tile number for the third frame of animation
  STA $0211
  LDA #$49
  STA $0215
  LDA #$3a
  STA $0219
  LDA #$4a
  STA $021d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$37      ; Use tile number for the second frame of animation
  STA $0211
  LDA #$47
  STA $0215
  LDA #$38
  STA $0219
  LDA #$48
  STA $021d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$35      ; Use tile number for the first frame of animation
  STA $0211
  LDA #$45
  STA $0215
  LDA #$36
  STA $0219
  LDA #$46
  STA $021d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  ; Increment frame counter
  INC frameCount2

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; up movement
.proc drawUp
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount3
  LDA animationCount3
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frameCount3
  AND #$1e      ; When it hits 30 reset to 0 the frame counter
  CMP #$0a      ; Check which frame of animation to use
  BCC frame_1   ; If less than 10, use the first frame
  CMP #$14      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 20, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$99      ; Use tile number for the third frame of animation
  STA $0221
  LDA #$a9
  STA $0225
  LDA #$9a
  STA $0229
  LDA #$aa
  STA $022d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$97      ; Use tile number for the second frame of animation
  STA $0221
  LDA #$a7
  STA $0225
  LDA #$98
  STA $0229
  LDA #$a8
  STA $022d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$95      ; Use tile number for the first frame of animation
  STA $0221
  LDA #$a5
  STA $0225
  LDA #$96
  STA $0229
  LDA #$a6
  STA $022d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0222
  STA $0226
  STA $022a
  STA $022e

  ; Increment frame counter
  INC frameCount3

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; down movement
.proc drawDown
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount4
  LDA animationCount4
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frameCount4
  AND #$1e      ; When it hits 30 reset to 0 the frame counter
  CMP #$0a      ; Check which frame of animation to use
  BCC frame_1   ; If less than 10, use the first frame
  CMP #$14      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 20, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$69      ; Use tile number for the third frame of animation
  STA $0231
  LDA #$79
  STA $0235
  LDA #$6a
  STA $0239
  LDA #$7a
  STA $023d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$67     ; Use tile number for the second frame of animation
  STA $0231
  LDA #$77
  STA $0235
  LDA #$68
  STA $0239
  LDA #$78
  STA $023d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$65      ; Use tile number for the first frame of animation
  STA $0231
  LDA #$75
  STA $0235
  LDA #$66
  STA $0239
  LDA #$76
  STA $023d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0232
  STA $0236
  STA $023a
  STA $023e

  ; Increment frame counter
  INC frameCount4

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
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

.byte $90, $05, $00, $70  ; 
.byte $98, $15, $00, $70  ; right
.byte $90, $06, $00, $78  ; 
.byte $98, $16, $00, $78  ; 

.byte $90, $35, $00, $80  ; 
.byte $98, $45, $00, $80 ; left
.byte $90, $36, $00, $88  ; 
.byte $98, $46, $00, $88  ;

.byte $90, $95, $00, $90  ; 
.byte $98, $a5, $00, $90  ; 
.byte $90, $96, $00, $98  ; up
.byte $98, $a6, $00, $98  ; 

.byte $90, $65, $00, $a0  ; 
.byte $98, $75, $00, $a0  ; down
.byte $90, $66, $00, $a8  ; 
.byte $98, $76, $00, $a8  ; 




.segment "CHR"
.incbin "graphics.chr"