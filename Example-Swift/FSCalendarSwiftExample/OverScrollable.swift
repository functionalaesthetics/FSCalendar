//
// Created by dk on 19.10.17.
// Copyright (c) 2017 wenchao. All rights reserved.
//

import Foundation

protocol OverScrollable {

    var isOverScrolled: Bool { get }
    var overScrollPanGestureRecognizer: UIPanGestureRecognizer? { get set }

}
