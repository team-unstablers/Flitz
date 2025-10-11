//
//  FZDateSeparatorView.swift
//  Flitz
//
//  Created by Gyuhwan Park on 10/12/25.
//

import UIKit

/// 대화 내에서 날짜 구분선을 표시하는 뷰
final class FZDateSeparatorView: UICollectionReusableView {

    static let reuseID = "pl.unstabler.flitz.messaging.DateSeparator"

    // MARK: - UI Components

    private let containerView = UIView()
    private let label = UILabel()
    private let capsuleBackground = UIView()

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
        backgroundColor = .clear

        // Container view (centers the content)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        // Capsule background
        capsuleBackground.backgroundColor = .white
        capsuleBackground.layer.cornerRadius = 14
        capsuleBackground.layer.masksToBounds = false
        capsuleBackground.layer.shadowColor = UIColor.black.cgColor
        capsuleBackground.layer.shadowOpacity = 0.1
        capsuleBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
        capsuleBackground.layer.shadowRadius = 2
        capsuleBackground.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(capsuleBackground)

        // Label
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container fills the entire view with vertical padding
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),

            // Capsule background matches label size + padding
            capsuleBackground.topAnchor.constraint(equalTo: label.topAnchor, constant: -4),
            capsuleBackground.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
            capsuleBackground.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            capsuleBackground.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),

            // Label centered in container
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    // MARK: - Configuration

    func configure(with date: Date) {
        label.text = date.localeDateString
    }
}
