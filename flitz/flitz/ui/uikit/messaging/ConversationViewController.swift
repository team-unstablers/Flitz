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
    @Published private var composeAreaFocused: Bool = false {
        didSet {
            // 키보드가 표시될 때 자동 스크롤
            if composeAreaFocused && shouldStickToBottom {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.scrollToBottom(animated: true)
                }
            }
        }
    }

    // 스크롤 상태 관리
    private var shouldStickToBottom = true
    
    private var shouldLoadMore = true

    // ViewModel 및 Combine
    private var viewModel: ConversationViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var currentUserId: String?
    

    let conversationId: String

    init(conversationId: String) {
        self.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)

        self.viewModel = ConversationViewModel(conversationId: conversationId)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // 노티피케이션 옵저버 제거
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        self.configureCollectionView()
        self.configureComposeArea()
        self.configureDataSource()
        self.setupViewModelBindings()
        self.setupScenePhaseObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // WebSocket 연결
        viewModel.connectWebSocket()

        // 읽음 처리
        Task {
            await viewModel.markAsRead()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // WebSocket 연결 해제
        viewModel.disconnectWebSocket()
    }

    func configure(with apiClient: FZAPIClient, currentUserId: String) {
        self.currentUserId = currentUserId
        viewModel.configure(with: apiClient, currentUserId: currentUserId)
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewCompositionalLayout { _, environment in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = false
            config.backgroundColor = .clear
            config.headerMode = .supplementary

            return .list(using: config, layoutEnvironment: environment)
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .interactive
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)

        // constraint는 composeArea 추가 후 설정

        collectionView.register(MessageBubbleCell.self, forCellWithReuseIdentifier: MessageBubbleCell.reuseID)
        collectionView.register(FZDateSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FZDateSeparatorView.reuseID)
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
        logger.debug("Sending message: \(request.text), images: \(request.images.count)")

        Task {
            await viewModel.sendMessage(request: request)
        }
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: MessageBubbleCell.reuseID, for: indexPath)
            }

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageBubbleCell.reuseID, for: indexPath) as! MessageBubbleCell

            let isFromCurrentUser = self.viewModel.isFromCurrentUser(item)

            // 읽음 상태 계산 (SwiftUI 버전과 동일)
            let isRead: Bool = {
                guard let opponentId = self.viewModel.opponentId,
                      let readAt = self.viewModel.readState[opponentId],
                      let messageDate = item.created_at.asISO8601Date else {
                    return false
                }
                return readAt >= messageDate
            }()

            // 첨부파일 탭 핸들러
            cell.configure(
                with: item,
                isFromCurrentUser: isFromCurrentUser,
                isRead: isRead,
                onAttachmentTap: { [weak self] attachmentId in
                    self?.composeAreaFocused = false
                    // TODO: 첨부파일 전체화면 보기 구현
                    self?.logger.debug("Attachment tapped: \(attachmentId)")
                }
            )

            return cell
        }

        // 섹션 헤더 (날짜 구분) 설정
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }

            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: FZDateSeparatorView.reuseID,
                    for: indexPath
                ) as! FZDateSeparatorView

                let section = self.grouped[indexPath.section].0
                if case .date(let date) = section {
                    header.configure(with: date)
                }

                return header
            }

            return nil
        }
    }
    
    private func applySnapshot(animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DirectMessage>()
        
        grouped.forEach { section, items in
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func setupViewModelBindings() {
        // 메시지 리스트 변경 구독
        viewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                guard let self = self else { return }
                self.grouped = self.groupByDay(messages: messages)
                self.applySnapshot(animated: false)

                // shouldStickToBottom이 true이거나 첫 로딩 시 자동 스크롤
                if self.shouldStickToBottom {
                    self.scrollToBottom(animated: false)
                }
            }
            .store(in: &cancellables)

        // 전송 상태 동기화
        viewModel.$isSending
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSending, on: self)
            .store(in: &cancellables)

        // 로딩 상태 구독 (필요 시 로딩 인디케이터 표시)
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.logger.debug("Loading state: \(isLoading)")
                // TODO: 로딩 인디케이터 표시
            }
            .store(in: &cancellables)

        // 연결 상태 구독 (에러 핸들링 및 사용자 피드백)
        viewModel.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleConnectionStateChange(state)
            }
            .store(in: &cancellables)
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

    private func handleConnectionStateChange(_ state: ConversationViewModel.ConnectionState) {
        switch state {
        case .connected:
            logger.info("[Connection] Connected to conversation")
            // TODO: 연결 성공 시 UI 피드백 (배너 숨기기 등)

        case .disconnected:
            logger.warning("[Connection] Disconnected from conversation")
            // TODO: 연결 끊김 시 UI 피드백 (배너 표시 등)

        case .reconnecting(let attempt):
            logger.info("[Connection] Reconnecting... (attempt \(attempt))")
            // TODO: 재연결 시도 시 UI 피드백 (배너 표시 등)
        }
    }

    private func setupScenePhaseObservers() {
        // 포그라운드 진입 노티피케이션
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        // 백그라운드 진입 노티피케이션
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    @objc private func handleWillEnterForeground() {
        logger.info("[ConversationViewController] App became active, reconnecting...")

        // WebSocket 재연결 (필요 시)
        if viewModel.connectionState == .disconnected {
            viewModel.connectWebSocket()
        }

        // 메시지 갱신 및 읽음 처리
        Task {
            await viewModel.loadMessages()
            await viewModel.markAsRead()
        }

        // 알림 제거
        viewModel.removeThreadNotifications()
    }

    @objc private func handleDidEnterBackground() {
        logger.info("[ConversationViewController] App went to background, disconnecting...")

        // WebSocket 연결 끊기
        viewModel.disconnectWebSocket()
    }
}

extension FZConversationViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 스크롤 시작 시 키보드 내리기
        composeAreaFocused = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 하단 근처인지 판단 (100pt 이내)
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        let isNearBottom = (contentHeight - offsetY - frameHeight) < 100

        shouldStickToBottom = isNearBottom
        
        if !viewModel.isLoadingMore {
            self.shouldLoadMore = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 2번째 아이템이 표시될 때 이전 메시지 로드 (SwiftUI 버전과 동일)
        
        if !shouldLoadMore {
            return
        }
        
        if viewModel.messages.count > 10 && indexPath.section == 0 && indexPath.item <= 9 {
            self.shouldLoadMore = false
            Task {
                await viewModel.loadPreviousMessages()
            }
        }
    }
}

extension FZConversationViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // 썸네일/이미지 프리패치 (9단계에서 구현)
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
    @EnvironmentObject var appState: RootAppState
    @Environment(\.userId) var userId

    let conversationId: String

    func makeUIViewController(context: Context) -> FZConversationViewController {
        let viewController = FZConversationViewController(conversationId: conversationId)
        viewController.configure(with: appState.client, currentUserId: userId)
        return viewController
    }

    func updateUIViewController(_ uiViewController: FZConversationViewController, context: Context) {
        // 필요 시 업데이트 로직 추가
    }
}

#Preview {
    FZConversationView(conversationId: "preview-conversation")
        .environmentObject(RootAppState())
        .environment(\.userId, "preview-user")
        .ignoresSafeArea(.all)
}
