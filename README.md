# fb-args

A small project to add cmd line args detection to FastBasic.

## Usage

There are 2 versions of the args routines.

1. detect/ which detects the DOS you are running
2. sdx/ an SDX specific version, a cutdown version of detect saving 126 bytes
   in final xex.

If your application needs to run in any cmd line capable environment use the detect/ directory.
Otherwise if you know you're only using SDX, then use the sdx/ directory.

The detect-split is same as detect, but the asm files are split over multiple
files, which I'm keeping to remind me how to do it when I look at this next
time.


A full example application is included in the [example](example/) directory.

For your own project, you simply need to include the appropriate asm file into
your project, and add the getArg function, and initialise reading the args
as follows:

```basic
proc getArg _n
  arg$ = ""
  _aArg = DPEEK(@_ARGV + _n * 2)
  _mp = PEEK(_aArg)
  while _mp <> 0
    arg$ =+ chr$(_mp)
    inc _aArg
    _mp = PEEK(_aArg)
  wend
endproc

_r = USR(@GET_ARGS)
```
