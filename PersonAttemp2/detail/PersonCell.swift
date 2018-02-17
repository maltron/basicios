//
//  PersonCell.swift
//  PersonAttemp2
//
//  Created by Mauricio Leal on 2/15/18.
//  Copyright © 2018 Mauricio Leal. All rights reserved.
//

import UIKit

class PersonCell: UITableViewCell {
    
    let DEFAULT_SPACE: CGFloat = CGFloat(16.0)
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        
        return label
    }()
    
    let textfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textfield.textAlignment = .right
        textfield.autocapitalizationType = .words
        textfield.autocorrectionType = .no
        textfield.keyboardType = .default
        textfield.returnKeyType = .default
        textfield.clearButtonMode = .whileEditing
        
        return textfield
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Disable selection
        selectionStyle = .none
        
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(label)
        NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: DEFAULT_SPACE).isActive = true

        addSubview(textfield)
        NSLayoutConstraint(item: textfield, attribute: .firstBaseline, relatedBy: .equal, toItem: label, attribute: .firstBaseline, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: textfield, attribute: .leading, relatedBy: .equal, toItem: label, attribute: .trailing, multiplier: 1.0, constant: DEFAULT_SPACE).isActive = true
        NSLayoutConstraint(item: textfield, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -DEFAULT_SPACE).isActive = true
    }
}
