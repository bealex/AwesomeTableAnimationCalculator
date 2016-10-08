//
// Created by Alexander Babaev on 18.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import Foundation
import UIKit

func dispatch_async_main(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func dispatch_async_background(_ closure: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async(execute: closure)
}

func dispatch_after_main(_ sec: TimeInterval, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + sec, execute: closure)
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
        label.frame = self.contentView.bounds.insetBy(dx: 15, dy: 0)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.backgroundColor = .clear

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
        self.backgroundColor = UIColor(colorLiteralRed: 0.95, green: 0.95, blue: 0.95, alpha: 1)

        label.frame = self.bounds.insetBy(dx: 15, dy: 0)
        label.frame.origin.y += 0

        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 9)

        self.addSubview(label)
    }
}
