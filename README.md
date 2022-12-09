# 沖縄県河川情報データサンプル

本リポジトリは沖縄県河川情報システムが公開している河川の水位と雨量のデータを検証用に加工し蓄積しています。

## データの種類

| データの種類 | 説明 | データ構造 |
| -- | -- | -- |
| 水位データ ([waterLevels.json](https://github.com/OkinawaOpenLaboratory/OkinawaRiverDataSample/blob/main/waterLevels.json)) | 10分毎の水位情報に観測所情報を付加した過去90日分のJSONデータ | timestamp (観測時刻)<br>sno (観測所番号)<br>kind (データ種別)<br>cam (カメラ番号)<br>area (地域)<br>stn (観測所名)<br>rgrp (水系名)<br>ksn (河川名)<br>offc (管理者名)<br>lat (緯度)<br>lon (経度)<br>alm (アラーム)<br>waterLevel (水位) |
| 雨量データ ([rains.json](https://github.com/OkinawaOpenLaboratory/OkinawaRiverDataSample/blob/main/rains.json)) | 10分毎の雨量情報に観測所情報を付加した過去90日分のJSONデータ | timestamp (観測時刻)<br>sno (観測所番号)<br>kind (データ種別)<br>area (地域)<br>stn (観測所名)<br>rgrp (水系名)<br>ksn (河川名)<br>offc (管理者名)<br>lat (緯度)<br>lon (経度)<br>rain (雨量) |


## 当リポジトリのデータ利用にあたっての注意

2022年12月3日から蓄積を開始しているため、90日分のデータに満たない可能性があります。

本リポジトリのデータの利用においては、出典元と沖縄オープンラボラトリではコンテンツを用いて行う一切の行為に対して責任を負うものではありません。

出典：沖縄県河川情報システム (http://www.bousai.okinawa.jp/river/kasen/)
