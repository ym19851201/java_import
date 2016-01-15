let s:unite_javaimport = {
\ "name" : "javaimport",
\ "description": "test example",
\ "action_table": {
\   "complete_import": {
\     "description": "complete",
\   }
\ },
\ "max_candidates": 30,
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
  let classes = filter(jar_tf, '
        \v:val =~ ".*class"
        \&& v:val !~ "$.*class"
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

  if filereadable('./.classpath') == 1
    let cps = split(readfile('./.classpath')[0], ':')
    let jars = filter(copy(cps), 'v:val =~ ".*jar"')
    let srcs = filter(copy(cps), 'v:val !~ ".*jar"')
    for jar in jars
      let jar_tf = filter(systemlist("jar tf ".jar), 'v:val =~ ".*class" && v:val !~ "$.*class"')
      let classes += jar_tf
    endfor

    let src_str = substitute(globpath(join(srcs, ','), '**/*.java'), getcwd().'/\(src\)\|\(test\)/', '', 'g')
    let src_cps = split(src_str, '\n')
    let classes += map(src_cps, 'substitute(v:val, "^/", "", "g")')
  endif

  return map(classes, '{
\   "word": substitute(substitute(v:val, ".class", "", "g"), "/", ".", "g"),
\   "source": "javaimport",
\   "kind": "word",
\ }')
endfunction


function! unite#sources#javaimport#define()
  return [deepcopy(s:unite_javaimport)]
endfunction
