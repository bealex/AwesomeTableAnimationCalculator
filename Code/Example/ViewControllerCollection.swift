//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import UIKit
import AwesomeTableAnimationCalculator

class ViewControllerCollection: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let collectionView:UICollectionView = UICollectionView(frame:CGRectZero, collectionViewLayout:UICollectionViewFlowLayout())
    private let calculator = ATableAnimationCalculator(cellSectionModel: ACellSectionModelExample())

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        calculator.cellModelComparator = { lhs, rhs in
            return lhs.header < rhs.header
                   ? true
                   : lhs.header > rhs.header
                           ? false
                           : lhs.text < rhs.text
        }

        initData()

        self.view.backgroundColor = UIColor.whiteColor()

        collectionView.backgroundColor = UIColor.clearColor()

        collectionView.frame = self.view.bounds
        collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        collectionView.alwaysBounceVertical = true

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.registerClass(CellViewCollection.self, forCellWithReuseIdentifier:"generalCell")
        collectionView.registerClass(CellHeaderViewCollection.self, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier:"generalHeader")

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .Vertical
            flowLayout.itemSize = CGSize(width:self.view.bounds.size.width, height:25)
            flowLayout.estimatedItemSize = flowLayout.itemSize
            flowLayout.headerReferenceSize = CGSize(width:self.view.bounds.size.width, height:20)
        }

        self.view.addSubview(collectionView)

        collectionView.reloadData()

        startTest()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return calculator.sectionsCount()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calculator.itemsCount(inSection:section)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("generalCell", forIndexPath:indexPath)
        cell.selectedBackgroundView?.backgroundColor = UIColor.lightGrayColor()
        if let cellView = cell as? CellViewCollection {
            cellView.label.text = calculator.item(forIndexPath:indexPath).text
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:"generalHeader", forIndexPath:indexPath)

        if let headerView = header as? CellHeaderViewCollection {
            let sectionData = calculator.section(withIndex:indexPath.section)
            headerView.label.text = "Header: \(sectionData.title)"
        }

        return header
    }
}

extension ViewControllerCollection {
    func update(addItems addedItems:[ACellModelExample], updateItemsWithIndexes:[Int], deleteItemsWithIndexes:[Int]) {
        var updatedItems:[ACellModelExample] = updateItemsWithIndexes.map { index in
            let updatedValue = ACellModelExample(copy:self.calculator.item(withIndex:index))
            updatedValue.text = "\(Int(updatedValue.text)! - 2)"
//            updatedValue.text = updatedValue.text + " •"

            return updatedValue
        }

        let deletedItems = deleteItemsWithIndexes.map { index in
            return self.calculator.item(withIndex:index)
        }

        updatedItems.appendContentsOf(addedItems)

        print("\n\n\n--------------------------------------------- Updated:")
        print("  " + updatedItems.map({ $0.debugDescription }).joinWithSeparator("\n  "))
        print("--------------------------------------------- Deleted:")
        print("  " + deletedItems.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("--------------------------------------------- Changes:")

        let itemsToAnimate = try! calculator.updateItems(addOrUpdate:updatedItems, delete:deletedItems)

        print("--------------------------------------------- NewItems:")
        print("  " + calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("---------------------------------------------\n\n")

        itemsToAnimate.applyTo(collectionView:collectionView)
    }

    func initData() {
        try! calculator.setItems([
                ACellModelExample(text: "1", header: "A"),
                ACellModelExample(text: "2", header: "B"),
                ACellModelExample(text: "3", header: "B"),
                ACellModelExample(text: "4", header: "C"),
                ACellModelExample(text: "5", header: "C")
        ])

        print("--------------------------------------------- NewItems:")
        print("  " + calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("---------------------------------------------\n\n")
    }

    func startTest() {
        let dTime:NSTimeInterval = 1

        var time = NSTimeInterval(dTime)
        dispatch_after_main(time) {
            self.update(
                    addItems:[
                            ACellModelExample(text:"6", header:"A")
                    ],
                    updateItemsWithIndexes:[2],
                    deleteItemsWithIndexes:[])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    addItems:[],
                    updateItemsWithIndexes:[],
                    deleteItemsWithIndexes:[1])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    addItems:[
                            ACellModelExample(text:"10", header:"C"),
                            ACellModelExample(text:"7", header:"D")
                    ],
                    updateItemsWithIndexes:[1],
                    deleteItemsWithIndexes:[])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    addItems:[],
                    updateItemsWithIndexes:[],
                    deleteItemsWithIndexes:[0, 4])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    addItems:[
                            ACellModelExample(text:"8", header:"A"),
                            ACellModelExample(text:"9", header:"C")
                    ],
                    updateItemsWithIndexes:[0],
                    deleteItemsWithIndexes:[1])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    addItems:[],
                    updateItemsWithIndexes:[0, 1, 2, 3, 4],
                    deleteItemsWithIndexes:[])
        }

        time += dTime
        dispatch_after_main(time) {
            self.calculator.cellModelComparator = { rhs, lhs in
                return lhs.header < rhs.header
                       ? true
                       : lhs.header > rhs.header
                               ? false
                               : lhs.text < rhs.text
            }

            print("••••••••••••••••••••••••••••••••••••• RESORTING all... :)")

            let itemsToAnimate = try! self.calculator.resortItems()

            print("--------------------------------------------- NewItems:")
            print("  " + self.calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
            print("---------------------------------------------\n\n")

            itemsToAnimate.applyTo(collectionView:self.collectionView);
        }

        time += dTime
        dispatch_after_main(time) {
            let moved1 = ACellModelExample(copy:self.calculator.items[3])
            let moved2 = ACellModelExample(copy:self.calculator.items[0])

            moved1.header = "D"
            moved2.header = "A"

            print("••••••••••••••••••••••••••••••••••••• RESORTING between sections... :)")

            let itemsToAnimate = try! self.calculator.updateItems(addOrUpdate:[moved1, moved2], delete:[])

            print("--------------------------------------------- NewItems:")
            print("  " + self.calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
            print("---------------------------------------------\n\n")

            itemsToAnimate.applyTo(collectionView:self.collectionView);
        }
    }
}

