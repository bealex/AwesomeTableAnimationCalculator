//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation

/**
 Cell representation for Diff calculation algorithm.

 Equality must determine, if the cell is the same, even when its contents was changed.
 Usually it is something like id-based equals.

 `contentIsSameAsIn` must determine, if cell contents is the same. It is used to find out,
  do we need to reload cell.

  Also, cell must know what section does it belong to. All cells must use the same
  section type.

  Calculator copies cell holders to ensure that it will detect cell changes after their external.
 */
public protocol ACellModel: Equatable {
    /// Copying constructor. It must copy all the cell contents. Otherwise
    /// if it will be changed outside (and simultaneously here), Calculator will not get that.
    init(copy: Self)

    /// Method that checks equality of the cell contents.
    func contentIsSameAsIn(_ another: Self) -> Bool

//    func shortDescription() -> String
}
