let s:unite_javaimport = {
\ "name" : "javaimport",
\ "description": "test example",
\ "action_table": {
\   "complete_import": {
\     "description": "complete",
\     "is_selectable": 1,
\   }
\ },
\ "max_candidates": 30,
\ "default_action": "complete_import",
\}

function! s:unite_javaimport.action_table.complete_import.func(candidates)
  let current_row = line('.')
  let current_col = col('.')

  call cursor(line('$'), 1)
  let first_import = search("^import")
  if first_import == 0
    let package_line = search("^package")
    call append(package_line, "")
    for candidate in a:candidates
      call append(package_line+1, "import ".candidate.word.";")
    endfor
    return
  endif

  call cursor(1, 1)
  let last_import = search("^import", 'b')
  for candidate in a:candidates
    call append(last_import, "import ".candidate.word.";")
  endfor
  let first_str = printf('%s', first_import)
  let last_str = printf('%s', last_import+1)
  execute first_str.','.last_str.'sort'

  call cursor(current_row, current_col)
endfunction

function! s:unite_javaimport.gather_candidates(args, context)
  if filereadable('./.javaimport') == 0
    return
  endif

  let dict = eval(join(readfile('./.javaimport')))

  let jar_tf = systemlist("jar tf ".dict.runtime)
  let classes = filter(jar_tf, '
        \v:val =~ ".*\.class$"
        \&& v:val !~ "$.*\.class$"
        \&& v:val !~ "^com\.oracle"
        \&& v:val !~ "^com\.sun"
        \&& v:val !~ "^sun"
        \&& v:val !~ "^sunw"
        \&& v:val !~ "^org\.ietf"
        \&& v:val !~ "^org\.jcp"
        \&& v:val !~ "^org\.omg"
        \&& v:val !~ "^org\.w3c"
        \&& v:val !~ "^org\.xml"
        \&& v:val !~ "^java\.lang"
        \')

  let other_jars = dict.jar
  for jar in other_jars
    let jar_tf = filter(systemlist("jar tf ".jar), 'v:val =~ ".*\.class$" && v:val !~ "$.*\.class$"')
    let classes += jar_tf
  endfor

  let sources = dict.src
  for src in sources
    let java_files = split(globpath(src, '**/*.java'), '\n\|\r\n\|\r')
    let java_files = map(java_files
    \, 'substitute(substitute(substitute(v:val, src."/", "", "g"), "^./", "", "g"), "\.java$", "", "g")'
    \)
    let classes += java_files
  endfor

  return map(classes, '{
\   "word": substitute(substitute(v:val, "\.class$", "", "g"), "/", ".", "g"),
\   "source": "javaimport",
\   "kind": "word",
\ }')
endfunction


function! unite#sources#javaimport#define()
  return [deepcopy(s:unite_javaimport)]
endfunction
