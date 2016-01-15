# javaimport

This plugin complements Java import statement using unite.vim.

## How to Use

* Create file named '.classpath' just below your Java project directory  
  , and write classpaths (separated with ':') in the file.

```:.classpath
/your/project/directory/src:/your/project/directory/test:/your/project/directory/lib/xxx.jar
```

* Command

    Type one Ex command of the following.

    + :Unite javaimport
    + :JavaImport('-no-quit' option applied)

* Hit Return key or Choose 'complete import' action after refining and choosing candidate.

    + Refine and Choose

        ![](https://i.gyazo.com/f3c4bf895edaf8fed644265e7f72d09b.png)

    + Complement (and sort import statements)

        ![](https://i.gyazo.com/a123fd3e40d61ad3710609cc206c38c6.png)

## dependency

* unite.vim

## TODO

* rt.jarのパスのとり方変更

* 悲惨なVimScriptのリファクタリング

* TODOの英語化
