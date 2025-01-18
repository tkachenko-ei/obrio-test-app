//
//  BalanceView.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

class BalanceView: UIView {
    
    private var viewModel: BalanceViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var bitcoinRateLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bitcoinBalanceLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 48)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bitcoinBalanceReplenishButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.buttonSize = .medium
        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var addTransactionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Add transaction"
        configuration.buttonSize = .medium
        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var layoutConstraints = [
        bitcoinRateLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 32),
        bitcoinRateLabel.leftAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leftAnchor),
        bitcoinRateLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -16),
        
        bitcoinBalanceLabel.topAnchor.constraint(equalTo: bitcoinRateLabel.bottomAnchor, constant: 32),
        bitcoinBalanceLabel.leftAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leftAnchor),
        bitcoinBalanceLabel.rightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.rightAnchor),
        bitcoinBalanceLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
        bitcoinBalanceReplenishButton.leftAnchor.constraint(equalTo: bitcoinBalanceLabel.rightAnchor, constant: 8),
        bitcoinBalanceReplenishButton.rightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.rightAnchor),
        bitcoinBalanceReplenishButton.centerYAnchor.constraint(equalTo: bitcoinBalanceLabel.centerYAnchor),
        
        addTransactionButton.topAnchor.constraint(equalTo: bitcoinBalanceLabel.bottomAnchor, constant: 32),
        addTransactionButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -32),
        addTransactionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
    ]
    
    init(viewModel: BalanceViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupSubviews()
        setupSubscriptions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(bitcoinRateLabel)
        addSubview(bitcoinBalanceLabel)
        addSubview(bitcoinBalanceReplenishButton)
        addSubview(addTransactionButton)
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    private func setupSubscriptions() {
        viewModel.$bitcoinRate
            .map { $0.formatted(.number.precision(.fractionLength(0...2))) }
            .map { "1 ₿ - \($0) $" }
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: bitcoinRateLabel)
            .store(in: &cancellables)
        
        viewModel.$bitcoinBalance
            .map { $0.formatted(.number.precision(.fractionLength(0...2))) }
            .map { "\($0) $" }
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: bitcoinBalanceLabel)
            .store(in: &cancellables)
        
        bitcoinBalanceReplenishButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.bitcoinBalanceReplenishButtonTapped()
            }
            .store(in: &cancellables)
        
        addTransactionButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.addTransactionButtonTapped()
            }
            .store(in: &cancellables)
    }
}

