//
//  PageViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Malte Schonvogel on 18.10.17.
//  Copyright © 2017 wenchao. All rights reserved.
//

import UIKit

public class CalendarDayPager: UIViewController {
    let pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    var currentDay: Date? {
        didSet {
            // TODO: Calling currentDay twice. Fix this
            guard let currentPage = pager.viewControllers?.first as? EventListViewController else {
                return
            }

            currentPage.date = currentDay
        }
    }
    var delegate: CalendarDayPagerDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()

        pager.view.backgroundColor = .white
        pager.dataSource = self
        pager.delegate = self

        addChildViewController(pager)
        view.addSubview(pager.view)
        pager.view.frame = view.bounds

        let startPage = EventListViewController()
        startPage.date = currentDay
        pager.setViewControllers([startPage], direction: .forward, animated: false, completion: nil)
    }
}

extension CalendarDayPager: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("viewControllerAfter")
        guard let currentPage = viewController as? EventListViewController else {
            return nil
        }

        let nextDate = currentPage.date?.tommorow

        let nextPage = EventListViewController()
        nextPage.date = nextDate
        return nextPage
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("viewControllerBefore")
        guard let currentPage = viewController as? EventListViewController else {
            return nil
        }

        let nextDate = currentPage.date?.yesterday

        let nextPage = EventListViewController()
        nextPage.date = nextDate
        return nextPage
    }
}

extension CalendarDayPager: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished else {
            return
        }

        guard let currentController = pageViewController.viewControllers?.first as? EventListViewController else {
            return
        }

        currentDay = currentController.date
        print(currentDay)

        guard let currentDay = currentDay else { return }
        delegate?.pagerDidSwitch(to: currentDay)
    }
}

protocol CalendarDayPagerDelegate {
    func pagerDidSwitch(to day: Date)
}

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var tommorow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
}
