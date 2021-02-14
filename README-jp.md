# Open Policy Agent (OPA) 事始め

Copyright: Hiro Osaki 2021

<!-- vscode-markdown-toc -->
* 1. [初めてのRego: Rego Playground](#Yourfirstcoding:TryRegoPlayground)
	* 1.1. [Rego言語のプログラムを動かしてみる (所要: 5分)](#Walkthrough5min)
	* 1.2. [まとめ: OPA が何をするのか (所要: 3分)](#WhatOPAdoes3min)
* 2. [自分の環境でOPAを起動する](#RunOPAonyourenvironment)
	* 2.1. [OPA をインストールする(所要: ~ 5分)](#InstallOPA5min)
	* 2.2. [OPAの起動を確認する (所要: 5分))](#CheckOPAruns5min)
	* 2.3. [OPAをサーバとして起動する  (所要: 5分)](#RunOPAasserver5min)
	* 2.4. [OPA にデータを読み込ませる (5 min)](#RunOPAserverwithloadingdata5min)
	* 2.5. [まとめ: OPAができること (所要: 3分)](#WhatOPAserverdoes3min)
* 3. [参考資料](#Reference)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

はじめに

このドキュメントは、[Open Policy Agent (OPA)](https://www.openpolicyagent.org/) を一度触ってみたいという方向けです. 

最短経路は8分で済みます.

[English version](./README.md)

##  1. <a name='Yourfirstcoding:TryRegoPlayground'></a>初めてのRego: Rego Playground

OPAとそこで使われるRego言語がどんなものなのかを掴むのに, OPAをインストールす必要はありません. 最速の方法は, [Styra](styra.com)が開発した["Rego Playground"](https://play.openpolicyagent.org/) というWebサービスを使うことです.

###  1.1. <a name='Walkthrough5min'></a>Rego言語のプログラムを動かしてみる (所要: 5分)

- https://play.openpolicyagent.org/ にアクセス.
- `Evaluate` ボタンをクリック.

  ![](img/2021-01-24-22-24-43.png)

- 初の **Rego 言語** プログラミングにチャレンジしましょう. 左のウィンドウの一番下に, 以下の3行を足します.

  ```
  newdata = msg {
    msg := concat("", ["Received the message: ", input.message])
  }
  ```

  この3行は、新しいデータ `newdata` を追加するコードです.

- 再度 `Evaluate` をクリック.
  
  `OUTPUT` ウィンドウに新しいデータ `newdata` が追加されます.

  ![](img/2021-01-24-22-26-25.png)

  その結果はこのようになります.
  ```
  {
    "hello": true,
    "newdata": "Received the message: world"
  }
  ```

  2行目の `"newdata": ...` が、新しいデータです. それ以外の `"hello"` は, もともとのソースコード `hello {...}` の結果です.

- `input`を変える
  - 右の `INPUT` ウィンドウに `"message":...` と書かれてあります.
  - この中身を `"message": "distopia"` に変えてみます.
  - `Evaluate` を再度クリック. このような結果が出るでしょう.
    ```
    {
        "hello": false,
        "newdata": "Received the message: distopia"
    }
    ```
    ![](img/2021-01-24-23-15-52.png)
  - `hello` の結果を見ます. 先ほどの `true` から `false` に結果が変わっています. 理由は, 
    
    `hello` の中身に `m == "world"` と書かれているためです. 
    
    この文は, もし `message` が `"world"` なら, 返り値は `true` になることを意味します. 
    
    そうでなければ, 返り値は `false` です.

- `data` を使ってみる
  - `data` ウィンドウに以下を書き込みます.
    ```
    {
      "rule": "be good"
    }
    ```
  - 左のウィンドウの最後の行に以下を追記します.
    ```
    importdata = msg {
      msg := concat("", ["Received the static data: ", data.rule])
    }
    ```
  - `Evaluate` を再度クリック.
    ![](img/2021-01-24-23-24-57.png)
  - 新たなコードの結果が表示されます.

    ```
    "importdata": "Received the static data: be good",
    ```

###  1.2. <a name='WhatOPAdoes3min'></a>まとめ: OPA が何をするのか (所要: 3分)

- Rego Playground を使ってみて分かること.
  ![](img/2021-01-24-23-17-41.png)
  1. **OPA はポリシーファイルを読み込む**.<br/> ポリシーファイルは Rego 言語で `newdata = msg {...}` のように記述されます. (Playgroundの左ウィンドウ)
  2. **OPA は `input` のデータを受け取る**.<br/> `input` のデータはJSONフォーマットでなければなりません. (Playgroundの右上ウィンドウ)
  3. **OPA は `data` のデータも受け取る**.<br/> `data` のデータもJSONフォーマットでなければなりません.  (Playgroundの右中央のウィンドウ. `data` は初期値で `{}`になっています)
  4. **OPA はポリシーの処理により `output` を生成する.**<br/> 生成される `output` もJSONフォーマットです. (Playgroundの右下ウィンドウ)
- まとめ: OPA はRegoファイルを読み込み, JSON データを処理します. そして, OPA は 出力のJSONデータを生成します.

- 詳細は, 公式ドキュメントの`introduction` https://www.openpolicyagent.org/docs/latest/ に記載されています.

##  2. <a name='RunOPAonyourenvironment'></a>自分の環境でOPAを起動する

###  2.1. <a name='InstallOPA5min'></a>OPA をインストールする(所要: ~ 5分)

- MacOSなら, 以下のコマンドでインストールできます.

  ```sh
  brew install opa
  ```
- その他の環境なら, 以下のドキュメントに従い `opa` コマンドをインストールします.
  - https://www.openpolicyagent.org/docs/latest/#running-opa

###  2.2. <a name='CheckOPAruns5min'></a>OPAの起動を確認する (所要: 5分))

- `opa run` を実行してみます.

  ```sh
  $ opa run
  ```

  その実行中に, `a = 3` や `exit` を実行できます.

  ```sh
  $ opa run
  OPA 0.26.0 (commit , built at )

  Run 'help' to see a list of commands and check for updates.

  > a = 3
  Rule 'a' defined in package repl. Type 'show' to see rules.
  > x = 3
  Rule 'x' defined in package repl. Type 'show' to see rules.
  > show
  package repl

  a = 3

  x = 3
  > exit
  ```

###  2.3. <a name='RunOPAasserver5min'></a>OPAをサーバとして起動する  (所要: 5分)

- `example.rego`というファイルを作成します.

  ```sh
  mkdir example/
  cd example/
  # create example.rego
  ```

  以下を`example.rego`として保存します. 1章と中身は同じですね.

  ```rego
  package play

  default hello = false

  hello {
      m := input.message
      m == "world"
  }

  newdata = msg {
      msg := concat("", ["Received the message: ", input.message])
  }

  importdata = msg {
      msg := concat("", ["Received the static data: ", data.rule])
  }
  ```

  `input.json` も以下の内容で作成します. これも1章と同じです.

  ```sh
  # create input.json
  ```

  ```json
  {
    "input": {
      "message": "world"
    }
  }
  ```

- 以下コマンドを実行します.

  ```sh
  opa run -s ./example.rego
  ```

- 別のコマンドラインから OPA サーバにリクエストを出します。

  - まずは `/v1/data/play` にアクセスします.

  ```sh
  $ curl localhost:8181/v1/data/play -i -d @input.json -H 'Content-Type: application/json'

  {"result":{"hello":true,"newdata":"Received the message: world"}}

  ```

  - 次に, `/v1/data/play/hello` にアクセスします.

  ```sh
  $ curl localhost:8181/v1/data/play/hello -i -d @input.json -H 'Content-Type: application/json'

  {"result":true}
  # Same as the value of "hello" in section 1.1
  ```

  - `/v1/data/play/newdata`

  ```sh
  $ curl localhost:8181/v1/data/play/newdata -i -d @input.json -H 'Content-Type: application/json'

  {"result":"Received the message: world"}
  # Same as the value of "newdata" in section 1.1
  ```

  - `/v1/data/play/importdata`

  ```sh
  $ curl localhost:8181/v1/data/play/importdata -i -d @input.json -H 'Content-Type: application/json'

  {}
  # This is undefined because no data is imported.
  ```

###  2.4. <a name='RunOPAserverwithloadingdata5min'></a>OPA にデータを読み込ませる (5 min)

  ```sh
  # create data.json
  ```

  ```json
  {
    "rule": "be good"
  }
  ```

  サーバの起動コマンドを以下のように変えて, OPAサーバを再度起動します.

  ```sh
  # add ./data.json to command arguments
  opa run -s ./example.rego ./data.json
  ```

- OPAサーバにリクエストを送信します.
  - `/v1/data/play`

  ```sh
  $ curl localhost:8181/v1/data/play -i -d @input.json -H 'Content-Type: application/json'

  {"result":{"hello":true,"importdata":"Received the static data: be good","newdata":"Received the message: world"}}
  # Field "importdata" was added.
  ```

  このように、読み込んだデータに応じてOPAが処理を変えます.

  - `/v1/data/play/importdata`
  ```sh
  $ curl localhost:8181/v1/data/play/importdata -i -d @input.json -H 'Content-Type: application/json'

  {"result":"Received the static data: be good"}
  # Data was added. Same as the value of "importdata" in section 1.1
  ```

###  2.5. <a name='WhatOPAserverdoes3min'></a>まとめ: OPAができること (所要: 3分)

- OPA サーバが自分の環境で起動でき, HTTPリクエストに応じて処理を実行しました.
  - HTTP リクエストで JSONデータを送信します. 
  - さらにボディは `{"input": ***}`の形式である必要があります.
- OPA サーバは `<server>/v1/api/data/<package name>[/<object name>]` のようなエンドポイントを持ちます.
  - Regoファイルの最初の行 `package play` により, `<package name>` が `play` であることを定義しています.
  - Regoファイルの中のルールの定義 `hello {...}` により, `<object name>` が `hello` であることを定義しています.
- OPAの返り値は, `{"result": ***}`の形式のJSONデータです.
  - 返り値の中身は, アクセスするエンドポイントによって変わります.
    - もし `<package name>` がリクエストされると, 返り値は `"result"` フィールドに全部の値を含みます.
    - もし `<package name>/<object name>` がリクエストされると, 返り値は `"result"` フィールドに指定されたオブジェクト = ルールの結果が含まれます.

##  3. <a name='Reference'></a>参考資料

- Rego Playground: https://play.openpolicyagent.org/
- Github `OPA` repository: https://github.com/open-policy-agent/opa
