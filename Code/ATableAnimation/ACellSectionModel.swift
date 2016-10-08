//
// Created by Alexander Babaev on 22.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

/**
    Protocol that defines section construction from the table cells.
 */
public protocol ACellSectionModel {
    associatedtype ACellModelType: ACellModel
    associatedtype ASectionModelType: ASectionModelProtocol, Equatable

    /**
        Checks, if two cells are in the same section.
     */
    func cellsHaveSameSection(one: ACellModelType, another: ACellModelType) -> Bool

    /**
        Creates a section for the specified cell.
     */
    func createSection(forCell cell: ACellModelType) -> ASectionModelType
}
