  .export _ARGC
  .export _ARGV
  .export GET_ARGS
  .export DOS_TYPE

;
; dosdetect.asm
;
; Taken from dosdetect.s in cc65 source
; Sets DOS_TYPE to current DOS from table below
;

SPARTADOS    = 0
REALDOS      = 1
BWDOS        = 2
OSADOS       = 3
XDOS         = 4
ATARIDOS     = 5
MYDOS        = 6
NODOS        = 255
MAX_DOS_WITH_CMDLINE = XDOS

MAXARGS = 16
CL_SIZE = 64

COMTAB  = 0
ZCRNAME = 3
DOSVEC  = $0A
DOS     = $0700
XLINE   = $0880

SPACE   = 32
ATEOL   = $9B
LBUF    = 63

  .zeropage
ptr1: .res 1

  .code

DOS_TYPE:  .res 1
CL_BUFFER: .res CL_SIZE + 1
_ARGC:      .res 1
_ARGV:      .res (1 + MAXARGS) * 2

.proc DOS_DETECT

    ldx     #0

    lda     DOS
    cmp     #'S'            ; SpartaDOS
    beq     spdos
    cmp     #'M'            ; MyDOS
    beq     mydos
    cmp     #'X'            ; XDOS
    beq     xdos
    cmp     #'R'            ; RealDOS
    beq     rdos

    lda     #$4C            ; probably default (MJF: 6502 JMP = $4c)
    ldy     #COMTAB
    cmp     (DOSVEC),y
    bne     done
    ldy     #ZCRNAME
    cmp     (DOSVEC),y
    bne     done

    ldy     #6              ; OS/A+ has a jmp here
    cmp     (DOSVEC),y
    ; MJF: is this correct? seem to be comparing to #$4C and if it's equal finishes rather than setting OSADOS
    beq     done
    lda     #OSADOS
    bne     __set

spdos:
    lda     DOS+3           ; 'B' in BW-DOS
    cmp     #'B'
    bne     spdos_real
    lda     DOS+4           ; 'W' in BW-DOS
    cmp     #'W'
    bne     spdos_real

    ; the following 2C bytes avoid the need for a JMP, as they do a harmless BIT instruction that ALSO eats
    ; the 2 bytes after them. Thus instead of any jump instructions, a bunch of effective NOP commands happen
    ; until the final _set location is hit.
    lda     #BWDOS
    .byte   $2C             ; BIT <abs>

spdos_real:
    lda     #SPARTADOS
    .byte   $2C             ; BIT <abs>

mydos:
    lda     #MYDOS
    .byte   $2C             ; BIT <abs>

rdos:
    lda     #REALDOS
    .byte   $2C             ; BIT <abs>

xdos:
    lda     #XDOS
__set:
    sta     DOS_TYPE
done:
    rts

.endproc

;
; getargs.asm
;
; Converted from getargs.s in cc65
;
.proc GET_ARGS
    ; get dos version
    jsr DOS_DETECT
    lda DOS_TYPE

    ldx #0

    cmp     #MAX_DOS_WITH_CMDLINE
    bcc     argdos
    beq     argdos
    ; no command line parsing with this DOS
    ; return 1 (error) in A, x already 0
    lda #1
    rts

; Initialize CL_BUFFER buffer

argdos:
    ldy     #ATEOL
    sty     CL_BUFFER+CL_SIZE

; Move SpartaDOS/XDOS command line to our own buffer

    cmp     #XDOS
    bne     sparta

    lda     #<XLINE
    sta     ptr1
    lda     #>XLINE
    sta     ptr1+1
    bne     cpcl0

sparta:
    lda     DOSVEC
    clc
    adc     #<LBUF
    sta     ptr1
    lda     DOSVEC+1
    adc     #>LBUF
    sta     ptr1+1

cpcl0:
    ldy     #0
cpcl:
    lda     (ptr1),y
    sta     CL_BUFFER,y
    iny
    cmp     #ATEOL
    beq     movdon
    cpy     #CL_SIZE
    bne     cpcl

movdon:
    lda     #0
    sta     CL_BUFFER,y     ; null terminate behind ATEOL

    ; Turn command line into argv table

    ;ldy    #0
    tay
eatspc:
    lda     CL_BUFFER,y     ; eat spaces
    cmp     #ATEOL
    beq     finargs
    cmp     #SPACE
    bne     rpar        ; begin of argument found
    iny
    cpy     #CL_SIZE
    bne     eatspc
    beq     finargs     ; only spaces is no argument

; Store argument vector

rpar:
    lda     _ARGC      ; low-byte
    asl
    tax                 ; table index
    tya                 ; CL_BUFFER index
    clc
    adc     #<CL_BUFFER
    sta     _ARGV,x
    lda     #>CL_BUFFER
    adc     #0
    sta     _ARGV+1,x
    ldx     _ARGC
    inx
    stx     _ARGC
    cpx     #MAXARGS
    beq     finargs

; Skip this arg.

skiparg:
    ldx     CL_BUFFER,y
    cpx     #ATEOL      ; end of line?
    beq     eopar
    cpx     #SPACE
    beq     eopar
    iny
    cpy     #CL_SIZE
    bne     skiparg

; End of arg. -> place 0

eopar:
    lda     #0
    sta     CL_BUFFER,y
    iny                 ; y behind arg.
    cpx     #ATEOL      ; was it the last arg?
    bne     eatspc

; Finish args

finargs:
    lda     _ARGC
    asl
    tax
    lda     #0
    sta     _ARGV,x
    sta     _ARGV+1,x

    ; return 0 as success result to FB
    lda     #0
    ldx     #0
    rts

.endproc

