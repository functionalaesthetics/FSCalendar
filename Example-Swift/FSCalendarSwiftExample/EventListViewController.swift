//
//  EventListViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Malte Schonvogel on 18.10.17.
//  Copyright © 2017 wenchao. All rights reserved.
//

import UIKit
private let sectionHeaderReuseIdentifier = "CalendarSectionHeaderView"

class EventListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    var overScrollPanGestureRecognizer: UIPanGestureRecognizer? {
        didSet {
            guard let recognizer = overScrollPanGestureRecognizer else {
                return
            }

            tableView.panGestureRecognizer.require(toFail: recognizer)
        }
    }
    var date: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = navbarColor
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 55
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 40
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(CalendarSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension EventListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EventListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [2,10][section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ImageTableViewCell
        if indexPath.section == 0 {
            cell.fakeImageView.image = #imageLiteral(resourceName: "fullday")
        } else {
            cell.fakeImageView.image = #imageLiteral(resourceName: "event")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderReuseIdentifier) as! CalendarSectionHeaderView
        header.title = (section == 0 ? "Ganztags" : "Tagsüber").uppercased()
        return header
    }
}

extension EventListViewController: OverScrollable {
    var isOverScrolled: Bool {
        return tableView.contentOffset.y <= -tableView.contentInset.top
    }
}

