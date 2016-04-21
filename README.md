### Awesome Table Animation Calculator

There are times when you need to determine what was changed in a table (collection) model to update it with animations. It can be even more complex task when sections are involved. 

Awesome Table Animation Calculator provides simple interface for this task. It holds data model for the table and can calculate animatable difference for some changes (and apply them to the UICollectionView/UITableView afterwards).

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AwesomeTableAnimationCalculator.svg)](https://img.shields.io/cocoapods/v/AwesomeTableAnimationCalculator.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE)
[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=5718f40453d186010052486e&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/5718f40453d186010052486e/build/latest)

###Usage

Implement Cell and Section models. These models define equality for cells (both id-equality and contents equality) and sections. Here is a simple example.

```swift
public class ASectionModelExample: ASectionModel, Equatable {
    public let title:String

    public init(title:String) {
        self.title = title
    }
}

public func ==(lhs:ASectionModelExample, rhs:ASectionModelExample) -> Bool {
    return lhs.title == rhs.title
}
```

Cells are just a little bit harder.

```swift
class ACellModelExample: ACellModel {
    var id:String
    var header:String
    var text:String

    init(text:String, header:String) {
        id = NSUUID().UUIDString
        self.text = text
        self.header = header
    }

    required init(copy:ACellModelExample) {
        id = copy.id
        text = copy.text
        header = copy.header
    }

    func contentIsSameAsIn(another:ACellModelExample) -> Bool {
        return text == another.text
    }

    func hasSameSectionAs(another:ACellModelExample) -> Bool {
        return header == another.header
    }

    func createSection(startIndex startIndex:Int, endIndex:Int) -> ASectionModelExample {
        return ASectionModelExample(title:header, start:startIndex, end:endIndex)
    }
}

func ==(lhs:ACellModelExample, rhs:ACellModelExample) -> Bool {
    return lhs.id == rhs.id
}
```

Create AnimationCalculator and set comparable there for the cells sorting.

```swift
private let calculator = ATableAnimationCalculator<ACellModelExample>()

// somewhere in init or viewDidLoad
calculator.cellModelComparator = { left, right in
    return left.header < right.header
           ? true
           : left.header > right.header
               ? false
               : left.text < right.text
}
```

After that you can use methods of AnimationCalculator for your dataSource methods implementation.


```swift
func numberOfSectionsInTableView(tableView:UITableView) -> Int {
    return calculator.sectionsCount()
}

func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
    return calculator.itemsCount(inSection:section)
}

func tableView(tableView:UITableView, 
        cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("generalCell")
    cell!.textLabel!.text = calculator.item(forIndexPath:indexPath).text
    return cell!
}

func tableView(tableView:UITableView, titleForHeaderInSection section:Int) -> ing? {
    return calculator.section(withIndex:section).title
}
```

Now magic starts. You can simply change whole model like this (no animation yet):

```swift
try! calculator.setItems([
        ACellModelExample(text:"1", header:"A"),
        ACellModelExample(text:"2", header:"B"),
        ACellModelExample(text:"3", header:"B"),
        ACellModelExample(text:"4", header:"C"),
        ACellModelExample(text:"5", header:"C")
])

tableView.reloadData()
```

You can change just a subset of cells (with animation):

```swift
let addedItems = [
    ACellModelExample(text:"2.5", header:"B"),
    ACellModelExample(text:"4.5", header:"C"),
]

let itemsToAnimate = try! calculator.updateItems(addOrUpdate:addedItems, delete:
itemsToAnimate.applyTo(tableView:tableView)
```

If you've changed comparator, you can simply resort model:

```swift
let itemsToAnimate = try! calculator.resortItems()
itemsToAnimate.applyTo(tableView:self.tableView)
```