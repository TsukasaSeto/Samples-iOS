# Sample NFC Application

NFCタグを読み取った内容を表示するサンプルアプリケーション

* Xcode 9.3
* iOS 11.3

## 開発メモ  

* Freeの開発アカウントではCoreNFCが利用できない
* CapabilitiesでNFCをONにする
* Linked Frameworks and Libraries で CoreNFC.frameworkを選択する
* Info.plist で Privacy -NFC Scan Usage Description を追加
* Info.plist で Required device capabilities に nfc を追加
* CoreNFCで読み取ったデータの構造

Messagesの中に複数のmessage
messageの中にRecords
Recordsはtypeとpayloadを持っている
