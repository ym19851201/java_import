# javaimport

This plugin complements Java import statement using unite.vim.

## How to Use

* Create file named '.javaimport' just below your Java project directory  
  , and write directories and path to jar in the file as following.

```:.javaimport
{
  'runtime': '/path/to/rt.jar',

  'jar': [
    './lib/library.jar',
    '/path/to/library/you/need/library2.jar',
  ],
  'src': [
    './src',
    './test',
  ]
}
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

    + Supporting multi candidates

        - Choose some candidates with <Space> key (default of unite.vim)

        - Hit Return key or Choose 'complete import' action

## dependency

* unite.vim

## TODO

* TODOの英語化
* .javaimportに記述がないときの処理忘れてた
