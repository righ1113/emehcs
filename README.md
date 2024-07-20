# emehcs
へなちょこ逆向き Scheme  

# 簡単な説明
emehcs(エメックス) は、右から左へ式を評価する関数型言語です。  
https://github.com/abo-junghichi/revapp-interpreter さんに感銘を受けて作り始めました。  
高階関数、関数合成、部分適用などを特徴としています。  
Scheme と言いながら全然 Scheme に寄せてないです。  
```bash
$ bundle exec ruby app/emehcs.rb
emehcs version 0.1.0
emehcs> 1 1 + | 2 3 *
2
6
emehcs> 5 ((5 +) (2 *) >>>) (3 -) >>>
17
emehcs> loadFile ./sample/col_fizz.eme
collatz0
fizz
collatz
fizzbuzz
[1 2 4 8 16 5]
["FizzBuzz" 59 58 "Fizz" 56 "Buzz" "Fizz" 53 52 "Fizz" "Buzz" 49 "Fizz" 47 46 "FizzBuzz" 44 43 "Fizz" 41 "Buzz" "Fizz" 38 37 "Fizz" "Buzz" 34 "Fizz" 32 31 "FizzBuzz" 29 28 "Fizz" 26 "Buzz" "Fizz" 23 22 "Fizz" "Buzz" 19 "Fizz" 17 16 "FizzBuzz" 14 13 "Fizz" 11 "Buzz" "Fizz" 8 7 "Fizz" "Buzz" 4 "Fizz" 2 1]
emehcs>
```
```
... =x 左辺を評価する
... >x 左辺の関数に名前をつける
```

# 変更履歴
24/01/11 emehcs version 0.1.0  
・関数定義時、関数名を出力するようにした  
・7 true true が true を出力するようにした  
・[内部]関数テーブルを使うようにした  
・prelude に関数合成を追加した  
・文字列を "" で囲むようにした  
・REPL で '|' を使えるようにした  
・timer, cmd の実装  
・プリミティブ関数とプレリュード関数の整理整頓  
23/12/11 emehcs version 0.0.1  
23/12/04 init.  
