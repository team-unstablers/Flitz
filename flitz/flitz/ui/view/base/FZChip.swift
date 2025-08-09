//
//  FZChip.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/10/25.
//

import SwiftUI

struct FZChip: View {
    let label: String
    let selected: Bool
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(selected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(selected ? Color.white : Color.black)
                .cornerRadius(12)
                .animation(nil)
        }
        .buttonStyle(.plain)
    }
}

protocol FZChipSelection: CaseIterable, Hashable {
    var asLocalizedString: String { get }
}

struct FZSingleChipSelector<Selection: FZChipSelection>: View {
    @Binding
    var selectedChip: Selection
    
    var body: some View {
        HStack {
            ForEach(Array(Selection.allCases), id: \.self) { selection in
                FZChip(label: selection.asLocalizedString, selected: selectedChip == selection) {
                    selectedChip = selection
                }
            }
        }
    }
}

struct FZChipSelector<Selection: FZChipSelection>: View {
    @Binding
    var selectedChips: Set<Selection>
    
    var body: some View {
        HStack {
            ForEach(Array(Selection.allCases), id: \.self) { selection in
                FZChip(label: selection.asLocalizedString, selected: selectedChips.contains(selection)) {
                    if selectedChips.contains(selection) {
                        selectedChips.remove(selection)
                    } else {
                        selectedChips.insert(selection)
                    }
                }
            }
        }
    }
}

#if DEBUG
fileprivate enum FZChipPreviewSelection: FZChipSelection {
    case man
    case woman
    case nonBinary
    
    var asLocalizedString: String {
        switch self {
        case .man:
            return "남성"
        case .woman:
            return "여성"
        case .nonBinary:
            return "논바이너리"
        }
    }
}

fileprivate struct FZChipPreview: View {
    @State
    var selectedChips: Set<FZChipPreviewSelection> = []
    
    var body: some View {
        FZChipSelector<FZChipPreviewSelection>(selectedChips: $selectedChips)
    }
}
#endif

#Preview {
    FZChipPreview()
}
