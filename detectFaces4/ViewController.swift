//
//  ViewController.swift
//  detectFaces4
//
//  Created by yuki on 2015/07/30.
//  Copyright (c) 2015年 higegiraffe. All rights reserved.
//

import UIKit
import AVFoundation

//var imageView: UIImageView!

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // セッション
    var mySession : AVCaptureSession!
    // カメラデバイス
    var myDevice : AVCaptureDevice!
    // 出力先
    var myOutput : AVCaptureVideoDataOutput!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面の生成
//        initDisplay()
        
        // カメラを準備
        if initCamera() {
            // 撮影開始
            mySession.startRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
/*
    // 画面の生成処理
    func initDisplay() {
        //スクリーンの幅
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        //スクリーンの高さ
        let screenHeight = UIScreen.mainScreen().bounds.size.height;
        
        imageView = UIImageView(frame: CGRectMake(0.0, 0.0, screenWidth, screenHeight))
    }
*/

    // カメラの準備処理
    func initCamera() -> Bool {
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // 解像度の指定.
        mySession.sessionPreset = AVCaptureSessionPresetMedium
        
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // フロントカメラをmyDeviceに格納.
        for device in devices {
            if(device.position == AVCaptureDevicePosition.Front){
                myDevice = device as! AVCaptureDevice
            }
        }
        if myDevice == nil {
            return false
        }
        
        // フロントカメラからVideoInputを取得.
        let myInput = AVCaptureDeviceInput.deviceInputWithDevice(myDevice, error: nil) as! AVCaptureDeviceInput
        
        
        // セッションに追加.
        if mySession.canAddInput(myInput) {
            mySession.addInput(myInput)
        } else {
            return false
        }
        
        // 出力先を設定
        myOutput = AVCaptureVideoDataOutput()
        myOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA ]
        
        // FPSを設定
        var lockError: NSError?
        if myDevice.lockForConfiguration(&lockError) {
            if let error = lockError {
                println("lock error: \(error.localizedDescription)")
                return false
            } else {
                myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
                myDevice.unlockForConfiguration()
            }
        }
        
        // デリゲートを設定
        let queue: dispatch_queue_t = dispatch_queue_create("myqueue",  nil)
        myOutput.setSampleBufferDelegate(self, queue: queue)
        
        
        // 遅れてきたフレームは無視する
        myOutput.alwaysDiscardsLateVideoFrames = true
        
        
        // セッションに追加.
        if mySession.canAddOutput(myOutput) {
            mySession.addOutput(myOutput)
        } else {
            return false
        }
        
        // カメラの向きを合わせる
        for connection in myOutput.connections {
            if let conn = connection as? AVCaptureConnection {
                if conn.supportsVideoOrientation {
                    conn.videoOrientation = AVCaptureVideoOrientation.Portrait
                }
            }
        }
        
        return true
    }
    
    // 毎フレーム実行される処理
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {

        var q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        var q_main: dispatch_queue_t  = dispatch_get_main_queue()
        
        dispatch_async(q_global, {
            dispatch_async(q_main, {
            
            // UIImageへ変換して表示させる
            self.imageView.image = CameraUtil.imageFromSampleBuffer(sampleBuffer)
            
                return
           })

            // UIImageへ変換
//            let image = CameraUtil.imageFromSampleBuffer(sampleBuffer)
            
            // 顔認識
            let detectFace = detectFaces.recognizeFace(self.imageView.image!)
            
            
            dispatch_async(q_main, {
                
                // 検出された顔のデータをCIFaceFeatureで処理.
                var feature : CIFaceFeature = CIFaceFeature()
                for feature in detectFace.faces {
                    
                    // 座標変換.
                    let faceRect : CGRect = CGRectApplyAffineTransform(feature.bounds, detectFace.transform)
                    
                    // 画像の顔の周りを線で囲うUIViewを生成.
                    var faceOutline = UIView(frame: faceRect)
                    faceOutline.layer.borderWidth = 1
                    faceOutline.layer.borderColor = UIColor.redColor().CGColor
                    self.imageView.addSubview(faceOutline)
                }
                
                return
            })
            
            
        })
    }
        
    
}

