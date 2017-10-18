//
//  FSCalendarScopeViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 30/12/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

private let navbarColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
private let lineWidth: CGFloat = 1 / UIScreen.main.scale
private let sectionHeaderReuseIdentifier = "CalendarSectionHeaderView"

class FSCalendarScopeExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let calendar = FSCalendar()
    private var calendarHeightConstraint: NSLayoutConstraint!

    private let monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = { [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var constraints = [NSLayoutConstraint]()

        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: navbarColor)!, for: .default)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)

        view.addGestureRecognizer(scopeGesture)
        view.backgroundColor = navbarColor

        calendar.delegate = self
        calendar.dataSource = self
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.backgroundColor = .white
        calendar.accessibilityIdentifier = "calendar" // For UITest
        calendar.headerHeight = 0
        calendar.weekdayHeight = 40
        calendar.calendarWeekdayView.backgroundColor = navbarColor
        calendar.scope = .week
        calendar.placeholderType = .none
        calendar.firstWeekday = 2

        calendar.appearance.caseOptions = .weekdayUsesUpperCase
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        calendar.appearance.weekdayTextColor = .gray
        calendar.appearance.selectionColor = UIColor(red: 1, green: 91/255, blue: 0, alpha: 1)
        calendar.appearance.todayColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.titleSelectionColor = .white
        calendar.appearance.titleDefaultColor = .black

        calendarHeightConstraint = calendar.heightAnchor.constraint(equalToConstant: 300)

        view.addSubview(calendar)

        constraints += [
            calendar.topAnchor.constraint(equalTo: view.topAnchor),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarHeightConstraint
        ]

        let weekdayBorderBottomView = UIView()
        weekdayBorderBottomView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        weekdayBorderBottomView.translatesAutoresizingMaskIntoConstraints = false
        calendar.calendarWeekdayView.addSubview(weekdayBorderBottomView)

        let calendarBorderBottomView = UIView()
        calendarBorderBottomView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        calendarBorderBottomView.translatesAutoresizingMaskIntoConstraints = false
        calendar.addSubview(calendarBorderBottomView)

        constraints += [
            weekdayBorderBottomView.leadingAnchor.constraint(equalTo: calendar.calendarWeekdayView.leadingAnchor),
            weekdayBorderBottomView.trailingAnchor.constraint(equalTo: calendar.calendarWeekdayView.trailingAnchor),
            weekdayBorderBottomView.bottomAnchor.constraint(equalTo: calendar.calendarWeekdayView.bottomAnchor),
            weekdayBorderBottomView.heightAnchor.constraint(equalToConstant: lineWidth),

            calendarBorderBottomView.leadingAnchor.constraint(equalTo: calendar.leadingAnchor),
            calendarBorderBottomView.trailingAnchor.constraint(equalTo: calendar.trailingAnchor),
            calendarBorderBottomView.bottomAnchor.constraint(equalTo: calendar.bottomAnchor),
            calendarBorderBottomView.heightAnchor.constraint(equalToConstant: lineWidth)
        ]

        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = navbarColor
        tableView.panGestureRecognizer.require(toFail: scopeGesture)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 55
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 40
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(CalendarSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: sectionHeaderReuseIdentifier)

        view.addSubview(tableView)

        constraints += [
            tableView.topAnchor.constraint(equalTo: calendar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = monthDateFormatter.string(from: calendar.currentPage)
    }
    
    deinit {
        print("\(#function)")
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = tableView.contentOffset.y <= -tableView.contentInset.top
        if shouldBegin {
            let velocity = scopeGesture.velocity(in: view)
            switch calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        title = monthDateFormatter.string(from: calendar.currentPage)
        print("\(dateFormatter.string(from: calendar.currentPage))")
    }
    
    // MARK:- UITableViewDataSource
    
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
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

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
