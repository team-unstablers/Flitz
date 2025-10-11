//
//  MessageBubbleCell.swift
//  Flitz
//
//  Created by Gyuhwan Park on 10/12/25.
//

import UIKit

class FZMessageBubbleView: UIView {

    // MARK: - Properties

    var conversationId: String?
    var userId: String?
    var onAttachmentTap: ((String) -> Void)?

    private var currentMessage: DirectMessage?
    private var isFromCurrentUser: Bool = false
    private var isRead: Bool = false

    // MARK: - UI Components

    private let containerStack = UIStackView()
    private let contentStack = UIStackView()
    private let bubble = UIView()
    private let textView = UITextView()
    private let imageView = UIImageView()
    private let metadataStack = UIStackView()
    private let timeLabel = UILabel()
    private let readLabel = UILabel()

    // MARK: - Constraints

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        // Container stack (horizontal)
        containerStack.axis = .horizontal
        containerStack.alignment = .bottom
        containerStack.spacing = 8
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerStack)

        // Content stack (vertical, contains bubble)
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0

        // Bubble
        bubble.layer.cornerRadius = 16
        bubble.layer.masksToBounds = true
        bubble.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(bubble)

        // Text view
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        textView.adjustsFontForContentSizeCategory = true
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.dataDetectorTypes = [.link, .phoneNumber]
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isHidden = true
        bubble.addSubview(textView)

        // Image view
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        bubble.addSubview(imageView)

        // Metadata stack
        metadataStack.axis = .vertical
        metadataStack.spacing = 2
        metadataStack.alignment = .trailing

        // Read label
        readLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        readLabel.textColor = UIColor.systemGray
        readLabel.text = NSLocalizedString("ui.messaging.bubble.read", comment: "읽음")
        readLabel.isHidden = true
        metadataStack.addArrangedSubview(readLabel)

        // Time label
        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        timeLabel.textColor = UIColor.systemGray
        metadataStack.addArrangedSubview(timeLabel)

        // Add tap gesture for image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        imageView.addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        leadingConstraint = containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        trailingConstraint = containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingConstraint,
            trailingConstraint,

            // Text view constraints
            textView.topAnchor.constraint(equalTo: bubble.topAnchor),
            textView.leadingAnchor.constraint(equalTo: bubble.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: bubble.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),

            // Image view constraints
            imageView.topAnchor.constraint(equalTo: bubble.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: bubble.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: bubble.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bubble.bottomAnchor),

            // Bubble max width
            bubble.widthAnchor.constraint(lessThanOrEqualToConstant: 260)
        ])
    }

    // MARK: - Configuration

    func configure(with message: DirectMessage, isFromCurrentUser: Bool, isRead: Bool) {
        self.currentMessage = message
        self.isFromCurrentUser = isFromCurrentUser
        self.isRead = isRead

        // Clear existing arranged subviews
        containerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Update metadata
        metadataStack.alignment = isFromCurrentUser ? .trailing : .leading
        readLabel.isHidden = !(isFromCurrentUser && isRead)
        if let date = message.created_at.asISO8601Date {
            timeLabel.text = date.localeTimeString
        }

        // Configure layout based on sender
        if isFromCurrentUser {
            // [spacer] [metadata] [bubble]
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            containerStack.addArrangedSubview(spacer)
            containerStack.addArrangedSubview(metadataStack)
            containerStack.addArrangedSubview(contentStack)
        } else {
            // [bubble] [metadata] [spacer]
            containerStack.addArrangedSubview(contentStack)
            containerStack.addArrangedSubview(metadataStack)
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            containerStack.addArrangedSubview(spacer)
        }

        // Configure content based on message type
        switch message.content.type {
        case "text":
            configureTextContent(message: message, isFromCurrentUser: isFromCurrentUser)
        case "attachment":
            configureAttachmentContent(message: message, isFromCurrentUser: isFromCurrentUser)
        default:
            configureUnsupportedContent(isFromCurrentUser: isFromCurrentUser)
        }

        // Setup context menu
        setupContextMenu(isFromCurrentUser: isFromCurrentUser)
    }

    private func configureTextContent(message: DirectMessage, isFromCurrentUser: Bool) {
        textView.isHidden = false
        imageView.isHidden = true

        textView.text = message.content.text

        if isFromCurrentUser {
            bubble.backgroundColor = .systemBlue
            textView.textColor = .white
        } else {
            bubble.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5)
            textView.textColor = .label
        }
    }

    private func configureAttachmentContent(message: DirectMessage, isFromCurrentUser: Bool) {
        textView.isHidden = true
        imageView.isHidden = false

        bubble.backgroundColor = .clear

        guard let attachmentId = message.content.attachment_id,
              let urlString = message.content.thumbnail_url ?? message.content.public_url,
              let url = URL(string: urlString),
              let width = message.content.width,
              let height = message.content.height else {
            return
        }

        let originalSize = CGSize(width: width, height: height)
        let scaledSize = originalSize.scaleInto(target: CGSize(width: 200, height: 200))

        // Update image view size constraint
        NSLayoutConstraint.deactivate(imageView.constraints.filter {
            $0.firstAttribute == .width || $0.firstAttribute == .height
        })
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: scaledSize.width),
            imageView.heightAnchor.constraint(equalToConstant: scaledSize.height)
        ])

        // Load image (using URLSession for now, can be replaced with CachedAsyncImage equivalent)
        loadImage(from: url, identifier: "message:attachment:\(attachmentId)")
    }

    private func configureUnsupportedContent(isFromCurrentUser: Bool) {
        textView.isHidden = false
        imageView.isHidden = true

        textView.text = "Unsupported message type"
        bubble.backgroundColor = .systemGray5
        textView.textColor = .label
    }

    // MARK: - Image Loading

    private func loadImage(from url: URL, identifier: String) {
        // Show placeholder
        imageView.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.1)

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageView.backgroundColor = .clear
            }
        }.resume()
    }

    // MARK: - Context Menu

    private func setupContextMenu(isFromCurrentUser: Bool) {
        let interaction = UIContextMenuInteraction(delegate: self)
        bubble.interactions.forEach { bubble.removeInteraction($0) }
        bubble.addInteraction(interaction)
    }

    // MARK: - Actions

    @objc private func handleImageTap() {
        guard let attachmentId = currentMessage?.content.attachment_id else { return }
        onAttachmentTap?(attachmentId)
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension FZMessageBubbleView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }

            if self.isFromCurrentUser {
                let deleteAction = UIAction(
                    title: NSLocalizedString("ui.messaging.bubble.delete", comment: "메시지 삭제"),
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive
                ) { _ in
                    // TODO: Implement delete
                }
                return UIMenu(title: "", children: [deleteAction])
            } else {
                let reportAction = UIAction(
                    title: NSLocalizedString("ui.messaging.bubble.report", comment: "메시지 신고"),
                    image: UIImage(systemName: "exclamationmark.triangle"),
                    attributes: .destructive
                ) { _ in
                    // TODO: Implement report
                }
                return UIMenu(title: "", children: [reportAction])
            }
        }
    }
}

final class MessageBubbleCell: UICollectionViewCell {

    static let reuseID = "pl.unstabler.flitz.messaging.MessageBubbleCell"

    private let bubbleView = FZMessageBubbleView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // FZMessageBubbleView will handle its own cleanup
    }

    func configure(with message: DirectMessage, isFromCurrentUser: Bool, isRead: Bool) {
        bubbleView.configure(with: message, isFromCurrentUser: isFromCurrentUser, isRead: isRead)
    }
}

// MARK: - SwiftUI Preview Support

#if DEBUG
import SwiftUI

struct FZMessageBubbleViewPreview: UIViewRepresentable {
    let message: DirectMessage
    let isFromCurrentUser: Bool
    let isRead: Bool

    func makeUIView(context: Context) -> FZMessageBubbleView {
        let view = FZMessageBubbleView()
        view.configure(with: message, isFromCurrentUser: isFromCurrentUser, isRead: isRead)
        return view
    }

    func updateUIView(_ uiView: FZMessageBubbleView, context: Context) {
        uiView.configure(with: message, isFromCurrentUser: isFromCurrentUser, isRead: isRead)
    }
}

#Preview("내가 보낸 텍스트 메시지") {
    FZMessageBubbleViewPreview(
        message: DirectMessage(
            id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
            sender: "me",
            content: DirectMessageContent(
                type: "text",
                text: "안녕하세요! 반갑습니다 😊"
            ),
            created_at: "1970-01-01T00:00:00Z"
        ),
        isFromCurrentUser: true,
        isRead: true
    )
    .frame(height: 80)
    .padding()
}

#Preview("상대방이 보낸 텍스트 메시지") {
    FZMessageBubbleViewPreview(
        message: DirectMessage(
            id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
            sender: "other",
            content: DirectMessageContent(
                type: "text",
                text: "네, 안녕하세요!"
            ),
            created_at: "1970-01-01T00:00:00Z"
        ),
        isFromCurrentUser: false,
        isRead: true
    )
    .frame(height: 80)
    .padding()
}

#Preview("읽지 않은 메시지") {
    FZMessageBubbleViewPreview(
        message: DirectMessage(
            id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
            sender: "me",
            content: DirectMessageContent(
                type: "text",
                text: "아직 안 읽으셨나요?"
            ),
            created_at: "1970-01-01T00:00:00Z"
        ),
        isFromCurrentUser: true,
        isRead: false
    )
    .frame(height: 80)
    .padding()
}

#Preview("긴 텍스트 메시지") {
    FZMessageBubbleViewPreview(
        message: DirectMessage(
            id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
            sender: "other",
            content: DirectMessageContent(
                type: "text",
                text: "이것은 아주 긴 메시지입니다. 버블이 적절하게 늘어나는지 확인해봅시다. 여러 줄에 걸쳐서 텍스트가 표시되어야 하고, 버블의 최대 너비를 넘지 않아야 합니다."
            ),
            created_at: "1970-01-01T00:00:00Z"
        ),
        isFromCurrentUser: false,
        isRead: true
    )
    .frame(height: 150)
    .padding()
}

#Preview("여러 메시지") {
    VStack(spacing: 8) {
        FZMessageBubbleViewPreview(
            message: DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
                sender: "other",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요!"
                ),
                created_at: "1970-01-01T00:00:00Z"
            ),
            isFromCurrentUser: false,
            isRead: true
        )

        FZMessageBubbleViewPreview(
            message: DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385416")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "네, 반갑습니다!"
                ),
                created_at: "1970-01-01T00:00:01Z"
            ),
            isFromCurrentUser: true,
            isRead: true
        )

        FZMessageBubbleViewPreview(
            message: DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385417")!,
                sender: "other",
                content: DirectMessageContent(
                    type: "text",
                    text: "날씨가 좋네요 😊"
                ),
                created_at: "1970-01-01T00:00:02Z"
            ),
            isFromCurrentUser: false,
            isRead: true
        )

        Spacer()
    }
    .padding()
}

#endif

