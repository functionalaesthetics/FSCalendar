//
//  CalendarSectionHeaderView.swift
//  FSCalendarSwiftExample
//
//  Created by Malte Schonvogel on 18.10.17.
//  Copyright © 2017 wenchao. All rights reserved.
//

import UIKit

class CalendarSectionHeaderView: UITableViewHeaderFooterView {

    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    private let titleLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = navbarColor

        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
