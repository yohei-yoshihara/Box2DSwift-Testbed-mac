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

class ContainerViewController: NSSplitViewController, NSToolbarItemValidation {
  func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
    switch item.itemIdentifier.rawValue {
    case "Play":
      return mainViewController.settings.pause
    case "Pause":
      return !mainViewController.settings.pause
    default:
      break
    }
    return true
  }

  lazy var listViewController = ListViewController()
  lazy var mainViewController = MainViewController()
  lazy var infoViewController = InfoViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let listItem = NSSplitViewItem(sidebarWithViewController: listViewController)
    listItem.minimumThickness = 220
    addSplitViewItem(listItem)
    
    let mainItem = NSSplitViewItem(viewController: mainViewController)
    mainItem.titlebarSeparatorStyle = .shadow
    mainItem.minimumThickness = 480
    addSplitViewItem(mainItem)
    
    let infoItem = NSSplitViewItem(viewController: infoViewController)
    infoItem.minimumThickness = 300
    addSplitViewItem(infoItem)
    
    mainViewController.infoViewController = infoViewController
  }
  
  @IBAction
  func openSettings(_ sender: Any) {
    mainViewController.openSettings(sender)
  }

  @IBAction
  func onPlay(_ sender: Any) {
    mainViewController.onPlay(sender)
  }

  @IBAction
  func onPause(_ sender: Any) {
    mainViewController.onPause(sender)
  }
  
  @IBAction
  func onSingleStep(_ sender: Any) {
    mainViewController.onSingleStep(sender)
  }
}

