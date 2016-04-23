//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation
import AwesomeTableAnimationCalculator

@objc
class ACellModelExample: NSObject, ACellModel {
    var id:String
    var text:String
    var header:String

    init(text:String, header:String) {
        id = NSUUID().UUIDString
        self.text = text
        self.header = header
    }

    required init(copy: ACellModelExample) {
        id = copy.id
        text = copy.text
        header = copy.header
    }

    func contentIsSameAsIn(another: ACellModelExample) -> Bool {
        return text == another.text
    }
}

extension ACellModelExample {
    override var debugDescription: String {
        return "Header: \"\(header)\"; Text: \"\(text)\"; id: \(id)"
    }
}

func ==(lhs: ACellModelExample, rhs: ACellModelExample) -> Bool {
    return lhs.id == rhs.id
}
