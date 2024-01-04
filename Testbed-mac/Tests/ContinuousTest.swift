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

import AppKit
import Box2D

class ContinuousTest: TestCase {
  override class var title: String { "Continuous Test" }
  var body: b2Body!
  var angularVelocity: b2Float = 0.0
  var s = String()
  var lastUpdate: CFTimeInterval = 0
  
  override func prepare() {
    b2Locally {
      let bd = b2BodyDef()
      bd.position.set(0.0, 0.0)
      let body = self.world.createBody(bd)
      
      let edge = b2EdgeShape()
      
      edge.set(vertex1: b2Vec2(-10.0, 0.0), vertex2: b2Vec2(10.0, 0.0))
      body.createFixture(shape: edge, density: 0.0)
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 0.2, halfHeight: 1.0, center: b2Vec2(0.5, 1.0), angle: 0.0)
      body.createFixture(shape: shape, density: 0.0)
    }
    
#if true
    b2Locally {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 20.0)
      //bd.angle = 0.1f;
      
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 2.0, halfHeight: 0.1)
      
      self.body = self.world.createBody(bd)
      self.body.createFixture(shape: shape, density: 1.0)
      
      self.angularVelocity = randomFloat(-50.0, 50.0)
      //angularVelocity = 46.661274f;
      self.body.setLinearVelocity(b2Vec2(0.0, -100.0))
      self.body.setAngularVelocity(self.angularVelocity)
    }
#else
    b2Locally {
      var bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 2.0)
      var body = self.world.createBody(bd)!
        
      var shape = b2CircleShape()
      shape.p.setZero()
      shape.radius = 0.5
      body.createFixture(shape, 1.0)
        
      bd.bullet = true
      bd.position.set(0.0, 10.0)
      body = self.world.createBody(bd)!
      body.createFixture(shape, 1.0)
      body.setLinearVelocity(b2Vec2(0.0, -100.0))
    }
#endif
    b2_gjkCalls = 0; b2_gjkIters = 0; b2_gjkMaxIters = 0
    b2_toiCalls = 0; b2_toiIters = 0
    b2_toiRootIters = 0; b2_toiMaxRootIters = 0
    b2_toiTime = 0.0; b2_toiMaxTime = 0.0
  }
  
  override func step() {
    if CACurrentMediaTime() - lastUpdate < 0.3 {
      return
    }
    
    _customView?.update(gjkCalls: b2_gjkCalls,
                        gjkIters: b2_gjkIters,
                        gjkMaxIters: b2_gjkMaxIters,
                        toiCalls: b2_toiCalls,
                        toiIters: b2_toiIters,
                        toiMaxIters: b2_toiMaxIters,
                        toiRootIters: b2_toiRootIters,
                        toiMaxRootIters: b2_toiMaxRootIters)
    
    if stepCount % 60 == 0 {
      //Launch();
    }
  }

  var _customView: GJKView? = nil
  
  override var customView: NSView? {
    if _customView == nil {
      _customView = GJKView(frame: .zero)
    }
    return _customView
  }
}
