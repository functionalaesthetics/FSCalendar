//
//  FSCalendarScopeViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 30/12/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

class FSCalendarScopeExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var animationSwitch: UISwitch!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }

        let navbarColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)

        tableView.backgroundColor = navbarColor
        view.backgroundColor = navbarColor

        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: navbarColor)!, for: .default)



        let borderView = UIView()
        borderView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        self.calendar.calendarWeekdayView.addSubview(borderView)

        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: self.calendar.calendarWeekdayView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: self.calendar.calendarWeekdayView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: self.calendar.calendarWeekdayView.bottomAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1),
        ])

        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 55
        self.tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "Cell")


        self.calendar.headerHeight = 0
        self.calendar.weekdayHeight = 40
        self.calendar.calendarWeekdayView.backgroundColor = navbarColor
        self.calendar.scope = .week
        self.calendar.placeholderType = .none
        self.calendar.firstWeekday = 2

        self.calendar.appearance.caseOptions = .weekdayUsesUpperCase
        self.calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.calendar.appearance.weekdayTextColor = .gray
        self.calendar.appearance.selectionColor = UIColor(red: 1, green: 91/255, blue: 0, alpha: 1)
        self.calendar.appearance.todayColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        self.calendar.appearance.titleTodayColor = .black
        self.calendar.appearance.titleSelectionColor = .white
        self.calendar.appearance.titleDefaultColor = .black
        self.calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)

        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"

        self.title = monthDateFormatter.string(from: calendar.currentPage)
    }
    
    deinit {
        print("\(#function)")
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }

    private let monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        title = monthDateFormatter.string(from: calendar.currentPage)
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
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
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let scope: FSCalendarScope = (indexPath.row == 0) ? .month : .week
            self.calendar.setScope(scope, animated: self.animationSwitch.isOn)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Ganztags" : "Tagsüber"
    }
    
    // MARK:- Target actions
    
    @IBAction func toggleClicked(sender: AnyObject) {
        self.calendar.select(Date(timeInterval: 24*60*60*1200, since: calendar.currentPage))

//        if self.calendar.scope == .month {
//            self.calendar.setScope(.week, animated: self.animationSwitch.isOn)
//        } else {
//            self.calendar.setScope(.month, animated: self.animationSwitch.isOn)
//        }
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
