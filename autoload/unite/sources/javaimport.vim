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
\ "hooks": {},
\}

function! s:unite_javaimport.hooks.on_init(args, context)
  let s:dict = eval(join(readfile('./.javaimport')))
  let sources = s:dict.src
  let s:java_files = []
  for src in sources
    let java_files = split(globpath(src, '**/*.java'), '\n\|\r\n\|\r')
    let s:java_files += map(java_files
    \, 'substitute(substitute(substitute(substitute(v:val, src."/", "", "g"), "^./", "", "g"), "\.java$", "", "g"), "/", ".", "g")'
    \)
  endfor

  let s:lib_jars = []
  for jar in s:dict.jar
    let jar_tf = filter(systemlist("jar tf ".jar), 'v:val =~ ".*\.class$" && v:val !~ "$.*\.class$"')
    let s:lib_jars += jar_tf
  endfor
endfunction

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
  let current_imports = filter(getline(first_import, last_import), 'v:val != ""')
  let imports = current_imports + map(a:candidates, '"import ".v:val.word.";"')
  let imports = uniq(sort(imports))

  let first_str = printf('%s', first_import)
  let last_str = printf('%s', last_import)
  execute 'silent '.first_str.','.last_str.'delete'

  let dict =  s:to_dict(imports)
  let inserts = sort(dict['java'])
  call add(inserts, '')
  let inserts += sort(dict['javax'])
  call add(inserts, '')
  let inserts += sort(dict['lib'])
  let inserts += sort(dict['src'])
  call append(package_line + 2, inserts)

  call cursor(current_row, current_col)
endfunction

function! s:to_dict(list)
  let java_package_str = 'java'
  let javax_package_str = 'javax'
  let src_package_str = 'src'
  let lib_package_str = 'lib'
  let src_packages = s:dict.src
  let lib_packages = s:dict.jar
  for jar in lib_packages
    let jar_tf = filter(systemlist("jar tf ".jar), 'v:val =~ ".*\.class$" && v:val !~ "$.*\.class$"')
  endfor

  let dict = {java_package_str : [], javax_package_str : [], src_package_str : [], lib_package_str : []}
  for e in a:list
    if e =~ "^import ".javax_package_str
      call add(dict[javax_package_str], e)
    elseif e =~ "^import ".java_package_str
      call add(dict[java_package_str], e)
    else
      call add(dict[src_package_str], e)
    endif
  endfor

  return dict
endfunction

function! s:unite_javaimport.gather_candidates(args, context)
  if filereadable('./.javaimport') == 0
    return
  endif

  let jar_tf = systemlist("jar tf ".s:dict.runtime)
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

  let classes += s:lib_jars

  let sources = s:dict.src
  let classes += s:java_files

  return map(classes, '{
\   "word": substitute(substitute(v:val, "\.class$", "", "g"), "/", ".", "g"),
\   "source": "javaimport",
\   "kind": "word",
\   "action__package": split(v:val, "/")[0],
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

