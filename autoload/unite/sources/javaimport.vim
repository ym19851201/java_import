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
  let package_line = search("^package")
  if first_import == 0
    call append(package_line, "")
    call append(package_line+1, map(a:candidates, '"import ".v:val.word.";"'))
    return
  endif

  call cursor(1, 1)
  let last_import = search("^import", 'b')
  let current_imports = getline(first_import, last_import)
  let imports = current_imports + map(a:candidates, '"import ".v:val.word.";"')
  let imports = sort(My_uniq(imports), 's:compare')
  let first_str = printf('%s', first_import)
  let last_str = printf('%s', last_import)
  execute 'silent '.first_str.','.last_str.'delete'
  call append(package_line + 2, imports)

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

function! s:compare(l, r)
  if a:r == ''
    return 0
  endif
  return a:l > a:r
endfunction

function! My_uniq(list)
  let ret = []
  for elem in a:list
    if elem == ''
      call add(ret, elem)
    elseif count(ret, elem) == 0
      call add(ret, elem)
    endif
  endfor

  return ret
endfunction

