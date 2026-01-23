//
//  CameraView.swift
//  Talangin
//
//  Created by Rifqi Rahman on 19/01/26.
//
//  Camera view component using AVFoundation for SwiftUI.
//  Provides camera interface for taking profile photos using AVCaptureSession.
//
//  BACKEND DEVELOPER NOTES:
//  -------------------------
//  Camera Access:
//  - Requires NSCameraUsageDescription in Info.plist
//  - Handles camera permissions and errors gracefully
//  - Captures photos and returns as Data (JPEG format)
//

import SwiftUI
@preconcurrency import AVFoundation
import Combine

struct CameraView: View {
    @Binding var isPresented: Bool
    let onPhotoTaken: (Data) -> Void
    
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if cameraManager.isAuthorized {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    HStack(spacing: AppSpacing.xl) {
                        // Cancel Button
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Capture Button
                        Button {
                            cameraManager.capturePhoto { imageData in
                                if let imageData = imageData {
                                    onPhotoTaken(imageData)
                                    isPresented = false
                                }
                            }
                        } label: {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                        .frame(width: 60, height: 60)
                                )
                        }
                        
                        Spacer()
                        
                        // Placeholder for symmetry
                        Color.clear
                            .frame(width: 60, height: 60)
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xl)
                }
            } else {
                VStack(spacing: AppSpacing.lg) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Camera Access Required")
                        .font(.Headline)
                        .foregroundColor(.white)
                    
                    Text("Please enable camera access in Settings to take photos.")
                        .font(.Body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                    
                    Button {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    } label: {
                        Text("Open Settings")
                            .font(.Body)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.horizontal, AppSpacing.xl)
                            .padding(.vertical, AppSpacing.md)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, AppSpacing.md)
                    
                    Button {
                        isPresented = false
                    } label: {
                        Text("Cancel")
                            .font(.Body)
                            .foregroundColor(.white)
                    }
                    .padding(.top, AppSpacing.sm)
                }
            }
        }
        .onAppear {
            cameraManager.requestPermission()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}

// MARK: - Camera Preview

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Camera Manager

@MainActor
class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    
    nonisolated(unsafe) let session = AVCaptureSession()
    nonisolated(unsafe) private var photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((Data?) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    func requestPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    self.isAuthorized = granted
                    if granted {
                        self.startSession()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }
    
    private func setupSession() {
        // Setup session on background queue since it's nonisolated
        // Note: AVCaptureSession is thread-safe and designed for background queue usage
        performSessionSetup(session: session, photoOutput: photoOutput)
    }
    
    // Nonisolated helper to avoid Sendable requirements
    nonisolated private func performSessionSetup(session: AVCaptureSession, photoOutput: AVCapturePhotoOutput) {
        DispatchQueue.global(qos: .userInitiated).async {
            session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) ?? 
                              AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input),
                  session.canAddOutput(photoOutput) else {
                session.commitConfiguration()
                return
            }
            
            session.addInput(input)
            session.addOutput(photoOutput)
            session.commitConfiguration()
        }
    }
    
    func startSession() {
        if !session.isRunning {
            // Note: AVCaptureSession is thread-safe and designed for background queue usage
            performStartSession(session: session)
        }
    }
    
    // Nonisolated helper to avoid Sendable requirements
    nonisolated private func performStartSession(session: AVCaptureSession) {
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if session.isRunning {
            // Note: AVCaptureSession is thread-safe and designed for background queue usage
            performStopSession(session: session)
        }
    }
    
    // Nonisolated helper to avoid Sendable requirements
    nonisolated private func performStopSession(session: AVCaptureSession) {
        DispatchQueue.global(qos: .userInitiated).async {
            session.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (Data?) -> Void) {
        captureCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        // Note: format is read-only, but photoOutput will use JPEG by default
        // if available. The delegate will receive the photo data which we'll
        // compress as JPEG in the delegate method.
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation() else {
            captureCompletion?(nil)
            return
        }
        
        // Compress the image
        if let image = UIImage(data: imageData),
           let compressedData = image.jpegData(compressionQuality: 0.8) {
            captureCompletion?(compressedData)
        } else {
            captureCompletion?(imageData)
        }
    }
}
