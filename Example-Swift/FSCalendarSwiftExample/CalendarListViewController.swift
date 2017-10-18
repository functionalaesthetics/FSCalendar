//
//  FSCalendarScopeViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 30/12/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import UIKit

let navbarColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
private let lineWidth: CGFloat = 1 / UIScreen.main.scale

class CalendarListViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let calendar = FSCalendar()
    private let dayPager = CalendarDayPager()
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

        dayPager.delegate = self
        dayPager.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dayPager.view)

        constraints += [
            dayPager.view.topAnchor.constraint(equalTo: calendar.bottomAnchor),
            dayPager.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dayPager.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dayPager.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        calendar.select(Date())
        dayPager.currentDay = calendar.selectedDate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = monthDateFormatter.string(from: calendar.currentPage)
    }
    
    deinit {
        print("\(#function)")
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        let shouldBegin = tableView.contentOffset.y <= -tableView.contentInset.top
//        if shouldBegin {
//            let velocity = scopeGesture.velocity(in: view)
//            switch calendar.scope {
//            case .month:
//                return velocity.y < 0
//            case .week:
//                return velocity.y > 0
//            }
//        }
//        return shouldBegin
//    }
}

extension CalendarListViewController: FSCalendarDataSource {

}

extension CalendarListViewController: CalendarDayPagerDelegate {
    func pagerDidSwitch(to day: Date) {
        calendar.select(day)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter
}()

extension CalendarListViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }

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
}
