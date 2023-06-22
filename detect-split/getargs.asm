;
; getargs.asm
;
; Converted from getargs.s in cc65
;

MAXARGS = 16
CL_SIZE = 64
SPACE   = 32
ATEOL   = $9B

DOSVEC  = $0A
XLINE   = $0880
LBUF    = 63

; see dosdetect.asm for all constants, duplicating for simplicity
XDOS    = 4
MAX_DOS_WITH_CMDLINE = XDOS

  .export GET_ARGS
  .import DOS_DETECT
  .import DOS_TYPE
  .import CL_BUFFER
  .import _ARGC
  .import _ARGV

  .zeropage
ptr1: .res 2

  .code


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

