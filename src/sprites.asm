.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
pad1: .res 1
frameCount: .res 1
animationCount: .res 1
.exportzp frameCount, animationCount
.exportzp player_x, player_y, pad1


.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import read_controller1

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00

  JSR read_controller1
  JSR updatePlayer


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
  LDA #$0a
  STA $0205
  LDA #$19
  STA $0209
  LDA #$1a
  STA $020d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$07      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$08
  STA $0205
  LDA #$17
  STA $0209
  LDA #$18
  STA $020d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$05      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$06
  STA $0205
  LDA #$15
  STA $0209
  LDA #$16
  STA $020d
  JMP tile_set_done

tile_set_done:

  ; write player tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f


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
  LDA #$39      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$3a
  STA $0205
  LDA #$49
  STA $0209
  LDA #$4a
  STA $020d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$37      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$38
  STA $0205
  LDA #$47
  STA $0209
  LDA #$48
  STA $020d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$35      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$36
  STA $0205
  LDA #$45
  STA $0209
  LDA #$46
  STA $020d
  JMP tile_set_done

tile_set_done:

  ; write player tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f


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
  LDA #$99      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$9a
  STA $0205
  LDA #$a9
  STA $0209
  LDA #$aa
  STA $020d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$97      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$98
  STA $0205
  LDA #$a7
  STA $0209
  LDA #$a8
  STA $020d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$95      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$96
  STA $0205
  LDA #$a5
  STA $0209
  LDA #$a6
  STA $020d
  JMP tile_set_done

tile_set_done:

  ; write player tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f


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
  LDA #$69      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$6a
  STA $0205
  LDA #$79
  STA $0209
  LDA #$7a
  STA $020d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$67     ; Use tile number for the second frame of animation
  STA $0201
  LDA #$68
  STA $0205
  LDA #$77
  STA $0209
  LDA #$78
  STA $020d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$65      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$66
  STA $0205
  LDA #$75
  STA $0209
  LDA #$76
  STA $020d
  JMP tile_set_done

tile_set_done:

  ; write player tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

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

.proc updatePlayer
  PHP  ; Start by saving registers,
  PHA  ; as usual.
  TXA
  PHA
  TYA
  PHA
; checking left
  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  JSR drawLeft
  DEC player_x  ; If the branch is not taken, move player left
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  JSR drawRight
  INC player_x
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  JSR drawUp
  DEC player_y
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking
  JSR drawDown
  INC player_y
done_checking:
  PLA ; Done with updates, restore registers
  TAY ; and return to where we called this
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


.segment "CHR"
.incbin "graphics.chr"