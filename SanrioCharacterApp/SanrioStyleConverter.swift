//
//  SanrioStyleConverter.swift
//  SanrioCharacterApp
//
//  Created by Developer on 2024.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum SanrioTheme {
    case helloKitty
    case myMelody
    case cinnamoroll
    case kuromi
    case pompompurin
    case random
}

class SanrioStyleConverter {
    private let context = CIContext()
    
    func convertToSanrioStyle(_ inputImage: UIImage) -> UIImage {
        // Simulate processing time for realistic feel
        Thread.sleep(forTimeInterval: 2.0)
        
        guard let ciImage = CIImage(image: inputImage) else {
            return createSanrioCharacter(from: inputImage)
        }
        
        // Apply various filters to create a Sanrio-like effect
        let processedImage = applySanrioFilters(to: ciImage)
        
        // Convert back to UIImage
        if let cgImage = context.createCGImage(processedImage, from: processedImage.extent) {
            let filteredImage = UIImage(cgImage: cgImage)
            return addSanrioElements(to: filteredImage)
        }
        
        return createSanrioCharacter(from: inputImage)
    }
    
    private func applySanrioFilters(to image: CIImage) -> CIImage {
        var currentImage = image
        
        // 1. Brighten and add warmth
        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = currentImage
        colorControls.brightness = 0.3
        colorControls.saturation = 1.4
        colorControls.contrast = 1.2
        currentImage = colorControls.outputImage ?? currentImage
        
        // 2. Add a soft, dreamy effect
        let gaussianBlur = CIFilter.gaussianBlur()
        gaussianBlur.inputImage = currentImage
        gaussianBlur.radius = 0.8
        let blurredImage = gaussianBlur.outputImage ?? currentImage
        
        // Blend original with slightly blurred version for soft look
        let sourceOverCompositing = CIFilter.sourceOverCompositing()
        sourceOverCompositing.inputImage = currentImage
        sourceOverCompositing.backgroundImage = blurredImage
        currentImage = sourceOverCompositing.outputImage ?? currentImage
        
        // 3. Add a pink/kawaii tint
        let colorMatrix = CIFilter.colorMatrix()
        colorMatrix.inputImage = currentImage
        colorMatrix.rVector = CIVector(x: 1.15, y: 0.05, z: 0.1, w: 0)
        colorMatrix.gVector = CIVector(x: 0.05, y: 1.1, z: 0.05, w: 0)
        colorMatrix.bVector = CIVector(x: 0.15, y: 0.05, z: 1.05, w: 0)
        currentImage = colorMatrix.outputImage ?? currentImage
        
        // 4. Add subtle vignette for focus
        let vignette = CIFilter.vignette()
        vignette.inputImage = currentImage
        vignette.intensity = 0.2
        vignette.radius = 1.8
        currentImage = vignette.outputImage ?? currentImage
        
        return currentImage
    }
    
    private func addSanrioElements(to image: UIImage) -> UIImage {
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Draw the processed image
            image.draw(at: .zero)
            
            // Add Sanrio-style decorative elements
            addKawaiiDecorations(context: context.cgContext, size: size)
            addSanrioFrame(context: context.cgContext, size: size)
        }
    }
    
    private func addKawaiiDecorations(context: CGContext, size: CGSize) {
        // Sanrio-style decorations
        let decorations = ["✨", "💖", "🌟", "💕", "⭐", "💫", "🎀", "🌸", "💗", "🌺"]
        let themes = [
            "🎀💖✨", // Hello Kitty theme
            "🐰💕🌸", // My Melody theme
            "☁️💙⭐", // Cinnamoroll theme
            "🖤💜🌙", // Kuromi theme
            "🍮💛🌟"  // Pompompurin theme
        ]
        
        let selectedTheme = themes.randomElement() ?? themes[0]
        let themeDecorations = selectedTheme.map { String($0) } + decorations
        
        // Add decorations around the image
        for i in 0..<12 {
            let decoration = String(themeDecorations.randomElement() ?? "✨")
            let x = CGFloat.random(in: size.width * 0.05...size.width * 0.95)
            let y = CGFloat.random(in: size.height * 0.05...size.height * 0.95)
            
            // Avoid center area where face might be
            let centerX = size.width / 2
            let centerY = size.height / 2
            let distanceFromCenter = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2))
            
            if distanceFromCenter < min(size.width, size.height) * 0.3 {
                continue // Skip decorations too close to center
            }
            
            let fontSize = CGFloat.random(in: 16...28)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: UIColor.systemPink.withAlphaComponent(CGFloat.random(in: 0.6...0.9))
            ]
            
            let attributedString = NSAttributedString(string: decoration, attributes: attributes)
            let textSize = attributedString.size()
            
            context.saveGState()
            context.translateBy(x: x, y: y)
            context.rotate(by: CGFloat.random(in: -0.2...0.2))
            
            attributedString.draw(at: CGPoint(x: -textSize.width/2, y: -textSize.height/2))
            context.restoreGState()
        }
    }
    
    private func addSanrioFrame(context: CGContext, size: CGSize) {
        // Add a cute border frame
        let borderWidth: CGFloat = 8
        let cornerRadius: CGFloat = 20
        
        // Create rounded rectangle path
        let rect = CGRect(x: borderWidth/2, y: borderWidth/2, 
                         width: size.width - borderWidth, height: size.height - borderWidth)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        // Set up gradient colors for the frame
        context.saveGState()
        context.setLineWidth(borderWidth)
        
        // Create gradient stroke effect
        let colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                colors: colors as CFArray,
                                locations: [0.0, 1.0])!
        
        context.addPath(path.cgPath)
        context.replacePathWithStrokedPath()
        context.clip()
        
        context.drawLinearGradient(gradient,
                                 start: CGPoint(x: 0, y: 0),
                                 end: CGPoint(x: size.width, y: size.height),
                                 options: [])
        
        context.restoreGState()
    }
    
    private func createSanrioCharacter(from image: UIImage) -> UIImage {
        // Fallback: Create a stylized version with Sanrio-themed overlays
        let size = CGSize(width: 500, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Draw kawaii background gradient
            let colors = [
                UIColor.systemPink.withAlphaComponent(0.2).cgColor,
                UIColor.systemPurple.withAlphaComponent(0.1).cgColor,
                UIColor.systemBlue.withAlphaComponent(0.1).cgColor
            ]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors as CFArray,
                                    locations: [0.0, 0.5, 1.0])!
            
            context.cgContext.drawRadialGradient(gradient,
                                               startCenter: CGPoint(x: size.width/2, y: size.height/2),
                                               startRadius: 0,
                                               endCenter: CGPoint(x: size.width/2, y: size.height/2),
                                               endRadius: size.width/2,
                                               options: [])
            
            // Draw resized original image with rounded corners
            let imageRect = CGRect(x: 50, y: 80, width: 400, height: 400)
            let path = UIBezierPath(roundedRect: imageRect, cornerRadius: 25)
            context.cgContext.addPath(path.cgPath)
            context.cgContext.clip()
            
            image.draw(in: imageRect)
            
            // Reset clipping
            context.cgContext.resetClip()
            
            // Add kawaii decorative frame
            context.cgContext.setStrokeColor(UIColor.systemPink.cgColor)
            context.cgContext.setLineWidth(6)
            context.cgContext.addPath(path.cgPath)
            context.cgContext.strokePath()
            
            // Add title text
            let title = "Kawaii Character! 🎀✨"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.systemPink,
                .strokeColor: UIColor.white,
                .strokeWidth: -2
            ]
            
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            let titleSize = titleString.size()
            titleString.draw(at: CGPoint(x: (size.width - titleSize.width) / 2, y: 20))
            
            // Add decorative elements around the frame
            addKawaiiDecorations(context: context.cgContext, size: size)
        }
    }
    
    // Character-specific styling methods
    func createHelloKittyStyle(_ image: UIImage) -> UIImage {
        return addCharacterTheme(to: image, theme: .helloKitty)
    }
    
    func createMyMelodyStyle(_ image: UIImage) -> UIImage {
        return addCharacterTheme(to: image, theme: .myMelody)
    }
    
    func createCinnamorollStyle(_ image: UIImage) -> UIImage {
        return addCharacterTheme(to: image, theme: .cinnamoroll)
    }
    
    private func addCharacterTheme(to image: UIImage, theme: SanrioTheme) -> UIImage {
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Draw original image
            image.draw(at: .zero)
            
            // Add theme-specific elements
            switch theme {
            case .helloKitty:
                addHelloKittyElements(context: context.cgContext, size: size)
            case .myMelody:
                addMyMelodyElements(context: context.cgContext, size: size)
            case .cinnamoroll:
                addCinnamorollElements(context: context.cgContext, size: size)
            case .kuromi:
                addKuromiElements(context: context.cgContext, size: size)
            case .pompompurin:
                addPompompurinElements(context: context.cgContext, size: size)
            case .random:
                addKawaiiDecorations(context: context.cgContext, size: size)
            }
        }
    }
    
    private func addHelloKittyElements(context: CGContext, size: CGSize) {
        let decorations = ["🎀", "💖", "✨", "🌸"]
        addThemeDecorations(context: context, size: size, decorations: decorations, color: .systemPink)
    }
    
    private func addMyMelodyElements(context: CGContext, size: CGSize) {
        let decorations = ["🐰", "💕", "🌸", "🎀"]
        addThemeDecorations(context: context, size: size, decorations: decorations, color: .systemPink)
    }
    
    private func addCinnamorollElements(context: CGContext, size: CGSize) {
        let decorations = ["☁️", "💙", "⭐", "✨"]
        addThemeDecorations(context: context, size: size, decorations: decorations, color: .systemBlue)
    }
    
    private func addKuromiElements(context: CGContext, size: CGSize) {
        let decorations = ["🖤", "💜", "🌙", "⭐"]
        addThemeDecorations(context: context, size: size, decorations: decorations, color: .systemPurple)
    }
    
    private func addPompompurinElements(context: CGContext, size: CGSize) {
        let decorations = ["🍮", "💛", "🌟", "☀️"]
        addThemeDecorations(context: context, size: size, decorations: decorations, color: .systemYellow)
    }
    
    private func addThemeDecorations(context: CGContext, size: CGSize, decorations: [String], color: UIColor) {
        for i in 0..<8 {
            let decoration = decorations[i % decorations.count]
            let x = CGFloat.random(in: size.width * 0.1...size.width * 0.9)
            let y = CGFloat.random(in: size.height * 0.1...size.height * 0.9)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: CGFloat.random(in: 20...32)),
                .foregroundColor: color.withAlphaComponent(0.8)
            ]
            
            let attributedString = NSAttributedString(string: decoration, attributes: attributes)
            let textSize = attributedString.size()
            
            context.saveGState()
            context.translateBy(x: x, y: y)
            context.rotate(by: CGFloat.random(in: -0.3...0.3))
            
            attributedString.draw(at: CGPoint(x: -textSize.width/2, y: -textSize.height/2))
            context.restoreGState()
        }
    }
} 