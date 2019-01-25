# Face Auth - iOS

カメラ画像から顔検出を行い、検出された顔を認識し名前、認識率を表示するアプリケーション


## 顔認識のために利用しているiOSのFrameworkについて

### [Vision](https://developer.apple.com/documentation/vision)  
iOS11から追加された画像認識APIを提供するフレームワーク  
同じくiOS11から追加された機械学習フレームワークのCore MLを抽象化  
(VisionのバックグラウンドではCore MLが利用されている)  

* 認識できるもの  

    機械学習モデルの用意が不要なもの  
    * 顔検出 / Face Detection and Recognition  
    * バーコード検出 / Barcode Detection  
    * 画像の位置合わせ / Image Alignment Analysis  
    * テキスト検出 / Text Detection  
    * 水平線検出 / Horizon Detection  
    * 矩形検出 / Rectangle Detection  

    機械学習モデルの用意が必要なもの  
    * オブジェクト検出とトラッキング / Object Detection and Tracking  
    * 機械学習による画像分析 / Machine Learning Image Analysis  
    ※ 配布されている機械学習モデル https://developer.apple.com/machine-learning/

* Vision.frameworkで利用する主なクラス
  - VNCoreMLModel（組み込んだモデル）  
    CoreMLのモデルをVisionで扱うためのコンテナクラス
  - VNCoreMLRequest（画像認識のリクエスト）
    CoreMLに画像認識を要求するためのクラス。認識結果はモデルの出力形式により決まる。  
    - 画像→クラス（分類結果）
    - 画像→特徴量
    - 画像→画像
  - VNImageRequestHandler（リクエストの実行）
    一つの画像に対し、一つ以上の画像認識処理（VNCoreMLRequest）を実行するためのクラス
    初期化時に認識対象の画像形式を指定する
    - CVPixelBuffer
    - CIImage
    - CGImage
  - VNObservation（認識結果）
  画像認識結果の抽象クラス
  顔検出
  VNFaceObservation
  顔ランドマーク検出
  VNFaceObservation
  画像レジストレーション
  VNImageAlignmentObservation
  矩形検出
  VNRectangleObservation
  バーコード検出
  VNBarcodeObservation
  テキスト検出
  VNTextObservation
  オブジェクトトラッキング
  VNDetectedObjectObservation
  結果としてこのクラスのサブクラスのいずれかが返される
    VNClassificationObservation 分類名としてidentifierプロパティを持つ
    VNCoreMLFeatureValueObservation 特徴量データとしてfeatureValueプロパティを持つ
    VNPixelBufferObservation 画像データとしてpixelBufferプロパティを持つ
  認識の確信度を表すconfidenceプロパティを持つ（VNConfidence=Floatのエイリアス）

実装の流れ
1. Requestを生成する
2. 画像データを渡しRequestHandlerを生成する
3. RequestHandlerにRequestを渡し、解析処理を実行する
4. Observationから観測結果を得る
