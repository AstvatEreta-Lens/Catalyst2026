//
//  CameraCaptureView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 27/01/26.
//
//  Camera capture using AVFoundation with SwiftUI wrapper.
//  More SwiftUI-native than UIImagePickerController, though still requires UIViewRepresentable for preview layer.
//

import SwiftUI
import AVFoundation

/// Camera capture view using AVFoundation.
/// NOTE: Still requires UIViewRepresentable for AVCaptureVideoPreviewLayer,
/// but uses AVFoundation instead of UIImagePickerController for more control.
struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        let parent: CameraCaptureView
        
        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }
        
        func cameraViewController(_ controller: CameraViewController, didCaptureImage imageData: Data) {
            parent.imageData = imageData
            parent.dismiss()
        }
        
        func cameraViewControllerDidCancel(_ controller: CameraViewController) {
            parent.dismiss()
        }
    }
}

// MARK: - Camera View Controller
/// Camera view controller using AVFoundation
/// NOTE: This still uses UIKit (UIViewController) because AVFoundation requires UIView for preview layer.
/// However, it's more SwiftUI-friendly than UIImagePickerController and gives us more control.
protocol CameraViewControllerDelegate: AnyObject {
    func cameraViewController(_ controller: CameraViewController, didCaptureImage imageData: Data)
    func cameraViewControllerDidCancel(_ controller: CameraViewController)
}

class CameraViewController: UIViewController {
    weak var delegate: CameraViewControllerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    private func setupCamera() {
        // Check camera authorization
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            configureCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if granted {
                        self.configureCaptureSession()
                    } else {
                        self.delegate?.cameraViewControllerDidCancel(self)
                    }
                }
            }
        default:
            delegate?.cameraViewControllerDidCancel(self)
        }
    }
    
    private func configureCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            delegate?.cameraViewControllerDidCancel(self)
            return
        }
        
        session.addInput(input)
        
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            photoOutput = output
        }
        
        captureSession = session
        
        // Setup preview layer
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        previewLayer = preview
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Capture button
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        captureButton.backgroundColor = .white
        captureButton.setTitleColor(.black, for: .normal)
        captureButton.layer.cornerRadius = 35
        captureButton.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        // Cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        // Stack view
        let stackView = UIStackView(arrangedSubviews: [cancelButton, captureButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    @objc private func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func cancel() {
        delegate?.cameraViewControllerDidCancel(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ CameraCaptureView: Error capturing photo - \(error.localizedDescription)")
            delegate?.cameraViewControllerDidCancel(self)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("⚠️ CameraCaptureView: No image data available")
            delegate?.cameraViewControllerDidCancel(self)
            return
        }
        
        print("✅ CameraCaptureView: Photo captured successfully (\(imageData.count) bytes)")
        delegate?.cameraViewController(self, didCaptureImage: imageData)
    }
}

// MARK: - Preview
#Preview {
    CameraCaptureView(imageData: .constant(nil))
}
