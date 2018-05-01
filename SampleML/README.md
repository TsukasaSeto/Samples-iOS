# Sample ML Application

CoreMLのサンプルアプリケーション

* Xcode 9.3
* iOS 11.3

## 開発メモ  

* Info.plistに Privacy - Camera Usage Description を追加

[学習済みモデル](https://developer.apple.com/machine-learning/):
* ResNet50 Microsoft
* Inception v3 Google

特徴:
* 外部の学習済みモデルを２次利用できる
* Vision 画像認識ができる
* Natural Langauge Processing 自然言語処理ができる

CoreMLとVisionフレームワークいよる推定処理の流れ

```
// モデルを定義
let model = VNCoreMLMode(for: Resnet50().model)

// リクエストを生成
let request = VNCoreMLRequest(model: model)

// リクエストハンドラを生成
let imageHandler = VNImageRequestHandler(ciImage: ciImage)

// ハンドラでリクエストを実行
imageHandler.perform([request])
```
