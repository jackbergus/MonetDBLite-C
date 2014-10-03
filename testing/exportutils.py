import re

# a function-like #define that we expand to also find exports hidden
# in preprocessor macros
defre = re.compile(r'^[ \t]*#[ \t]*define[ \t]+'            # #define
                   r'(?P<name>[a-zA-Z_][a-zA-Z0-9_]*)'      # name being defined
                   r'\((?P<args>[a-zA-Z0-9_, \t]*)\)[ \t]*' # arguments
                   r'(?P<def>.*)$',                         # macro replacement
                   re.MULTILINE)
# line starting with a "#"
cldef = re.compile(r'^[ \t]*#', re.MULTILINE)

# white space
spcre = re.compile(r'\s+')

# some regexps helping to normalize a declaration
strre = re.compile(r'([^ *])\*')
comre = re.compile(r',\s*')

# do something a bit like the C preprocessor
#
# we expand function-like macros and remove all ## sequences from the
# replacement (even when there are no adjacent parameters that were
# replaced), but this is good enough for our purpose of finding
# exports that are hidden away in several levels of macro definitions
#
# we assume that there are no continuation lines in the input
def preprocess(data):
    defines = {}
    ndata = []
    for line in data.split('\n'):
        res = defre.match(line)
        if res is not None:
            name, args, body = res.groups()
            args = tuple(map(lambda x: x.strip(), args.split(',')))
            if len(args) == 1 and args[0] == '':
                args = ()       # empty argument list
            defines[name] = (args, body)
        else:
            tried = {}
            changed = True
            while changed:
                changed = False
                for name, (args, body) in defines.items():
                    if name in tried:
                        continue
                    pat = r'\b%s\b' % name
                    sep = r'\('
                    for arg in args:
                        pat = pat + sep + r'([^,(]*(?:\([^,(]*\)[^,(]*)*)'
                        sep = ','
                    pat += r'\)'
                    repl = {}
                    r = re.compile(pat)
                    res = r.search(line)
                    if res is not None:
                        tried[name] = True
                        changed = True
                    while res is not None:
                        bd = body
                        if len(args) > 0:
                            pars = map(lambda x: x.strip(), res.groups())
                            pat = r'\b(?:'
                            sep = ''
                            for arg, par in zip(args, pars):
                                repl[arg] = par
                                pat += sep + arg
                                sep = '|'
                            pat += r')\b'
                            r2 = re.compile(pat)
                            res2 = r2.search(bd)
                            while res2 is not None:
                                arg = res2.group(0)
                                bd = bd[:res2.start(0)] + repl[arg] + bd[res2.end(0):]
                                res2 = r2.search(bd, res2.start(0) + len(repl[arg]))
                            bd = bd.replace('##', '')
                        line = line[:res.start(0)] + bd + line[res.end(0):]
                        res = r.search(line, res.start(0) + len(bd))
            if not cldef.match(line):
                ndata.append(line)
    return '\n'.join(ndata)

def normalize(decl):
    decl = spcre.sub(' ', decl) \
                .replace(' ;', ';') \
                .replace(' (', '(') \
                .replace('( ', '(') \
                .replace(' )', ')') \
                .replace(') ', ')') \
                .replace('* ', '*') \
                .replace(' ,', ',') \
                .replace(')__attribute__', ') __attribute__')
    decl = strre.sub(r'\1 *', decl)
    decl = comre.sub(', ', decl)
    return decl
