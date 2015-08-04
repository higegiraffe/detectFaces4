//
//  detectFaces.swift
//  detectFaces4
//
//  Created by yuki on 2015/08/02.
//  Copyright (c) 2015年 higegiraffe. All rights reserved.
//

import UIKit
import CoreImage

class detectFaces {

    class func recognizeFace(image: UIImage) -> (faces: NSArray , transform: CGAffineTransform) {

        // NSDictionary型のoptionを生成。顔認識の精度を追加する.
        var options : NSDictionary = [CIDetectorSmile : true, CIDetectorEyeBlink : true]
    
        // CIDetectorを生成。顔認識をするのでTypeはCIDetectorTypeFace.
        let detector : CIDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    
        var outputImage :CIImage = CIImage(image: image)
        
        // detectorで認識した顔のデータを入れておくNSArray.
        var faces : NSArray = detector.featuresInImage(outputImage, options: options as [NSObject : AnyObject])
    
       // UIKitは画面左上に原点があるが、CoreImageは画面左下に原点があるのでそれを揃えなくてはならない.
       // CoreImageとUIKitの原点を画面左上に統一する処理.
       var transform : CGAffineTransform = CGAffineTransformMakeScale(1, -1)
//       transform = CGAffineTransformTranslate(transform, 0, -self.imageView.bounds.size.height)
       transform = CGAffineTransformTranslate(transform, 0, -UIScreen.mainScreen().bounds.size.height)
        
/*
       // 検出された顔のデータをCIFaceFeatureで処理.
       var feature : CIFaceFeature = CIFaceFeature()
       for feature in faces {
    
       // 座標変換.
       let faceRect : CGRect = CGRectApplyAffineTransform(feature.bounds, transform)
    
       // 画像の顔の周りを線で囲うUIViewを生成.
       var faceOutline = UIView(frame: faceRect)
       faceOutline.layer.borderWidth = 1
       faceOutline.layer.borderColor = UIColor.redColor().CGColor
       self.imageView.addSubview(faceOutline)
       }
*/
       return (faces,transform)
        
    }

}