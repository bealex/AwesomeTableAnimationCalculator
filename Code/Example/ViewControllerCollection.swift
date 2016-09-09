//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import UIKit
import AwesomeTableAnimationCalculator

class ViewControllerCollection: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let calculator = ATableAnimationCalculator(cellSectionModel: ACellSectionModelExample())

    private var iterationIndex = 1

    override var prefersStatusBarHidden: Bool {
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
                    return lhs.text < rhs.text
//                    return Int(lhs.text) < Int(rhs.text)
                }
            }
        }

        self.view.backgroundColor = .white

        collectionView.backgroundColor = .clear

        collectionView.frame = self.view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(CellViewCollection.self, forCellWithReuseIdentifier: "generalCell")
        collectionView.register(CellHeaderViewCollection.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "generalHeader")

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.itemSize = CGSize(width: self.view.bounds.size.width, height: 25)
            flowLayout.estimatedItemSize = flowLayout.itemSize
            flowLayout.headerReferenceSize = CGSize(width: self.view.bounds.size.width, height: 20)
        }

        self.view.addSubview(collectionView)

//        runTestFromBundledFile("1.Test_DBZ_small.txt")
//        runTestFromBundledFile("2.Test_Assertion (not working).txt")

//        initBigData()

        initData()
        startTest()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return calculator.sectionsCount()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calculator.itemsCount(inSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "generalCell", for: indexPath)
        cell.selectedBackgroundView?.backgroundColor = .lightGray
        if let cellView = cell as? CellViewCollection {
            cellView.label.text = calculator.item(forIndexPath: indexPath).text
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "generalHeader", for: indexPath)

        if let headerView = header as? CellHeaderViewCollection {
            let sectionData = calculator.section(withIndex: indexPath.section)
            headerView.label.text = "Header: \(sectionData.title)"
        }

        return header
    }

    // MARK: - Helpers

    func parseLineToACellExample(_ line: String) -> ACellModelExample {
        let result = ACellModelExample(text: "", header: "")

        let parts = line
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                .components(separatedBy: ";")

        for part in parts {
            if part.contains("Header: ") {
                result.header = part
                        .replacingOccurrences(of: "Header: ", with: "")
                        .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            } else if part.contains("Text: ") {
                result.text = part
                        .replacingOccurrences(of: "Text: ", with: "")
                        .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            } else if part.contains("id: ") {
                let resultId = part
                        .replacingOccurrences(of: "id: ", with: "")
                        .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\""))

                result.id = NSUUID(uuidString: resultId)!
            }
        }

        return result
    }

    func runTestFromBundledFile(fileName: String) {
        let filePath = Bundle.main.path(forResource: fileName, ofType: nil)
        let blocks = try! String(contentsOfFile: filePath!).components(separatedBy: "\n----------------")

        var initialItems = [ACellModelExample]()
        var addedItems = [ACellModelExample]()
        var updatedItems = [ACellModelExample]()
        var deletedItems = [ACellModelExample]()

        for block in blocks {
            let lines = block.components(separatedBy: "\n")

            if block.contains("--- Old items") {
                for line in lines {
                    if !line.contains("---") {
                        if !line.isEmpty {
                            initialItems.append(parseLineToACellExample(line))
                        }
                    }
                }
            } else if block.contains("--- Added") {
                for line in lines {
                    if !line.contains("---") {
                        if !line.isEmpty {
                            addedItems.append(parseLineToACellExample(line))
                        }
                    }
                }
            } else if block.contains("--- Updated") {
                for line in lines {
                    if !line.contains("---") {
                        if !line.isEmpty {
                            updatedItems.append(parseLineToACellExample(line))
                        }
                    }
                }
            } else if block.contains("--- Deleted") {
                for line in lines {
                    if !line.contains("---") {
                        if !line.isEmpty {
                            deletedItems.append(parseLineToACellExample(line))
                        }
                    }
                }
            }
        }

        let _ = try! calculator.setItems(initialItems)

        updatedItems.append(contentsOf: addedItems)

        dispatch_after_main(1) {
            let itemsToAnimate = try! self.calculator.updateItems(addOrUpdate: updatedItems, delete: deletedItems)
            itemsToAnimate.applyTo(collectionView: self.collectionView) {}
        }
    }

    // MARK: - Random tests

    func initData() {
        let _ = try! calculator.setItems([
                ACellModelExample(text: "1", header: "A"),
                ACellModelExample(text: "2", header: "B"),
                ACellModelExample(text: "3", header: "C"),
                ACellModelExample(text: "4", header: "D"),
                ACellModelExample(text: "5", header: "E")
        ])

        print("--------------------------------------------- NewItems: ")
        print("  " + calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("---------------------------------------------\n\n")

        collectionView.reloadData()
    }

    func initBigData() {
        var headers = [
            "A",
//            "B", "C", "D", "E", "F", "G", "H"
        ]
        var headerIndex = 0

        var bigDataSet: [ACellModelExample] = []
        for i in 1...100000 {
//            bigDataSet.append(ACellModelExample(text: "1", header: headers[headerIndex]))
            bigDataSet.append(ACellModelExample(text: "\(i)", header: headers[headerIndex]))
            headerIndex += 1
            if headerIndex >= headers.count {
                headerIndex = 0
            }
        }

//        calculator.cellModelComparator = nil

        dispatch_async_main {
            Thread.sleep(forTimeInterval: 5)

            let _ = try! self.calculator.setItems(bigDataSet)
            self.collectionView.reloadData()
        }
    }

    func randomText() -> String {
        return "\(arc4random_uniform(20))"
    }

    func randomHeader() -> String {
        let code = UInt32("A".utf8.first!) + arc4random_uniform(UInt32("G".utf8.first!) - UInt32("A".utf8.first!))
        return "\(Character(UnicodeScalar(code)!))"
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
            addedItems.append(ACellModelExample(text: randomText(), header: randomHeader()))
        }

        var updatedIndexes = [Int]()
        var deletedIndexes = [Int]()

        if items.count != 0 {
            for _ in 0 ..< updatedCount {
                let index = Int(arc4random_uniform(UInt32(items.count)))

                if !updatedIndexes.contains(index) {
                    let updatedItem = ACellModelExample(copy: items[index])
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

                    deletedItems.append(ACellModelExample(copy: item))
                    deletedIndexes.append(index)
                }
            }
        }

        print("\n\n\n")
        print("--------------------------------------------- Old items (iteration \(iterationIndex)): ")
        print("  " + calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("--------------------------------------------- Added: ")
        print("  " + addedItems.map({ $0.debugDescription }).joined(separator: ", \n  "))
        print("--------------------------------------------- Updated: ")
        print("  " + updatedItems.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("--------------------------------------------- Deleted: ")
        print("  " + deletedItems.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("------------------------------------------------------")

        updatedItems.append(contentsOf: addedItems)

        let itemsToAnimate = try! calculator.updateItems(addOrUpdate: updatedItems, delete: deletedItems)

        print("--------------------------------------------- New items: ")
        print("  " + calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("---------------------------------------------\n\n")

        itemsToAnimate.applyTo(collectionView: collectionView) {
            self.iterationIndex += 1
            dispatch_after_main(0.6) {
                self.runRandomTest()
            }
        }
    }

    func update(addItems addedItems: [ACellModelExample], updateItemsWithIndexes: [Int], deleteItemsWithIndexes: [Int]) {
        var updatedItems: [ACellModelExample] = updateItemsWithIndexes.map { index in
            let updatedValue = ACellModelExample(copy: self.calculator.item(withIndex: index))
            updatedValue.text = "\(Int(updatedValue.text)! - 2)"
//            updatedValue.text = updatedValue.text + " •"

            return updatedValue
        }

        let deletedItems = deleteItemsWithIndexes.map { index in
            return self.calculator.item(withIndex: index)
        }

        updatedItems.append(contentsOf: addedItems)

        print("\n\n\n--------------------------------------------- Updated: ")
        print("  " + updatedItems.map({ $0.debugDescription }).joined(separator: "\n  "))
        print("--------------------------------------------- Deleted: ")
        print("  " + deletedItems.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("--------------------------------------------- Changes: ")

        let itemsToAnimate = try! calculator.updateItems(addOrUpdate: updatedItems, delete: deletedItems)

        print("--------------------------------------------- NewItems: ")
        print("  " + calculator.items.map({ $0.debugDescription }).joined(separator: ",\n  "))
        print("---------------------------------------------\n\n")

        itemsToAnimate.applyTo(collectionView: collectionView, completionHandler: nil)
    }

    func startTest() {
        dispatch_after_main(1) {
            self.runRandomTest()
        }
    }
}
