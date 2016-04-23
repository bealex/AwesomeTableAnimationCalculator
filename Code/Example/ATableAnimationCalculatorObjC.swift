//
// Created by Alexander Babaev on 23.04.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation
import UIKit
import AwesomeTableAnimationCalculator

@objc
class ATableAnimationCalculatorObjC: NSObject {
    private let calculator = ATableAnimationCalculator(cellSectionModel:ACellSectionModelExample())

    func getCalculator() -> AnyObject? {
        return calculator
    }

    func setItems(items:[ACellModelExample], andApplyToTableView tableView:UITableView) {
        try! calculator.setItems(items).applyTo(tableView:tableView)
    }
}
