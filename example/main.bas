' Demonstration application reading args from command line

' sets variable arg$ to the command line arg specified by parameter _n
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


' MAIN START
_r = USR(@GET_ARGS)
if _r <> 0
  ? "Unable to get cmd line args"
  end
endif

' Loop through all args and display them

' argv includes the command name, so argc is 1 higher than the number of args
' you type on the command line
' e.g. "D1:main.xex hello world"
' argc = 3, with args:
' arg 0 = D1:main.xex
' arg 1 = hello
' arg 2 = world
argc = PEEK(@_ARGC)
for i = 1 to (argc - 1)
  @getArg i
  m$ = "arg": m$ =+ STR$(i)
  ? m$, arg$
next i

