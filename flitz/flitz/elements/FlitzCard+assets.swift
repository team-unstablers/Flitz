//
//  FlitzCard+assets.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//

extension Flitz.Card {
    
    /**
     카드 내의 모든 이미지 에셋을 수집합니다.
     */
    func collectImageAssets() -> Set<Flitz.ImageSource> {
        var assets: Set<Flitz.ImageSource> = []
        
        if let background = self.background {
            assets.insert(background)
        }
        
        for element in self.elements {
            switch element {
            case let text as Flitz.Text:
                break
            case let image as Flitz.Image:
                assets.insert(image.source)
            default:
                break
            }
        }
        
        return assets
    }
    
    
    /**
     카드 내의 모든 에셋이 서버에 업로드되어, 최종적으로 공개가 가능한 상태인지 확인합니다.
     */
    var isReadyToPublish: Bool {
        let imageAssets = self.collectImageAssets()
        
        if (imageAssets.contains { $0.isLocal }) {
            return false
        }
        
        return true
    }
}
