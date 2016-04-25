//
// Created by Alexander Babaev on 22.04.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation
import AwesomeTableAnimationCalculator

class ACellSectionModelExample: ACellSectionModel {
    func cellsHaveSameSection(one one:ACellModelExample, another:ACellModelExample) -> Bool {
        return one.header == another.header
    }

    func createSection(forCell cell:ACellModelExample) -> ASectionModelExample {
        return ASectionModelExample(title:cell.header)
    }
}

class ACellSectionModelExampleObjC: ACellSectionModel {
    func cellsHaveSameSection(one one:ACellModelExampleObjC, another:ACellModelExampleObjC) -> Bool {
        return one.header == another.header
    }

    func createSection(forCell cell:ACellModelExampleObjC) -> ASectionModelExampleObjC {
        return ASectionModelExampleObjC(title:cell.header)
    }
}

