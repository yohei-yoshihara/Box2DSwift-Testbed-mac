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

class WindowController: NSWindowController, NSToolbarDelegate {
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    guard let window = window else { fatalError() }
    
    let toolbar = NSToolbar(identifier: "toolbar")
    toolbar.displayMode = .iconOnly
    toolbar.delegate = self
    window.toolbar = toolbar
    window.toolbarStyle = .unified
    window.title = "Box2D Testbed"
    window.styleMask.insert(.fullSizeContentView)
  }
  
  struct ItemIdentifier {
    static let toggleSidebar = NSToolbarItem.Identifier("toggleSidebar")
    static let play = NSToolbarItem.Identifier("Play")
    static let pause = NSToolbarItem.Identifier("Pause")
    static let singleStep = NSToolbarItem.Identifier("SingleStep")
    static let separator = NSToolbarItem.Identifier("Separator")
  }

  let toolbarItemIdentifiers: [NSToolbarItem.Identifier] = [
    ItemIdentifier.toggleSidebar,
    NSToolbarItem.Identifier.sidebarTrackingSeparator,
    ItemIdentifier.play,
    ItemIdentifier.pause,
    ItemIdentifier.singleStep,
  ]

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return toolbarItemIdentifiers
  }
  
  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return toolbarItemIdentifiers
  }
  
  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier
               itemIdentifier: NSToolbarItem.Identifier,
               willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    switch itemIdentifier {
    case ItemIdentifier.toggleSidebar:
      let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
      toolbarItem.image = NSImage(systemSymbolName: "sidebar.left", accessibilityDescription: "toggle button")
      toolbarItem.isBordered = true
      toolbarItem.target = nil
      toolbarItem.action = #selector(NSSplitViewController.toggleSidebar(_:))
      return toolbarItem
    case ItemIdentifier.play:
      let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
      toolbarItem.image = NSImage(systemSymbolName: "play", accessibilityDescription: "play")
      toolbarItem.isBordered = true
      toolbarItem.target = nil
      toolbarItem.action = #selector(ContainerViewController.onPlay(_:))
      return toolbarItem
    case ItemIdentifier.pause:
      let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
      toolbarItem.image = NSImage(systemSymbolName: "pause", accessibilityDescription: "pause")
      toolbarItem.isBordered = true
      toolbarItem.target = nil
      toolbarItem.action = #selector(ContainerViewController.onPause(_:))
      return toolbarItem
    case ItemIdentifier.singleStep:
      let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
      toolbarItem.image = NSImage(systemSymbolName: "playpause", accessibilityDescription: "single step")
      toolbarItem.isBordered = true
      toolbarItem.target = nil
      toolbarItem.action = #selector(ContainerViewController.onSingleStep(_:))
      return toolbarItem
    default:
      return nil
    }
  }

}

