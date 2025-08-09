import UIKit

extension UIImage {
    /// 이미지를 최대 너비와 높이에 맞게 리사이즈합니다.
    /// - Parameters:
    ///   - maxWidth: 최대 너비 (픽셀)
    ///   - maxHeight: 최대 높이 (픽셀)
    /// - Returns: 리사이즈된 이미지. 원본이 제한 크기보다 작으면 원본 그대로 반환
    func resize(maxWidth: Int, maxHeight: Int) -> UIImage {
        let maxWidthCG = CGFloat(maxWidth)
        let maxHeightCG = CGFloat(maxHeight)
        
        // 현재 이미지 크기
        let currentWidth = self.size.width * self.scale
        let currentHeight = self.size.height * self.scale
        
        // 이미지가 이미 제한 크기보다 작으면 그대로 반환
        if currentWidth <= maxWidthCG && currentHeight <= maxHeightCG {
            return self
        }
        
        // 축소 비율 계산 (aspect ratio 유지)
        let widthRatio = maxWidthCG / currentWidth
        let heightRatio = maxHeightCG / currentHeight
        let scaleFactor = min(widthRatio, heightRatio)
        
        // 새로운 크기 계산
        let newWidth = currentWidth * scaleFactor
        let newHeight = currentHeight * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // 고품질 리사이징을 위한 UIGraphicsImageRenderer 사용
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        let resizedImage = renderer.image { context in
            // 고품질 렌더링 옵션 설정
            context.cgContext.interpolationQuality = .high
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    /// 이미지를 최대 너비와 높이에 맞게 리사이즈하고, 추가 옵션을 제공합니다.
    /// - Parameters:
    ///   - maxWidth: 최대 너비 (픽셀)
    ///   - maxHeight: 최대 높이 (픽셀)
    ///   - compressionQuality: JPEG 압축 품질 (0.0~1.0, nil이면 압축하지 않음)
    /// - Returns: 리사이즈된 이미지
    func resize(maxWidth: Int, maxHeight: Int, compressionQuality: CGFloat? = nil) -> UIImage {
        let resizedImage = resize(maxWidth: maxWidth, maxHeight: maxHeight)
        
        // 압축이 필요한 경우
        if let quality = compressionQuality,
           let imageData = resizedImage.jpegData(compressionQuality: quality),
           let compressedImage = UIImage(data: imageData) {
            return compressedImage
        }
        
        return resizedImage
    }
    
    /// 이미지의 실제 픽셀 크기를 반환합니다.
    var pixelSize: CGSize {
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
}