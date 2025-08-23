import SwiftUI

/// 무한 스크롤을 지원하는 제네릭 GridView
public struct FZInfiniteGridView<Data, Content, LoadingView>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View, LoadingView: View {
    
    // MARK: - Properties
    
    private let data: Data
    private let columns: [GridItem]
    private let content: (Data.Element) -> Content
    private let loadingView: () -> LoadingView
    private let onLoadMore: () async -> Void
    
    @State private var isLoading = false
    @Binding var hasMoreData: Bool
    
    // Grid spacing
    private let spacing: CGFloat?
    private let horizontalSpacing: CGFloat?
    private let verticalSpacing: CGFloat?
    
    // Threshold for triggering load more (items from end)
    private let loadThreshold: Int
    
    // MARK: - Initialization
    
    /// Initialize infinite grid view with custom spacing
    /// - Parameters:
    ///   - data: Collection of data items to display
    ///   - columns: Grid column configuration
    ///   - hasMoreData: Binding to track if more data is available
    ///   - spacing: Uniform spacing for both axes (overridden by horizontal/vertical if provided)
    ///   - horizontalSpacing: Horizontal spacing between items
    ///   - verticalSpacing: Vertical spacing between rows
    ///   - loadThreshold: Number of items from end to trigger load more (default: 6 for 2-column grid)
    ///   - loadingView: View to show while loading more data
    ///   - onLoadMore: Async closure called when more data should be loaded
    ///   - content: View builder for each data item
    public init(
        data: Data,
        columns: [GridItem],
        hasMoreData: Binding<Bool>,
        spacing: CGFloat? = nil,
        horizontalSpacing: CGFloat? = nil,
        verticalSpacing: CGFloat? = nil,
        loadThreshold: Int = 6,
        @ViewBuilder loadingView: @escaping () -> LoadingView,
        onLoadMore: @escaping () async -> Void,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.columns = columns
        self._hasMoreData = hasMoreData
        self.spacing = spacing
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.loadThreshold = loadThreshold
        self.loadingView = loadingView
        self.onLoadMore = onLoadMore
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            LazyVGrid(
                columns: columns,
                spacing: verticalSpacing ?? spacing
            ) {
                ForEach(Array(data)) { item in
                    content(item)
                        .onAppear {
                            checkIfLoadMoreNeeded(item)
                        }
                }
                
                if isLoading {
                    // Loading view spans all columns
                    loadingView()
                        .frame(maxWidth: .infinity)
                        .gridCellColumns(columns.count)
                        .padding()
                }
            }
            .padding(.horizontal, horizontalSpacing ?? spacing)
        }
    }
    
    // MARK: - Private Methods
    
    private func checkIfLoadMoreNeeded(_ item: Data.Element) {
        guard !isLoading,
              hasMoreData,
              let itemIndex = data.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        // Check if we're near the end (within threshold items)
        let distance = data.distance(from: itemIndex, to: data.endIndex)
        if distance <= loadThreshold {
            loadMore()
        }
    }
    
    private func loadMore() {
        isLoading = true
        
        Task {
            await onLoadMore()
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// MARK: - Convenience Initializers

extension FZInfiniteGridView where LoadingView == ProgressView<EmptyView, EmptyView> {
    /// Initialize with default ProgressView as loading indicator
    public init(
        data: Data,
        columns: [GridItem],
        hasMoreData: Binding<Bool>,
        spacing: CGFloat? = nil,
        horizontalSpacing: CGFloat? = nil,
        verticalSpacing: CGFloat? = nil,
        loadThreshold: Int = 6,
        onLoadMore: @escaping () async -> Void,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data: data,
            columns: columns,
            hasMoreData: hasMoreData,
            spacing: spacing,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            loadThreshold: loadThreshold,
            loadingView: { ProgressView() },
            onLoadMore: onLoadMore,
            content: content
        )
    }
}

extension FZInfiniteGridView {
    /// Initialize with uniform spacing
    public init(
        data: Data,
        columns: [GridItem],
        hasMoreData: Binding<Bool>,
        spacing: CGFloat,
        loadThreshold: Int = 6,
        @ViewBuilder loadingView: @escaping () -> LoadingView,
        onLoadMore: @escaping () async -> Void,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data: data,
            columns: columns,
            hasMoreData: hasMoreData,
            spacing: spacing,
            horizontalSpacing: nil,
            verticalSpacing: nil,
            loadThreshold: loadThreshold,
            loadingView: loadingView,
            onLoadMore: onLoadMore,
            content: content
        )
    }
}

// MARK: - Preview

#Preview("Basic Infinite Grid") {
    struct PreviewItem: Identifiable {
        let id = UUID()
        let number: Int
        let color: Color
    }
    
    struct PreviewView: View {
        @State private var items: [PreviewItem] = (1...20).map {
            PreviewItem(number: $0, color: Color.random)
        }
        @State private var hasMoreData = true
        
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        var body: some View {
            NavigationView {
                FZInfiniteGridView(
                    data: items,
                    columns: columns,
                    hasMoreData: $hasMoreData,
                    spacing: 10,
                    onLoadMore: {
                        // Simulate network delay
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        
                        // Add more items
                        let currentCount = items.count
                        let newItems = (currentCount + 1...currentCount + 20).map {
                            PreviewItem(number: $0, color: Color.random)
                        }
                        
                        await MainActor.run {
                            items.append(contentsOf: newItems)
                            // Stop loading after 100 items
                            if items.count >= 100 {
                                hasMoreData = false
                            }
                        }
                    }
                ) { item in
                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(item.color)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Text("#\(item.number)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    .padding(4)
                }
                .navigationTitle("Infinite Grid")
            }
        }
    }
    
    return PreviewView()
}

#Preview("3-Column Grid with Custom Loading") {
    struct PreviewCard: Identifiable {
        let id = UUID()
        let title: String
        let imageNumber: Int
    }
    
    struct PreviewView: View {
        @State private var cards: [PreviewCard] = (1...30).map {
            PreviewCard(title: "Card \($0)", imageNumber: $0)
        }
        @State private var hasMoreData = true
        
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        var body: some View {
            NavigationView {
                FZInfiniteGridView(
                    data: cards,
                    columns: columns,
                    hasMoreData: $hasMoreData,
                    horizontalSpacing: 8,
                    verticalSpacing: 8,
                    loadThreshold: 9,
                    loadingView: {
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading more cards...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    },
                    onLoadMore: {
                        // Simulate network delay
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        
                        // Add more items
                        let currentCount = cards.count
                        let newCards = (currentCount + 1...currentCount + 30).map {
                            PreviewCard(title: "Card \($0)", imageNumber: $0)
                        }
                        
                        await MainActor.run {
                            cards.append(contentsOf: newCards)
                            // Stop loading after 150 cards
                            if cards.count >= 150 {
                                hasMoreData = false
                            }
                        }
                    }
                ) { card in
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.3))
                            .aspectRatio(0.75, contentMode: .fit)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.blue)
                            )
                        
                        Text(card.title)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(radius: 2)
                    )
                }
                .background(Color.gray.opacity(0.05))
                .navigationTitle("Card Gallery")
            }
        }
    }
    
    return PreviewView()
}

// MARK: - Helper Extensions

private extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0.3...0.9),
            green: .random(in: 0.3...0.9),
            blue: .random(in: 0.3...0.9)
        )
    }
}