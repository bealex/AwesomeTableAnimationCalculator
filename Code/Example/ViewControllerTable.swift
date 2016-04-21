//
//  ViewControllerTable.swift
//  CollectionViewDataStorage
//
//  Created by Alexander Babaev on 17.04.16.
//  Copyright © 2016 LonelyBytes. All rights reserved.
//

import UIKit

class ViewControllerTable: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView:UITableView = UITableView(frame:CGRectZero, style:UITableViewStyle.Plain)
    private let dataStorage = ATableAnimationCalculator<ACellModelExample>()

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataStorage.comparator = { left, right in
            return left.header < right.header
                   ? true
                   : left.header > right.header
                       ? false
                       : left.text < right.text
        }

        initData()

        self.view.backgroundColor = UIColor.whiteColor()

        tableView.backgroundColor = UIColor.clearColor()

        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.alwaysBounceVertical = true

        tableView.dataSource = self
        tableView.delegate = self

        self.view.addSubview(tableView)

        tableView.reloadData()

        startTest()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataStorage.sectionsCount()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStorage.itemsCount(inSection:section)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("generalCell")
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier:"generalCell")
        }
        cell!.textLabel!.text = dataStorage.item(forIndexPath:indexPath).text
        return cell!
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionData = dataStorage.section(withIndex:section)
        return "Header: \(sectionData.title)"
    }
}

extension ViewControllerTable {
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

        itemsToAnimate.applyTo(tableView:tableView)
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
            self.dataStorage.comparator = { rhs, lhs in
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

            itemsToAnimate.applyTo(tableView:self.tableView);
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

            itemsToAnimate.applyTo(tableView:self.tableView);
        }
    }
}

