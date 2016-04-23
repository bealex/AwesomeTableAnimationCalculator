//
// Created by Alexander Babaev on 23.04.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation
import UIKit
import AwesomeTableAnimationCalculator

@objc
class ATableAnimationCalculatorObjC: NSObject {
    private let calculator = ATableAnimationCalculator(cellSectionModel:ACellSectionModelExampleObjC())

    func getCalculator() -> AnyObject? {
        return calculator
    }

    func setItems(items:[ACellModelExampleObjC], andApplyToTableView tableView:UITableView) {
        let diff = try! calculator.setItems(items)
        NSLog("Values: %@", calculator.items)
        diff.applyTo(tableView:tableView)
    }
}
