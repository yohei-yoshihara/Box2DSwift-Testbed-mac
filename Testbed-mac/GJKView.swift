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

class GJKView: NSGridView {
  let gjkCallsField = createValueField(labelWithString: "0")
  let aveGjkItersField = createValueField(labelWithString: "0.0")
  let maxGjkItersField = createValueField(labelWithString: "0")
  
  let toiCallsField = createValueField(labelWithString: "0")
  let aveToiItersField = createValueField(labelWithString: "0.0")
  let maxToiItersField = createValueField(labelWithString: "0")
  
  let aveToiRootItersField = createValueField(labelWithString: "0.0")
  let maxToiRootItersField = createValueField(labelWithString: "0")
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    addRow(with: [createLabelField(labelWithString: "gjk calls:"), gjkCallsField])
    addRow(with: [createLabelField(labelWithString: "ave gjk iters:"), aveGjkItersField])
    addRow(with: [createLabelField(labelWithString: "max gjk iters:"), maxGjkItersField])
    
    addRow(with: [createLabelField(labelWithString: "toi calls:"), toiCallsField])
    addRow(with: [createLabelField(labelWithString: "ave toi iters:"), aveToiItersField])
    addRow(with: [createLabelField(labelWithString: "max toi iters:"), maxToiItersField])
    
    addRow(with: [createLabelField(labelWithString: "ave toi root iters:"), aveToiRootItersField])
    addRow(with: [createLabelField(labelWithString: "max toi root iters:"), maxToiRootItersField])
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func update(gjkCalls: Int, gjkIters: Int, gjkMaxIters: Int,
              toiCalls: Int, toiIters: Int, toiMaxIters: Int,
              toiRootIters: Int, toiMaxRootIters: Int) {
    if gjkCalls > 0 {
      gjkCallsField.integerValue = gjkCalls
      aveGjkItersField.stringValue = String(format: "%3.1f", Float(gjkIters) / Float(gjkCalls))
      maxGjkItersField.integerValue = gjkMaxIters
    }
    
    if toiCalls > 0 {
      toiCallsField.integerValue = toiCalls
      aveToiItersField.stringValue = String(format: "%3.1f", Float(toiIters) / Float(toiCalls))
      maxToiItersField.integerValue = toiMaxIters
      
      aveToiRootItersField.stringValue = String(format: "%3.1f", Float(toiRootIters) / Float(toiCalls))
      maxToiRootItersField.integerValue = toiMaxRootIters
    }
  }
}
