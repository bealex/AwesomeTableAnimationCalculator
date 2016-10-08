//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

/**
    Calculation result
 */
public struct ATableDiff {
    public let updatedPaths: [IndexPath]
    public let updatedSectionHeaders: IndexSet

    public let deletedPaths: [IndexPath]
    public let deletedSections: IndexSet

    public let addedPaths: [IndexPath]
    public let addedSections: IndexSet

    public let movedSections: [(Int, Int)]
    public let movedPaths: [(IndexPath, IndexPath)]

    public func isEmpty() -> Bool {
        return updatedPaths.isEmpty &&
            updatedSectionHeaders.isEmpty &&
            deletedPaths.isEmpty &&
            deletedSections.isEmpty &&
            addedPaths.isEmpty &&
            addedSections.isEmpty &&
            movedSections.isEmpty &&
            movedPaths.isEmpty
    }
}
