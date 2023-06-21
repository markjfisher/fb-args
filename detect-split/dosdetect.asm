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

COMTAB  = 0
ZCRNAME = 3
DOSVEC  = $0A
DOS     = $0700

  .export DOS_DETECT
  .import DOS_TYPE

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
