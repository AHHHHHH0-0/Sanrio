//
//  ContentView.swift
//  SanrioCharacterApp
//
//  Created by Andrew Liu on 6/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var sanrioCharacter: UIImage?
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Title
                VStack {
                    Text("📸✨ Sanrio Me! ✨📸")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    Text("Turn your photo into a cute Sanrio character!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                // Main Content Area
                if let sanrioCharacter = sanrioCharacter {
                    // Show generated Sanrio character
                    VStack(spacing: 20) {
                        Text("Your Sanrio Character! 🎀")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.pink)
                        
                        Image(uiImage: sanrioCharacter)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300, maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .pink.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        HStack(spacing: 15) {
                            Button("Save Photo 💾") {
                                saveImageToPhotos(sanrioCharacter)
                            }
                            .buttonStyle(SanrioButtonStyle(color: .blue))
                            
                            Button("Create Another! 🌟") {
                                resetApp()
                            }
                            .buttonStyle(SanrioButtonStyle(color: .pink))
                        }
                    }
                } else if let capturedImage = capturedImage {
                    // Show captured image and processing
                    VStack(spacing: 20) {
                        if isProcessing {
                            VStack(spacing: 15) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.pink)
                                
                                Text("Creating your Sanrio character...")
                                    .font(.headline)
                                    .foregroundColor(.pink)
                                
                                Text("✨ Adding kawaii magic ✨")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.pink.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        } else {
                            Text("Your Photo 📷")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.pink)
                            
                            Image(uiImage: capturedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 250, maxHeight: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 5)
                        }
                    }
                } else {
                    // Initial state - show camera button
                    VStack(spacing: 25) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.pink)
                        
                        Text("Tap to take a photo and create your Sanrio character!")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Camera Button (always visible unless processing)
                if !isProcessing {
                    Button(action: {
                        showingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text(capturedImage == nil ? "Take Photo" : "Take New Photo")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.pink, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .pink.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(capturedImage == nil ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: capturedImage)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.pink.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                capturedImage = image
                processImageToSanrioStyle(image)
            }
        }
    }
    
    private func processImageToSanrioStyle(_ image: UIImage) {
        isProcessing = true
        
        // Process image to Sanrio style
        DispatchQueue.global(qos: .userInitiated).async {
            let converter = SanrioStyleConverter()
            let processedImage = converter.convertToSanrioStyle(image)
            
            DispatchQueue.main.async {
                self.sanrioCharacter = processedImage
                self.isProcessing = false
            }
        }
    }
    
    private func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    private func resetApp() {
        capturedImage = nil
        sanrioCharacter = nil
        isProcessing = false
    }
    
    private func testSanrioConverter() {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        let testImage = renderer.image { context in
            UIColor.systemPink.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let text = "Test Photo 📸"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white
            ]
            text.draw(at: CGPoint(x: 80, y: 140), withAttributes: attrs)
        }
        
        capturedImage = testImage
        processImageToSanrioStyle(testImage)
    }
}

struct SanrioButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = .pink) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
