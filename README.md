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
    * 29行目でブラックリスト（[blacklist](/blacklist)）を読み込む
    * 30, 31行目でブロックする曜日・時間を設定
        * S	日曜日
        * M	月曜日
        * T	火曜日
        * W	水曜日
        * H	木曜日
        * F	金曜日
        * A	土曜日
    * 32, 33行目でブロックリストと曜日・時間設定を紐付け
    ```bash
    28   # ブラックリストに登録されているポートを拒否
    29   acl blacklist dstdomain "/etc/squid/blacklist"
    30   acl blacktime time SMTWHFA 00:00-20:00
    31   acl blacktime2 time SMTWHFA 22:30-23:59
    32   http_access deny blacklist blacktime
    33   http_access deny blacklist blacktime2
    ```
* `/etc/squid/squid.conf`<br>
    * ブラックリストとする特定サイトを指定
    * 先頭に . をつけるとサブドメインを含めすべてブロックすることになる
    ```bash
    3   .youtube.com
    4   .twitter.com
    5   .facebook.com
    6   .instagram.com
    ```

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
