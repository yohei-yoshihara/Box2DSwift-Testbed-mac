/**
 Copyright (c) 2006-2014 Erin Catto http://www.box2d.org
 Copyright (c) 2015 - Yohei Yoshihara
 
 This software is provided 'as-is', without any express or implied
 warranty.  In no event will the authors be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must not
 claim that you wrote the original software. If you use this software
 in a product, an acknowledgment in the product documentation would be
 appreciated but is not required.
 
 2. Altered source versions must be plainly marked as such, and must not be
 misrepresented as being the original software.
 
 3. This notice may not be removed or altered from any source distribution.
 
 This version of box2d was developed by Yohei Yoshihara. It is based upon
 the original C++ code written by Erin Catto.
 */

import Cocoa

let testCaseChangedNotification = NSNotification.Name("testCaseChangedNotification")

class ListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
  lazy var tableView = NSTableView(frame: .zero)
  lazy var scrollView = NSScrollView(frame: .zero)
  
  struct ItemIdentifier {
    static let column = NSUserInterfaceItemIdentifier("column")
  }

  override func loadView() {
    view = NSView(frame: .zero)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.intercellSpacing = NSSize(width: 16, height: 8)
    tableView.gridStyleMask = [.dashedHorizontalGridLineMask]
    tableView.usesAutomaticRowHeights = true
    tableView.dataSource = self
    tableView.delegate = self
    tableView.headerView = nil
    tableView.allowsEmptySelection = false
    tableView.allowsMultipleSelection = false
    
    let column = NSTableColumn(identifier: ItemIdentifier.column)
    tableView.addTableColumn(column)
    
    scrollView.documentView = tableView
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
    ])
  }

  func numberOfRows(in tableView: NSTableView) -> Int {
    return testCases.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    var tableCellView: TableCellView
    if let reuse = tableView.makeView(withIdentifier: ItemIdentifier.column, owner: self) as? TableCellView {
      tableCellView = reuse
    } else {
      tableCellView = TableCellView(frame: .zero)
      tableCellView.identifier = ItemIdentifier.column
    }
    tableCellView.titleTextField.stringValue = testCases[row].title
    return tableCellView
  }

  func tableViewSelectionDidChange(_ notification: Notification) {
    NotificationCenter.default.post(name: testCaseChangedNotification, 
                                    object: self,
                                    userInfo: ["testCase": testCases[tableView.selectedRow]])
  }
  
  class TableCellView : NSView {
    let titleTextField = NSTextField(labelWithString: "")
    
    override init(frame frameRect: NSRect) {
      super.init(frame: frameRect)
      titleTextField.textColor = NSColor.labelColor
      titleTextField.translatesAutoresizingMaskIntoConstraints = false
      addSubview(titleTextField)
      NSLayoutConstraint.activate([
        titleTextField.topAnchor.constraint(equalTo: topAnchor, constant: 4),
        titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
        bottomAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 4),
        trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor, constant: 4),
      ])
    }
    
    required init?(coder: NSCoder) {
      fatalError()
    }
  }

}
