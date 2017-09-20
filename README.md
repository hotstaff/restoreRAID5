# restoreRAID5

Buffalo製RAID5対応外付けハードディスクHD-QS2.0TSU2/R5から取り出したHDDを直接読み込んでアレイデータを復旧するためのPerlスクリプト

## 説明

・故障したHDDを除く３台のHDDからパリティを計算してアレイのイメージを作ります。
・ハードウェアRAID側の故障で動かせない場合の復旧にも使えます。

## 対象とするハードウェアのアレイ情報
- 4本構成 SATA
- RAID5
- HardRaid
- ストライプサイズ: 1セクタ(512バイト)
- Layout: Left-Asymmetric
＜注意＞構造が違う場合はそのまま実行できません。ソースコードの修正が必要です。

## 対応可能な機種
-Buffalo HD-QSSU2/R5シリーズ
-- HD-QS6.0TSU2/R5
-- HD-QS4.0TSU2/R5 
-- HD-QS3.0TSU2/R5
-- HD-QS2.0TSU2/R5 （動作確認はこれのみ実施）
-- HD-QS1.0TSU2/R5

## 必須

- Perl
- Linux

## 使い方
- スクリプト本体をご覧ください

## その他
- HDDを直接読んで書き込むことも出来ますが、故障が疑われるHDDの場合一旦ddresqueなどで先に安全なHDDへコピーして作業をすることをおすすめします。
- ストライプ長についてはスクリプトの編集で対応可能です。
- 参考元のプログラムと基本的に動作内容は同じです。どのような動作をしているのかには下の素晴らしい参考元をご覧ください。
- 単純なスクリプトなので少し変えれば他のものにも対応出来ると思います。

## 参考元
- [参考元1（プログラム）](http://www.maniac.ne.jp/~maniac/weblog/archives/2009/06/raid5.html)
- [参考元2（アレイ情報）](http://3309masa.blog130.fc2.com/blog-category-4.html)

## ライセンス
[MIT](http://b4b4r07.mit-license.org)
