# emehcs
へなちょこ逆向き Scheme  

# 簡単な説明
emehcs(エメックス) は、右から左へ式を評価する関数型言語です。  
https://github.com/abo-junghichi/revapp-interpreter さんに感銘を受けて作り始めました。  
高階関数、関数合成、部分適用などを特徴としています。  
Scheme と言いながら全然 Scheme に寄せてないです。  

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
