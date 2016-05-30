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
    public let updatedPaths:[NSIndexPath]
    public let updatedSectionHeaders:NSIndexSet

    public let deletedPaths:[NSIndexPath]
    public let deletedSections:NSIndexSet

    public let addedPaths:[NSIndexPath]
    public let addedSections:NSIndexSet

    public let movedSections:[(Int, Int)]
    public let movedPaths:[(NSIndexPath, NSIndexPath)]
    
    public func isEmpty() -> Bool {
        return updatedPaths.count == 0 &&
            updatedSectionHeaders.count == 0 &&
            deletedPaths.count == 0 &&
            deletedSections.count == 0 &&
            addedPaths.count == 0 &&
            addedSections.count == 0 &&
            movedSections.count == 0 &&
            movedPaths.count == 0
    }
}
