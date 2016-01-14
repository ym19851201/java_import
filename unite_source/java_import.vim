let s:unite_javaimport = {
\ "name" : "javaimport",
\ "description": "test example",
\ "action_table": {
\   "complete_import": {
\     "description": "complete",
\   }
\ },
\ "default_action": "complete_import",
\}

function! s:unite_javaimport.action_table.complete_import.func(candidate)
  let current_row = line('.')
  let current_col = col('.')

  call cursor(line('$'), 1)
  let first_import = search("^import")
  if first_import == 0
    let package_line = search("^package")
    call append(package_line, "")
    call append(package_line+1, "import ".a:candidate.word.";")
    return
  endif

  call cursor(1, 1)
  let last_import = search("^import", 'b')
  call append(last_import, "import ".a:candidate.word.";")
  let first_str = printf('%s', first_import)
  let last_str = printf('%s', last_import+1)
  execute first_str.','.last_str.'sort'

  call cursor(current_row, current_col)
endfunction

function! s:unite_javaimport.gather_candidates(args, context)
  let java = system("which java")
  let java_home = system("readlink ".java)
  let java_home = system("readlink ".java_home)
  let rt_jar = substitute(java_home, "/bin/java", "/lib/rt.jar", "g")

  let jar_tf = systemlist("jar tf ".rt_jar)
  let classes = filter(jar_tf, 'v:val =~ ".*class"')
  let classes = filter(classes, 'v:val !~ "$.*class"')
  let classes = filter(classes, 'v:val !~ "^com\.oracle"')
  let classes = filter(classes, 'v:val !~ "^com\.sun"')
  let classes = filter(classes, 'v:val !~ "^sun"')
  let classes = filter(classes, 'v:val !~ "^sunw"')
  let classes = filter(classes, 'v:val !~ "^org\.ietf"')
  let classes = filter(classes, 'v:val !~ "^org\.jcp"')
  let classes = filter(classes, 'v:val !~ "^org\.omg"')
  let classes = filter(classes, 'v:val !~ "^org\.w3c"')
  let classes = filter(classes, 'v:val !~ "^org\.xml"')
  let classes = filter(classes, 'v:val !~ "^java\.lang"')

  return map(classes, '{
\   "word": substitute(substitute(v:val, ".class", "", "g"), "/", ".", "g"),
\   "source": "javaimport",
\   "kind": "word",
\ }')
endfunction

call unite#define_source(s:unite_javaimport)
unlet s:unite_javaimport
