//
// Created by Alexander Babaev on 18.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT
//

import Foundation
import UIKit


func dispatch_async_main(closure:() -> Void) {
    dispatch_async(dispatch_get_main_queue(), closure)
}

func dispatch_async_background(closure:() -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), closure)
}

func dispatch_after_main(sec:NSTimeInterval, closure:() -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(sec*Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}


class CellViewCollection: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createLabel()
    }

    func createLabel() {
        label.frame = self.contentView.bounds.insetBy(dx:15, dy:0)
        label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        label.backgroundColor = UIColor.clearColor()

        self.contentView.addSubview(label)
    }
}


class CellHeaderViewCollection: UICollectionReusableView {
    let label = UILabel()

    override var reuseIdentifier: String? {
        get {
            return "generalHeader"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        createLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createLabel()
    }

    func createLabel() {
        self.backgroundColor = UIColor(colorLiteralRed:0.95, green:0.95, blue:0.95, alpha:1)

        label.frame = self.bounds.insetBy(dx:15, dy:0)
        label.frame.origin.y += 0

        label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.boldSystemFontOfSize(9)

        self.addSubview(label)
    }
}
