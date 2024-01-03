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
import Box2D

private let initValue = "0.00 [ 0.00] ( 0.00)"

class InfoView: NSStackView {
  let statsGridView = NSGridView()
  let profileGridView = NSGridView()
  
  var enableStats = false {
    didSet {
      statsGridView.isHidden = !enableStats
    }
  }
  var enableProfile = false {
    didSet {
      profileGridView.isHidden = !enableProfile
    }
  }
  weak var world: b2World? = nil
  var maxProfile = b2Profile()
  var totalProfile = b2Profile()
  var lastTimestamp: CFTimeInterval = 0
  
  // Stats
  let bodyCountField = createValueField(labelWithString: "0")
  let contactCountField = createValueField(labelWithString: "0")
  let jointCountField = createValueField(labelWithString: "0")

  let proxyCountField = createValueField(labelWithString: "0")
  let heightField = createValueField(labelWithString: "0")
  let balanceField = createValueField(labelWithString: "0")
  let qualityField = createValueField(labelWithString: "0")
  
  // Profile
  let stepField = createValueField(labelWithString: initValue)
  let collideField = createValueField(labelWithString: initValue)
  let solveField = createValueField(labelWithString: initValue)
  let solveInitField = createValueField(labelWithString: initValue)
  let solveVelocityField = createValueField(labelWithString: initValue)
  let solvePositionField = createValueField(labelWithString: initValue)
  let solveTOIField = createValueField(labelWithString: initValue)
  let broadphaseField = createValueField(labelWithString: initValue)

  override init(frame: CGRect) {
    super.init(frame: frame)
    orientation = .vertical
    addArrangedSubview(statsGridView)
    addArrangedSubview(profileGridView)
    lastTimestamp = CACurrentMediaTime()
    
    let font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
    bodyCountField.font = font
    contactCountField.font = font
    jointCountField.font = font
    
    proxyCountField.font = font
    heightField.font = font
    balanceField.font = font
    qualityField.font = font
    
    stepField.font = font
    collideField.font = font
    solveField.font = font
    solveInitField.font = font
    solveVelocityField.font = font
    solvePositionField.font = font
    solveTOIField.font = font
    broadphaseField.font = font
    
    let statsLabel = NSTextField(labelWithString: "Stats")
    statsLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .large), weight: .bold)
    statsGridView.addRow(with: [statsLabel]).bottomPadding = 3
    statsGridView.addRow(with: [createLabelField(labelWithString: "bodies:"), bodyCountField])
    statsGridView.addRow(with: [createLabelField(labelWithString: "contacts:"), contactCountField])
    statsGridView.addRow(with: [createLabelField(labelWithString: "joints:"), jointCountField]).bottomPadding = 2
    
    statsGridView.addRow(with: [createLabelField(labelWithString: "proxies:"), proxyCountField])
    statsGridView.addRow(with: [createLabelField(labelWithString: "height:"), heightField])
    statsGridView.addRow(with: [createLabelField(labelWithString: "balance:"), balanceField])
    statsGridView.addRow(with: [createLabelField(labelWithString: "quality:"), qualityField]).bottomPadding = 8
    
    let profileLabel = NSTextField(labelWithString: "Profile")
    profileLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .large), weight: .bold)
    profileGridView.addRow(with: [profileLabel]).bottomPadding = 3
    profileGridView.addRow(with: [createLabelField(labelWithString: "step [ave] (max):"), stepField])
    profileGridView.addRow(with: [createLabelField(labelWithString: "collide [ave] (max):"), collideField])
    profileGridView.addRow(with: [createLabelField(labelWithString: "solve [ave] (max):"), solveField])
    profileGridView.addRow(with: [createLabelField(labelWithString: "solve init [ave] (max):"), solveInitField])
    profileGridView.addRow(with: [createLabelField(labelWithString: "solve velocity [ave] (max):"), solveVelocityField])
    profileGridView.addRow(with: [createLabelField(labelWithString: "solve position [ave] (max):"), solvePositionField])
    profileGridView.addRow(with: [createLabelField(labelWithString: "solveTOI [ave] (max):"), solveTOIField])
    profileGridView.addRow(with: [createLabelField(labelWithString: "broad-phase [ave] (max):"), broadphaseField])
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func updateProfile(_ stepCount: Int) {
    guard let world else {
      return
    }
    
    let profile = world.profile
    
    maxProfile.step = max(maxProfile.step, profile.step)
    maxProfile.collide = max(maxProfile.collide, profile.collide)
    maxProfile.solve = max(maxProfile.solve, profile.solve)
    maxProfile.solveInit = max(maxProfile.solveInit, profile.solveInit)
    maxProfile.solveVelocity = max(maxProfile.solveVelocity, profile.solveVelocity)
    maxProfile.solvePosition = max(maxProfile.solvePosition, profile.solvePosition)
    maxProfile.solveTOI = max(maxProfile.solveTOI, profile.solveTOI)
    maxProfile.broadphase = max(maxProfile.broadphase, profile.broadphase)
    
    totalProfile.step += profile.step
    totalProfile.collide += profile.collide
    totalProfile.solve += profile.solve
    totalProfile.solveInit += profile.solveInit
    totalProfile.solveVelocity += profile.solveVelocity
    totalProfile.solvePosition += profile.solvePosition
    totalProfile.solveTOI += profile.solveTOI
    totalProfile.broadphase += profile.broadphase
    
    if enableStats == false && enableProfile == false {
      statsGridView.isHidden = true
      profileGridView.isHidden = true
      return
    }
    if CACurrentMediaTime() - lastTimestamp < 1.0 {
      return
    }
    
    if enableStats {
      let bodyCount = world.bodyCount
      let contactCount = world.contactCount
      let jointCount = world.jointCount
      
      bodyCountField.integerValue = bodyCount
      contactCountField.integerValue = contactCount
      jointCountField.integerValue = jointCount
//      s += String(format:"bodies/contacts/joints = %d/%d/%d\n", bodyCount, contactCount, jointCount)
      
      let proxyCount = world.proxyCount
      let height = world.treeHeight
      let balance = world.treeBalance
      let quality = world.treeQuality
      
      proxyCountField.integerValue = proxyCount
      heightField.integerValue = height
      balanceField.integerValue = balance
      qualityField.floatValue = quality
      qualityField.stringValue = String(format: "%.2f", quality)
    }
    
    if enableProfile {
      var aveProfile = b2Profile()
      if stepCount > 0 {
        let scale = b2Float(1.0) / b2Float(stepCount)
        aveProfile.step = scale * totalProfile.step
        aveProfile.collide = scale * totalProfile.collide
        aveProfile.solve = scale * totalProfile.solve
        aveProfile.solveInit = scale * totalProfile.solveInit
        aveProfile.solveVelocity = scale * totalProfile.solveVelocity
        aveProfile.solvePosition = scale * totalProfile.solvePosition
        aveProfile.solveTOI = scale * totalProfile.solveTOI
        aveProfile.broadphase = scale * totalProfile.broadphase
      }

      stepField.stringValue = String(format: "%5.2f [%6.2f] (%6.2f)", profile.step, aveProfile.step, maxProfile.step)
      collideField.stringValue = String(format: "%5.2f [%6.2f] (%6.2f)", profile.collide, aveProfile.collide, maxProfile.collide)
      solveField.stringValue = String(format: "%5.2f [%6.2f] (%6.2f)", profile.solve, aveProfile.solve, maxProfile.solve)
      solveInitField.stringValue = String(format: "%5.2f [%6.2f] (%6.2f)", profile.solve, aveProfile.solve, maxProfile.solve)
      solveVelocityField.stringValue = String(format: "%5.2f [%6.2f] (%6.2f)", profile.solveVelocity, aveProfile.solveVelocity, maxProfile.solveVelocity)
      solvePositionField.stringValue = String(format: "%5.2f [%6.2f] (%6.2f)", profile.solvePosition, aveProfile.solvePosition, maxProfile.solvePosition)
      solveTOIField.stringValue = String(format: "%5.2f [%6.2f] (%6.2f)", profile.solveTOI, aveProfile.solveTOI, maxProfile.solveTOI)
      broadphaseField.stringValue = String(format: "%5.2f [%6.2f] (%6.2f)", profile.broadphase, aveProfile.broadphase, maxProfile.broadphase)

//      s += String(format: "step [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.step, aveProfile.step, maxProfile.step)
//      s += String(format:  "collide [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.collide, aveProfile.collide, maxProfile.collide)
//      s += String(format:  "solve [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solve, aveProfile.solve, maxProfile.solve)
//      s += String(format:  "solve init [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solveInit, aveProfile.solveInit, maxProfile.solveInit)
//      s += String(format:  "solve velocity [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solveVelocity, aveProfile.solveVelocity, maxProfile.solveVelocity)
//      s += String(format:  "solve position [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solvePosition, aveProfile.solvePosition, maxProfile.solvePosition)
//      s += String(format:  "solveTOI [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.solveTOI, aveProfile.solveTOI, maxProfile.solveTOI)
//      s += String(format:  "broad-phase [ave] (max) = %5.2f [%6.2f] (%6.2f)\n", profile.broadphase, aveProfile.broadphase, maxProfile.broadphase)
    }
    
//    label.text = s
//    label.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
//    label.sizeToFit()
    lastTimestamp = CACurrentMediaTime()
  }
}
