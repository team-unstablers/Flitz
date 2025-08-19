import SwiftUI

/// 무한 스크롤을 지원하는 제네릭 ScrollView
public struct FZInfiniteScrollView<Data, Content, LoadingView>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View, LoadingView: View {
    
    // MARK: - Properties
    
    private let data: Data
    private let content: (Data.Element) -> Content
    private let loadingView: () -> LoadingView
    private let onLoadMore: () async -> Void
    
    @State private var isLoading = false
    @State private var hasMoreData = true
    
    // Threshold for triggering load more (in points from bottom)
    private let loadThreshold: CGFloat
    
    // MARK: - Initialization
    
    /// Initialize infinite scroll view
    /// - Parameters:
    ///   - data: Collection of data items to display
    ///   - loadThreshold: Distance from bottom to trigger load more (default: 100)
    ///   - loadingView: View to show while loading more data
    ///   - onLoadMore: Async closure called when more data should be loaded
    ///   - content: View builder for each data item
    public init(
        data: Data,
        loadThreshold: CGFloat = 100,
        @ViewBuilder loadingView: @escaping () -> LoadingView,
        onLoadMore: @escaping () async -> Void,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.loadThreshold = loadThreshold
        self.loadingView = loadingView
        self.onLoadMore = onLoadMore
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(data)) { item in
                    content(item)
                        .onAppear {
                            checkIfLoadMoreNeeded(item)
                        }
                }
                
                if isLoading {
                    loadingView()
                        .padding()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func checkIfLoadMoreNeeded(_ item: Data.Element) {
        guard !isLoading,
              hasMoreData,
              let itemIndex = data.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        // Check if we're near the end (within last 3 items)
        let distance = data.distance(from: itemIndex, to: data.endIndex)
        if distance <= 3 {
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

// MARK: - Convenience Initializer with Default Loading View

extension FZInfiniteScrollView where LoadingView == ProgressView<EmptyView, EmptyView> {
    /// Initialize with default ProgressView as loading indicator
    public init(
        data: Data,
        loadThreshold: CGFloat = 100,
        onLoadMore: @escaping () async -> Void,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data: data,
            loadThreshold: loadThreshold,
            loadingView: { ProgressView() },
            onLoadMore: onLoadMore,
            content: content
        )
    }
}

// MARK: - Preview

#Preview("Basic Infinite Scroll") {
    struct PreviewItem: Identifiable {
        let id = UUID()
        let number: Int
        let color: Color
    }
    
    struct PreviewView: View {
        @State private var items: [PreviewItem] = (1...20).map {
            PreviewItem(number: $0, color: Color.random)
        }
        
        var body: some View {
            NavigationView {
                FZInfiniteScrollView(
                    data: items,
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
                        }
                    }
                ) { item in
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.color)
                            .frame(width: 50, height: 50)
                        
                        Text("Item #\(item.number)")
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
                .navigationTitle("Infinite Scroll")
            }
        }
    }
    
    return PreviewView()
}

#Preview("Custom Loading View") {
    struct PreviewItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
    }
    
    struct PreviewView: View {
        @State private var posts: [PreviewItem] = (1...10).map {
            PreviewItem(
                title: "Post \($0)",
                subtitle: "This is the content of post number \($0)"
            )
        }
        @State private var isLoadingMore = false
        
        var body: some View {
            NavigationView {
                FZInfiniteScrollView(
                    data: posts,
                    loadThreshold: 150,
                    loadingView: {
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading more posts...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    },
                    onLoadMore: {
                        isLoadingMore = true
                        
                        // Simulate network delay
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        
                        // Add more items
                        let currentCount = posts.count
                        let newPosts = (currentCount + 1...currentCount + 10).map {
                            PreviewItem(
                                title: "Post \($0)",
                                subtitle: "This is the content of post number \($0)"
                            )
                        }
                        
                        await MainActor.run {
                            posts.append(contentsOf: newPosts)
                            isLoadingMore = false
                        }
                    }
                ) { post in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.title)
                            .font(.headline)
                        
                        Text(post.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(radius: 2)
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
                .background(Color.gray.opacity(0.05))
                .navigationTitle("Social Feed")
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