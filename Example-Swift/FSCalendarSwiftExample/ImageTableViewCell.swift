//
//  ImageTableViewCell.swift
//  FSCalendarSwiftExample
//
//  Created by Malte Schonvogel on 18.10.17.
//  Copyright © 2017 wenchao. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    let fakeImageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        fakeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fakeImageView)

        NSLayoutConstraint.activate([
            fakeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            fakeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            fakeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            fakeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
