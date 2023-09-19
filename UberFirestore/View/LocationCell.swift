//
//  LocationCell.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 17.09.2023.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {
    
    //MARK: - Properties
    
    private var viewModel: LocationCellViewModel?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "123 Title Street"
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "123 Address Street, Washington, DC"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - API
    
    //MARK: - Actions
    
    //MARK: - Helpers
    
    func configure(viewModel: LocationCellViewModel) {
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.titleText
        addressLabel.text = viewModel.addressText
    }
}
