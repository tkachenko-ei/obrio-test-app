//
//  AddTransactionViewController.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

class AddTransactionViewController: UIViewController {
    
    private var viewModel: AddTransactionViewModel
    
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
    
    private lazy var categoryPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .secondarySystemGroupedBackground
        pickerView.layer.cornerRadius = 8
        pickerView.layer.masksToBounds = true
        return pickerView
    }()
    
    private lazy var addTransactionButton: UIButton = {
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
            categoryPickerView,
            addTransactionButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var layoutConstraints = [
        stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 32),
        stackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 16),
        stackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: -16),
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor)
    ]
    
    init(viewModel: AddTransactionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        title = "Add transaction"
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
    
    private func setupSubviews() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    private func setupSubscriptions() {
        viewModel.$addTranssactionButtonIsEnabled
            .assign(to: \.isEnabled, on: addTransactionButton)
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.presentAlertError(error)
            }
            .store(in: &cancellables)
        
        amountTextField.publisher(for: .editingChanged)
            .compactMap { $0 as? UIDoubleField }
            .map(\.value)
            .map { $0 ?? 0 }
            .assign(to: \.amount, on: viewModel)
            .store(in: &cancellables)
        
        addTransactionButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.addTranssactionButtonTapped()
            }
            .store(in: &cancellables)
    }
    
    private func presentAlertError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
            alert.dismiss(animated: true)
        })
        present(alert, animated: true, completion: nil)
    }
}

extension AddTransactionViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfCategories()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.titleForCategory(at: row)
    }
}

extension AddTransactionViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedCategory(at: row)
    }
}

