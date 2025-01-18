//
//  HomeViewController.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    private var viewModel: HomeViewModel
    
    private var cancellables = Set<AnyCancellable>()

    private lazy var balanceView = {
        let balanceView = BalanceView(viewModel: viewModel.balance)
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        return balanceView
    }()
    
    private lazy var transactionsTableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var layoutConstraints = [
        balanceView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        balanceView.leftAnchor.constraint(equalTo: view.leftAnchor),
        balanceView.rightAnchor.constraint(equalTo: view.rightAnchor),
        
        transactionsTableView.topAnchor.constraint(equalTo: balanceView.bottomAnchor),
        transactionsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        transactionsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        transactionsTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
    ]
    
    private lazy var transactionsSnapshot = TransactionsDiffableDataSourceSnapshot()
    private lazy var transactionsDataSource = TransactionsDiffableTableDataSource(tableView: transactionsTableView)
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        title = "Transactions"
    }
    
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
        view.addSubview(balanceView)
        view.addSubview(transactionsTableView)
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    private func setupSubscriptions() {
        viewModel.transactionsViewActionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                self?.updateTransactionsSnapshot(action)
            }
            .store(in: &cancellables)
    }
    
    private func updateTransactionsSnapshot(_ action: TransactionsViewAction) {
        switch action {
        case let .showNewTransaction(transaction):
            showNewTransaction(transaction)
                
        case let .showNewPageTransactions(transactions):
            showNewPageTransactions(transactions)
        }
    }
    
    private func showNewTransaction(_ transaction: TransactionSection) {
        if transactionsSnapshot.sectionIdentifiers.contains(transaction.section) {
            if let firstItem = transactionsSnapshot.itemIdentifiers(inSection: transaction.section).first {
                transactionsSnapshot.insertItems([transaction.transaction],beforeItem: firstItem)
            } else {
                transactionsSnapshot.appendItems([transaction.transaction], toSection: transaction.section)
            }
        } else {
            if let firstSection = transactionsSnapshot.sectionIdentifiers.first {
                transactionsSnapshot.insertSections([transaction.section], beforeSection: firstSection)
            } else {
                transactionsSnapshot.appendSections([transaction.section])
            }
            transactionsSnapshot.appendItems([transaction.transaction], toSection: transaction.section)
        }
        
        transactionsDataSource.apply(transactionsSnapshot, animatingDifferences: false)
    }
    
    private func showNewPageTransactions(_ transactions: [TransactionsSection]) {
        guard !transactions.isEmpty else {
            return
        }
        
        for section in transactions {
            if !transactionsSnapshot.sectionIdentifiers.contains(section.section) {
                transactionsSnapshot.appendSections([section.section])
            }
            
            transactionsSnapshot.appendItems(section.transactions, toSection: section.section)
        }
        
        transactionsDataSource.apply(transactionsSnapshot, animatingDifferences: false)
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset

        if distanceFromBottom < height {
            viewModel.loadMoreTransactions()
        }
    }
}

