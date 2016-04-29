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

    private var iterationIndex = 1

    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        calculator.cellModelComparator = { lhs, rhs in
            if lhs.header < rhs.header {
                return true
            } else {
                if lhs.header > rhs.header {
                    return false
                } else {
                    return Int(lhs.text) < Int(rhs.text)
                }
            }
        }

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

//        runTestFromBundledFile("1.Test_DBZ_small.txt")
//        runTestFromBundledFile("2.Test_Assertion (not working).txt")

        initData()
//        startTest()
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
    func parseLineToACellExample(line:String) -> ACellModelExample {
        let result = ACellModelExample(text:"", header:"")

        let parts = line
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                .componentsSeparatedByString(";")

        for part in parts {
            if part.containsString("Header:") {
                result.header = part
                        .stringByReplacingOccurrencesOfString("Header:", withString:"")
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if result.header.hasPrefix("\"") {
                    result.header = result.header.substringFromIndex(result.header.startIndex.successor())
                }
                if result.header.hasSuffix("\"") {
                    result.header = result.header.substringToIndex(result.header.endIndex.predecessor())
                }
            } else if part.containsString("Text:") {
                result.text = part
                        .stringByReplacingOccurrencesOfString("Text:", withString:"")
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if result.text.hasPrefix("\"") {
                    result.text = result.text.substringFromIndex(result.text.startIndex.successor())
                }
                if result.text.hasSuffix("\"") {
                    result.text = result.text.substringToIndex(result.text.endIndex.predecessor())
                }
            } else if part.containsString("id:") {
                result.id = part
                        .stringByReplacingOccurrencesOfString("id:", withString:"")
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if result.id.hasPrefix("\"") {
                    result.id = result.id.substringFromIndex(result.id.startIndex.successor())
                }
                if result.id.hasSuffix("\"") {
                    result.id = result.id.substringToIndex(result.id.endIndex.predecessor())
                }
            }
        }

        return result
    }

    func runTestFromBundledFile(fileName:String) {
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType:nil)
        let blocks = try! String(contentsOfFile:filePath!).componentsSeparatedByString("\n----------------")

        var initialItems = [ACellModelExample]()
        var addedItems = [ACellModelExample]()
        var updatedItems = [ACellModelExample]()
        var deletedItems = [ACellModelExample]()

        for block in blocks {
            let lines = block.componentsSeparatedByString("\n")

            if block.containsString("--- Old items") {
                for line in lines {
                    if !line.containsString("---") {
                        if !line.isEmpty {
                            initialItems.append(parseLineToACellExample(line))
                        }
                    }
                }
            } else if block.containsString("--- Added") {
                for line in lines {
                    if !line.containsString("---") {
                        if !line.isEmpty {
                            addedItems.append(parseLineToACellExample(line))
                        }
                    }
                }
            } else if block.containsString("--- Updated") {
                for line in lines {
                    if !line.containsString("---") {
                        if !line.isEmpty {
                            updatedItems.append(parseLineToACellExample(line))
                        }
                    }
                }
            } else if block.containsString("--- Deleted") {
                for line in lines {
                    if !line.containsString("---") {
                        if !line.isEmpty {
                            deletedItems.append(parseLineToACellExample(line))
                        }
                    }
                }
            }
        }

        try! calculator.setItems(initialItems)

        updatedItems.appendContentsOf(addedItems)

        dispatch_after_main(1) {
            let itemsToAnimate = try! self.calculator.updateItems(addOrUpdate:updatedItems, delete:deletedItems)
            itemsToAnimate.applyTo(collectionView:self.collectionView) {}
        }
    }
}

// random tests
extension ViewControllerCollection {
    func initData() {
        try! calculator.setItems([
                ACellModelExample(text: "1", header: "A"),
                ACellModelExample(text: "2", header: "B"),
                ACellModelExample(text: "3", header: "C"),
                ACellModelExample(text: "4", header: "D"),
                ACellModelExample(text: "5", header: "E")
        ])

        print("--------------------------------------------- NewItems:")
        print("  " + calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("---------------------------------------------\n\n")

        collectionView.reloadData()
    }

    func randomText() -> String {
        return "\(arc4random_uniform(20))"
    }

    func randomHeader() -> String {
        let code = UInt32("A".utf8.first!) + arc4random_uniform(UInt32("G".utf8.first!) - UInt32("A".utf8.first!))
        return "\(Character(UnicodeScalar(code)))"
    }

    func runRandomTest() {
        let items = calculator.items

        var addedItems = [ACellModelExample]()
        var updatedItems = [ACellModelExample]()
        var deletedItems = [ACellModelExample]()

        let maxItemsInEveryPart = UInt32(5)
//        let maxItemsInEveryPart = UInt32(items.count)

        let addedCount = arc4random_uniform(maxItemsInEveryPart)
        let updatedCount = arc4random_uniform(maxItemsInEveryPart)
        let deletedCount = arc4random_uniform(maxItemsInEveryPart)

        for _ in 0 ..< addedCount {
            addedItems.append(ACellModelExample(text:randomText(), header:randomHeader()))
        }

        var updatedIndexes = [Int]()
        var deletedIndexes = [Int]()

        if items.count != 0 {
            for _ in 0 ..< updatedCount {
                let index = Int(arc4random_uniform(UInt32(items.count)))

                if !updatedIndexes.contains(index) {
                    let updatedItem = ACellModelExample(copy:items[index])
                    updatedItem.text = randomText()
                    if (arc4random_uniform(500) > 250) {
                        updatedItem.header = randomHeader()
                    }

//                    updatedItems.append(updatedItem)
                    updatedIndexes.append(index)
                }
            }

            for _ in 0 ..< deletedCount {
                let index = Int(arc4random_uniform(UInt32(items.count)))

                if !deletedIndexes.contains(index) {
                    let item = items[index]

                    deletedItems.append(ACellModelExample(copy:item))
                    deletedIndexes.append(index)
                }
            }
        }

        print("\n\n\n")
        print("--------------------------------------------- Old items (iteration \(iterationIndex)):")
        print("  " + calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("--------------------------------------------- Added:")
        print("  " + addedItems.map({ $0.debugDescription }).joinWithSeparator(", \n  "))
        print("--------------------------------------------- Updated:")
        print("  " + updatedItems.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("--------------------------------------------- Deleted:")
        print("  " + deletedItems.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("------------------------------------------------------")

        updatedItems.appendContentsOf(addedItems)

        let itemsToAnimate = try! calculator.updateItems(addOrUpdate:updatedItems, delete:deletedItems)

        print("--------------------------------------------- New items:")
        print("  " + calculator.items.map({ $0.debugDescription }).joinWithSeparator(",\n  "))
        print("---------------------------------------------\n\n")

        itemsToAnimate.applyTo(collectionView:collectionView) {
            self.iterationIndex += 1
            dispatch_after_main(1) {
                self.runRandomTest()
            }
        }
    }

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

        itemsToAnimate.applyTo(collectionView:collectionView, completionHandler:nil)
    }

    func startTest() {
        dispatch_after_main(1) {
            self.runRandomTest()
        }
    }
}
