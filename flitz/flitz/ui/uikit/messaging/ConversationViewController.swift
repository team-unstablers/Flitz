//
//  MessagingViewController.swift
//  FlitzNewChatUI
//
//  Created by Gyuhwan Park on 10/11/25.
//



import UIKit
import SwiftUI
import Combine

final class FZConversationViewController: UIViewController {
    private let logger = createFZOSLogger("FZConversationViewController")

    enum Section: Hashable {
        case date(Date)
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, DirectMessage>

    private var collectionView: UICollectionView!
    private var composeAreaHostingController: UIHostingController<MessageComposeAreaWrapper>!

    private var dataSource: DataSource!
    private var grouped: [(Section, [DirectMessage])] = []

    // MessageComposeArea 상태 관리
    @Published private var isSending: Bool = false
    @Published private var composeAreaFocused: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        self.configureCollectionView()
        self.configureComposeArea()
        self.configureDataSource()
        self.loadInitial()
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewCompositionalLayout { _, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = false
            config.backgroundColor = .clear
            
            return .list(using: config, layoutEnvironment: environment)
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .interactive
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)

        // constraint는 composeArea 추가 후 설정
        
        collectionView.register(MessageBubbleCell.self, forCellWithReuseIdentifier: MessageBubbleCell.reuseID)
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
    }

    private func configureComposeArea() {
        // SwiftUI MessageComposeArea를 Wrapper로 감싸서 호스팅
        let focusedBinding = Binding<Bool>(
            get: { [weak self] in self?.composeAreaFocused ?? false },
            set: { [weak self] newValue in self?.composeAreaFocused = newValue }
        )

        let wrapper = MessageComposeAreaWrapper(
            focused: focusedBinding,
            isSending: isSending
        ) { [weak self] request in
            self?.handleSendMessage(request: request)
        }

        composeAreaHostingController = UIHostingController(rootView: wrapper)
        composeAreaHostingController.view.backgroundColor = .clear
        composeAreaHostingController.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(composeAreaHostingController)
        view.addSubview(composeAreaHostingController.view)
        composeAreaHostingController.didMove(toParent: self)

        // Auto Layout 설정
        NSLayoutConstraint.activate([
            // CollectionView
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: composeAreaHostingController.view.topAnchor),

            // ComposeArea
            composeAreaHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composeAreaHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composeAreaHostingController.view.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    private func handleSendMessage(request: MessageRequest) {
        // TODO: 실제 메시지 전송 로직 구현
        logger.debug("Sending message: \(request.text), images: \(request.images.count)")

        // isSending 상태 업데이트
        isSending = true

        // 임시: 1초 후 전송 완료
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isSending = false
        }
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageBubbleCell.reuseID, for: indexPath) as! MessageBubbleCell
            cell.configure(with: item, isFromCurrentUser: item.sender == "me", isRead: true)
            
            return cell
        }
    }
    
    private func applySnapshot(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DirectMessage>()
        
        grouped.forEach { section, items in
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func loadInitial() {
        let now = Date()
        let messages: [DirectMessage] = [
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
                sender: "other",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요!"
                ),
                created_at: "1970-01-01T00:00:00Z"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385416")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "네, 반갑습니다!"
                ),
                created_at: "1970-01-01T00:00:01Z"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385417")!,
                sender: "other",
                content: DirectMessageContent(
                    type: "text",
                    text: "날씨가 좋네요 😊"
                ),
                created_at: "1970-01-01T00:00:02Z"
            )
        ]
        
        grouped = groupByDay(messages: messages)
        applySnapshot(animated: false)
        scrollToBottom(animated: false)
    }
    
    private func groupByDay(messages: [DirectMessage]) -> [(Section, [DirectMessage])] {
        let cal = Calendar.current
        let dict = Dictionary(grouping: messages) { (m: DirectMessage) -> Date in
            cal.startOfDay(for: m.created_at.asISO8601Date!)
        }.sorted { $0.key < $1.key }
        return dict.map { (key, vals) in (.date(key), vals.sorted { $0.created_at < $1.created_at }) }
    }
    
    
    private func scrollToBottom(animated: Bool) {
        guard let lastSection = grouped.last else { return }
        let sectionIndex = grouped.count - 1
        let itemIndex = lastSection.1.count - 1
        if sectionIndex >= 0, itemIndex >= 0 {
            let idx = IndexPath(item: itemIndex, section: sectionIndex)
            collectionView.scrollToItem(at: idx, at: .bottom, animated: animated)
        }
    }
}

extension FZConversationViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 스크롤 시작 시 키보드 내리기
        composeAreaFocused = false
    }
}

extension FZConversationViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // 썸네일/이미지 프리패치 자리
    }
}

// MARK: - SwiftUI Wrapper

/// MessageComposeArea를 UIKit에서 사용하기 위한 Wrapper
struct MessageComposeAreaWrapper: View {
    @Binding var focused: Bool
    @FocusState private var internalFocused: Bool
    var isSending: Bool
    var onSend: (MessageRequest) -> Void

    var body: some View {
        MessageComposeArea(
            focused: $internalFocused,
            onSend: onSend,
            isSending: isSending
        )
        .onChange(of: focused) { _, newValue in
            internalFocused = newValue
        }
        .onChange(of: internalFocused) { _, newValue in
            focused = newValue
        }
    }
}

struct FZConversationView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FZConversationViewController {
        FZConversationViewController()
    }
    
    func updateUIViewController(_ uiViewController: FZConversationViewController, context: Context) {
    }
}

#Preview {
    FZConversationView()
        .ignoresSafeArea(.all)
}
