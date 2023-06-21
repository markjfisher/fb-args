; SpartaDosX get args routine.
;
; This skips any detection and is 126 bytes shorter

  .export _ARGC
  .export _ARGV
  .export GET_ARGS

MAXARGS = 16
CL_SIZE = 64

DOSVEC  = $0A
SPACE   = 32
ATEOL   = $9B
LBUF    = 63

  .zeropage
ptr1: .res 1

  .code

; this is the C-String buffer of 0 terminated strings copied from SDX buffer
; into our own
CL_BUFFER: .res CL_SIZE + 1
; Number of args parsed
_ARGC:      .res 1
; A list of pointers to the strings in the CL_BUFFER
_ARGV:      .res (1 + MAXARGS) * 2

; Converted from getargs.s in cc65
;
.proc GET_ARGS
    ldx #0

; Initialize CL_BUFFER buffer

argdos:
    ldy     #ATEOL
    sty     CL_BUFFER+CL_SIZE

; Move SpartaDOS buffer to our buffer

sparta:
    lda     DOSVEC
    clc
    adc     #<LBUF
    sta     ptr1
    lda     DOSVEC+1
    adc     #>LBUF
    sta     ptr1+1

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

