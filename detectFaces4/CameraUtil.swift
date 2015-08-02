//
//  CameraUtil.swift
//  detectFaces4
//
//  Created by yuki on 2015/07/30.
//  Copyright (c) 2015年 higegiraffe. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraUtil {
    
    // sampleBufferからUIImageへ変換
    class func imageFromSampleBuffer(sampleBuffer: CMSampleBufferRef) -> UIImage {
        let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // ベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        // 画像データの情報を取得
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        // RGB色空間を作成
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        // Bitmap graphic contextを作成
        let bitsPerCompornent: UInt = 8
        var bitmapInfo = CGBitmapInfo((CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue) as UInt32)
        let Context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)
        
        // Quartz imageを作成
        let imageRef = CGBitmapContextCreateImage(Context)
        
        // ベースアドレスをアンロック
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
        
        // UIImageを作成
        let resultImage: UIImage = UIImage(CGImage: imageRef)!
        
        return resultImage
    }
    
}
