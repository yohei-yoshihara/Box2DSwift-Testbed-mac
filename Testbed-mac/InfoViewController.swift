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

class InfoViewController: NSViewController {
  let stackView = NSStackView()
  let infoView = InfoView(frame: .zero)
  
  override func loadView() {
    view = NSView(frame: .zero)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    stackView.orientation = .vertical
    stackView.alignment = .leading
    stackView.spacing = 32
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
      view.bottomAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: 8),
      view.trailingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor, constant: 8),
    ])
    stackView.addArrangedSubview(infoView)
  }
  
  private var _customView: NSView?
  
  var customView: NSView? {
    set {
      if let _customView {
        _customView.removeFromSuperview()
      }
      _customView = newValue
      if let _customView {
        _customView.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertArrangedSubview(_customView, at: 0)
      }
    }
    get {
      return _customView
    }
  }
  
}
