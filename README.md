# Python 3.10 with Ubuntu 25.04 / 24.04 LTS
Deadsnakeでまだ用意されていないUbuntu 25.04 / 24.04 LTS用のPython 3.10.18を自動でビルドし、システムを破壊しないように、自動で.debを作成してインストールする簡易的なスクリプトです。
手動でsudo make installしたりして後々アンインストール困難になる問題を回避できます。

## 使用方法
```
$ git clone https://github.com/Nyaruke/python3.10-ubuntu-archive-unofficial
$ cd python3.10-ubuntu-archive-unofficial
$ bash auto-build.sh
```

## 既知の問題
- /usr/bin/pip3.10が動作しません。ここからの呼び出しをあまり使うことはないと思いますが、`/usr/bin/python3.10 -m pip`かvenvを作成することでとりあえず対処できます。