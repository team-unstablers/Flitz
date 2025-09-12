//
//  HashtagField.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

import SwiftUI
import UIKit

typealias HashtagArray = [String]

extension HashtagArray {
    
}


struct FZHashtagField: View {
    @Binding
    var hashtags: HashtagArray
    
    @State
    var hashtagString: String = ""
    
    @FocusState
    var isFocused: Bool

    var body: some View {
        TextField(NSLocalizedString("ui.common.hashtag.placeholder", comment: "해시태그를 입력하세요"), text: $hashtagString, axis: .vertical)
            .lineLimit(2...3)
            .font(.fzHeading3)
            .foregroundStyle(Color.blue.opacity(0.8))
            .keyboardType(.twitter)
            .focusable()
            .focused($isFocused)
            .onAppear {
                loadHashtags()
            }
            .onChange(of: hashtags) { _, _ in
                // Update the hashtag string when the hashtags array changes
                loadHashtags()
            }
            .onChange(of: isFocused) { _, newValue in
                print(newValue, hashtagString)
                if (newValue) {
                    if hashtagString.isEmpty {
                        hashtagString = "#"
                    }
                } else {
                    if (hashtagString == "#") {
                        hashtagString = ""
                    }
                    
                    normalizeHashtags()
                }
            }
            .onChange(of: hashtagString) { (prevValue, newValue) in
                if (prevValue.count > hashtagString.count) {
                    if isFocused && hashtagString.isEmpty {
                        hashtagString = "#"
                    }
                    return
                }
                
                if (hashtagString.last == " ") {
                    hashtagString += "#"
                }
            }
    }
    
    func normalizeHashtags() {
        let components = hashtagString
            // remove '#'
            .replacingOccurrences(of: "#", with: "")
            .split(separator: " ")
        
        // normalize each hashtag component
        let normalizedComponents = components.map { component -> String in
            let str = String(component)
            
            // Remove emojis and special characters, keep only:
            // - Letters (any language)
            // - Numbers
            // - Underscore
            let filtered = str.unicodeScalars.filter { scalar in
                // Allow letters and numbers
                if CharacterSet.alphanumerics.contains(scalar) {
                    return true
                }
                // Allow underscore
                if scalar.value == 95 { // underscore
                    return true
                }
                // Reject emojis (most emojis are in these ranges)
                if scalar.value >= 0x1F600 && scalar.value <= 0x1F64F { return false } // Emoticons
                if scalar.value >= 0x1F300 && scalar.value <= 0x1F5FF { return false } // Misc Symbols and Pictographs
                if scalar.value >= 0x1F680 && scalar.value <= 0x1F6FF { return false } // Transport and Map
                if scalar.value >= 0x2600 && scalar.value <= 0x26FF { return false } // Misc symbols
                if scalar.value >= 0x2700 && scalar.value <= 0x27BF { return false } // Dingbats
                if scalar.value >= 0xFE00 && scalar.value <= 0xFE0F { return false } // Variation Selectors
                if scalar.value >= 0x1F900 && scalar.value <= 0x1F9FF { return false } // Supplemental Symbols and Pictographs
                if scalar.value >= 0x1FA70 && scalar.value <= 0x1FAFF { return false } // Symbols and Pictographs Extended-A
                
                return false
            }
            
            return String(String.UnicodeScalarView(filtered))
        }
        
        // remove duplicate hashtags, keeping order
        var seen: Set<String> = []
        
        let uniqueComponents = normalizedComponents.filter { 
            !$0.isEmpty && seen.insert($0.lowercased()).inserted 
        }
        
        self.hashtags = uniqueComponents
    }
    
    func loadHashtags() {
        self.hashtagString = hashtags.map { "#" + $0 }.joined(separator: " ")
    }
}

#if DEBUG

struct FZHashtagFieldPreview: View {
    @State
    var hashtags: HashtagArray = []
    
    var body: some View {
        FZHashtagField(hashtags: $hashtags)
    }
    
}

#endif

#Preview {
#if DEBUG
    FZHashtagFieldPreview()
        .font(.fzHeading3)
        .padding(16)
#endif
}
