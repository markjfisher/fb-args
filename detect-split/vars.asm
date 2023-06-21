  .export DOS_TYPE
  .export CL_BUFFER
  .export _ARGC
  .export _ARGV

CL_SIZE  = 64
MAX_ARGS = 16

;  .segment "INIT"

DOS_TYPE:  .res 1, 5         ; default ATARIDOS
CL_BUFFER: .res CL_SIZE + 1
_ARGC:      .res 1
_ARGV:      .res (1 + MAX_ARGS) * 2
