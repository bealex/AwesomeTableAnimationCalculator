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
    private let dataStorage = ATableAnimationCalculator(cellSectionModel: ACellSectionModelExample())

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ObjCTest()

        dataStorage.cellModelComparator = { lhs, rhs in
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
            flowLayout.headerReferenceSize = CGSize(width:self.view.bounds.size.width, height:20)
        }

        self.view.addSubview(collectionView)

        collectionView.reloadData()

        startTest()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataStorage.sectionsCount()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStorage.itemsCount(inSection:section)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("generalCell", forIndexPath:indexPath)
        cell.selectedBackgroundView?.backgroundColor = UIColor.lightGrayColor()
        if let cellView = cell as? CellViewCollection {
            cellView.label.text = dataStorage.item(forIndexPath:indexPath).text
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:"generalHeader", forIndexPath:indexPath)

        if let headerView = header as? CellHeaderViewCollection {
            let sectionData = dataStorage.section(withIndex:indexPath.section)
            headerView.label.text = "Header: \(sectionData.title)"
        }

        return header
    }
}

extension ViewControllerCollection {
    func update(items addedItems:[ACellModelExample], updateItemsWithIndexes:[Int], deleteItemsWithIndexes:[Int]) {
        var updatedItems:[ACellModelExample] = updateItemsWithIndexes.map { index in
            let updatedValue = ACellModelExample(copy:self.dataStorage.item(withIndex:index))
            updatedValue.text = updatedValue.text + " •"

            return updatedValue
        }

        let deletedItems = deleteItemsWithIndexes.map { index in
            return self.dataStorage.item(withIndex:index)
        }

        updatedItems.appendContentsOf(addedItems)

        print("\n\n\n--------------------------------------------- Updated:")
        print("  " + updatedItems.map({ $0.debugDescription }).joinWithSeparator("\n  "))
        print("--------------------------------------------- Deleted:")
        print("  " + deletedItems.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("--------------------------------------------- Changes:")

        let itemsToAnimate = try! dataStorage.updateItems(addOrUpdate:updatedItems, delete:deletedItems)

        print("--------------------------------------------- NewItems:")
        print("  " + dataStorage.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("---------------------------------------------\n\n")

        itemsToAnimate.applyTo(collectionView:collectionView)
    }

    func initData() {
        try! dataStorage.setItems([
                ACellModelExample(text: "1", header: "A"),
                ACellModelExample(text: "2", header: "B"),
                ACellModelExample(text: "3", header: "B"),
                ACellModelExample(text: "4", header: "C"),
                ACellModelExample(text: "5", header: "C")
        ])

        print("--------------------------------------------- NewItems:")
        print("  " + dataStorage.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("---------------------------------------------\n\n")
    }

    func startTest() {
        let dTime:NSTimeInterval = 1

        var time = NSTimeInterval(dTime)
        dispatch_after_main(time) {
            self.update(
                    items:[
                            ACellModelExample(text:"6", header:"A")
                    ],
                    updateItemsWithIndexes:[2],
                    deleteItemsWithIndexes:[])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[],
                    updateItemsWithIndexes:[],
                    deleteItemsWithIndexes:[1])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[
                            ACellModelExample(text:"10", header:"C"),
                            ACellModelExample(text:"7", header:"D")
                    ],
                    updateItemsWithIndexes:[1],
                    deleteItemsWithIndexes:[])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[],
                    updateItemsWithIndexes:[],
                    deleteItemsWithIndexes:[0, 4])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[
                            ACellModelExample(text:"8", header:"A"),
                            ACellModelExample(text:"9", header:"C")
                    ],
                    updateItemsWithIndexes:[0],
                    deleteItemsWithIndexes:[1])
        }

        time += dTime
        dispatch_after_main(time) {
            self.update(
                    items:[],
                    updateItemsWithIndexes:[0, 1, 2, 3, 4],
                    deleteItemsWithIndexes:[])
        }

        time += dTime
        dispatch_after_main(time) {
            self.dataStorage.cellModelComparator = { rhs, lhs in
                return lhs.header < rhs.header
                       ? true
                       : lhs.header > rhs.header
                               ? false
                               : lhs.text < rhs.text
            }

            print("••••••••••••••••••••••••••••••••••••• RESORTING all... :)")

            let itemsToAnimate = try! self.dataStorage.resortItems()

            print("--------------------------------------------- NewItems:")
            print("  " + self.dataStorage.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
            print("---------------------------------------------\n\n")

            itemsToAnimate.applyTo(collectionView:self.collectionView);
        }

        time += dTime
        dispatch_after_main(time) {
            let moved1 = ACellModelExample(copy:self.dataStorage.items[3])
            let moved2 = ACellModelExample(copy:self.dataStorage.items[0])

            moved1.header = "D"
            moved2.header = "A"

            print("••••••••••••••••••••••••••••••••••••• RESORTING between sections... :)")

            let itemsToAnimate = try! self.dataStorage.updateItems(addOrUpdate:[moved1, moved2], delete:[])

            print("--------------------------------------------- NewItems:")
            print("  " + self.dataStorage.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
            print("---------------------------------------------\n\n")

            itemsToAnimate.applyTo(collectionView:self.collectionView);
        }
    }
}

