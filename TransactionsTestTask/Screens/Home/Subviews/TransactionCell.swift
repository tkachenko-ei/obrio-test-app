//
//  TransactionCell.swift
//  TransactionsTestTask
//
//

import UIKit

class TransactionCell: UITableViewCell {

    var transaction: Transaction? {
        didSet {
            amountLabel.text = transaction?.amount.formatted(.number.precision(.fractionLength(0...4)))
            categoryLabel.text = transaction?.category?.rawValue.capitalizedSentence
            timeLabel.text = transaction?.date.formatted(date: .omitted, time: .standard)
        }
    }
    
    private lazy var amountLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var categoryLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var layoutConstraints = [
        amountLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
        amountLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
        
        categoryLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4),
        categoryLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
        categoryLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
 
        timeLabel.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
        timeLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor)
    ]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(amountLabel)
        addSubview(categoryLabel)
        addSubview(timeLabel)
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
}

