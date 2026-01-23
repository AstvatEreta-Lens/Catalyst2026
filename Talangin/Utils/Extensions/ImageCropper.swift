//
//  ImageCropper.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 18/01/26.
//

import UIKit
import Vision

extension UIImage {
    
    func crop(to normalizedRect: CGRect) -> UIImage? {
        
        // 1. Standarisasi Orientasi Gambar
        guard let fixedImage = self.fixedOrientation(),
              let cgImage = fixedImage.cgImage else {
            return nil
        }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        // 2. Konversi Koordinat Vision (Bottom-Left) ke CoreGraphics (Top-Left)
        
        let x = normalizedRect.minX * width
        let w = normalizedRect.width * width
        let h = normalizedRect.height * height
        
        // Y = (1 - Y_Max_Vision) * Tinggi_Gambar
        let y = (1 - normalizedRect.maxY) * height
        
        let cropRect = CGRect(x: x, y: y, width: w, height: h)
        
        // 3. Validasi Batas (Clamping)
        let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
        let safeCropRect = cropRect.intersection(imageRect)
        
        if safeCropRect.isNull || safeCropRect.isEmpty {
            return nil
        }
        
        // 4. Lakukan Cropping
        guard let croppedCGImage = cgImage.cropping(to: safeCropRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage)
    }
    
    func fixedOrientation() -> UIImage? {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}
