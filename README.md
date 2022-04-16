# proxy-blacklist-raspberrypi
Raspberry Piをプロキシサーバーにして、特定のサイト・曜日・時間におけるアクセスをブロックする。

## Raspberry Piの設定
### ◇ Raspberry PiのIPアドレスを固定にする
* [Raspberry Pi のIPアドレスを固定にするには？](https://www.fabshop.jp/raspberry-pi-static-ip/)

### ◇ Squidのインストール
```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install squid -y
```

### ◇ Squidの設定
1. 設定ファイルの権限変更
    ```bash
    $ sudo chmod 777 /etc/squid/squid.conf
    ```
2. `/etc/squid/squid.conf`を編集<br>
    ⇒ [squid.conf](/squid.conf)
3. `/etc/squid/blacklist`を作成<br>
    ⇒ [blacklist](/blacklist)

#### 設定内容の説明
* `/etc/squid/squid.conf`<br>
    ```bash
    26  # ブラックリストに登録されているポートを拒否
    27  acl blacklist dstdomain "/etc/squid/blacklist"
    28  acl blacktime time SMTWHFA 00:00-20:00
    29  acl blacktime2 time SMTWHFA 22:30-23:59
    30  http_access deny blacklist blacktime
    31  http_access deny blacklist blacktime2
    ```
    * 27行目でブラックリスト（[blacklist](/blacklist)）を読み込む
    * 28, 29行目でブロックする曜日・時間を設定
        * S	日曜日
        * M	月曜日
        * T	火曜日
        * W	水曜日
        * H	木曜日
        * F	金曜日
        * A	土曜日
    * 30, 31行目でブロックリストと曜日・時間設定を紐付け
* `/etc/squid/squid.conf`<br>
    ```bash
    1  .youtube.com
    2  .twitter.com
    3  .facebook.com
    4  .instagram.com
    ```
    * ブラックリストとする特定サイトを指定
    * 先頭に . をつけるとサブドメインを含めすべてブロックすることになる
### ◇ 自動起動設定と設定ファイルの反映
```bash
$ sudo systemctl enable squid.service
$ sudo systemctl restart squid.service
```

## iPhoneのプロキシ利用設定
* [iPhoneでWi-Fiの接続時にプロキシを使うよう設定する方法](https://novlog.me/ios/proxy/)<br>
    * サーバ：Raspberry Pi固定IP
    * ポート：3128（[squid.conf](/squid.conf) に記載）

## 参考
* [【ラズベリーパイ4】Squidでプロキシサーバを自作する方法](https://algorithm.joho.info/raspberry-pi/squid-raspberry-pi/)
* [Raspberry PiをHTTP/HTTPSプロキシサーバーにしてみた](https://qiita.com/mascii/items/400a0ecab61d885ac2a8)
* [Web プロキシサーバ Squid を利用して、特定のサイト・時間帯・曜日にアクセスできないようにする](https://zenn.dev/noraworld/articles/access-restriction-using-squid)
