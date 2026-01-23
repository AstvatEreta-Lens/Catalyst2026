//
//  MLService.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 14/01/26.
//

import Vision
import UIKit
import CoreML

struct DetectedObject: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}

final class ObjectDetectionService {
    
    static let shared = ObjectDetectionService()
    private var detectionRequest: VNCoreMLRequest?
    
    private init() {
        setupModel()
    }
    
    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            let model = try ReceiptScanner(configuration: config)
            
            let visionModel = try VNCoreMLModel(for: model.model)
            
            self.detectionRequest = VNCoreMLRequest(model: visionModel)
            
            self.detectionRequest?.imageCropAndScaleOption = .scaleFill
            
        } catch {
            print("❌ Gagal memuat model CoreML: \(error)")
        }
    }
    
    func detect(image: UIImage, completion: @escaping ([DetectedObject]) -> Void) {
        guard let cgImage = image.cgImage, let request = detectionRequest else {
            completion([])
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    DispatchQueue.main.async { completion([]) }
                    return
                }
                
                let detections = results.map { observation -> DetectedObject in
                    let topLabel = observation.labels.first
                    return DetectedObject(
                        label: topLabel?.identifier ?? "Unknown",
                        confidence: topLabel?.confidence ?? 0,
                        boundingBox: observation.boundingBox
                    )
                }
                
                DispatchQueue.main.async {
                    completion(detections)
                }
                
            } catch {
                print("❌ Error during detection: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
