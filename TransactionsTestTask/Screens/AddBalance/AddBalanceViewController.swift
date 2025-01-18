//
//  AddBalanceViewController.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

class AddBalanceViewController: UIViewController {
    private var viewModel: AddBalanceViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var amountTextField = {
        let textField = UIDoubleField()
        textField.placeholder = "Amount"
        textField.font = .systemFont(ofSize: 22)
        textField.textInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        return textField
    }()
    
    private lazy var addBalanceButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .large
        configuration.title = "Add"
        configuration.titleTextAttributesTransformer = .init { incoming in
            var outgoing = incoming
            outgoing.font = .boldSystemFont(ofSize: 20)
            return outgoing
        }
        let button = UIButton(configuration: configuration)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var stackView = {
        let stackView = UIStackView(arrangedSubviews: [
            amountTextField,
            addBalanceButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var layoutConstraints = [
        stackView.topAnchor.constraint(
            equalTo: view.layoutMarginsGuide.topAnchor,
            constant: 32
        ),
        stackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 16),
        stackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -16),
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor)
    ]
    
    init(viewModel: AddBalanceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setupPresentationStyle()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        setupSubscriptions()
        
        view.backgroundColor = .systemBackground
    }
    
    private func setupPresentationStyle() {
        let smallDetentId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentId) { context in
            return 150
        }
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [smallDetent]
    }
    
    private func setupSubviews() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    private func setupSubscriptions() {
        viewModel.$addBalanceButtonIsEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: addBalanceButton)
            .store(in: &cancellables)
        
        amountTextField.publisher(for: .editingChanged)
            .compactMap { $0 as? UIDoubleField }
            .map(\.value)
            .map { $0 ?? 0 }
            .assign(to: \.amount, on: viewModel)
            .store(in: &cancellables)
        
        addBalanceButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.addBalanceButtonTapped()
            }
            .store(in: &cancellables)
    }
}

