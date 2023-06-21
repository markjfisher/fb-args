' Get args from command line

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
if _r <> 0
  ? "Unable to get cmd line args"
  end
endif
