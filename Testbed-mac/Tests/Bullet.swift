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

class Bullet: TestCase {
  override class var title: String { "Bullet" }
  
  var body: b2Body!
  var bullet: b2Body!
  var x: b2Float = 0.0
  
  override func prepare() {
    do {
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
    
    do {
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 4.0)
      
      let box = b2PolygonShape()
      box.setAsBox(halfWidth: 2.0, halfHeight: 0.1)
      
      self.body = self.world.createBody(bd)
      self.body.createFixture(shape: box, density: 1.0)
      
      box.setAsBox(halfWidth: 0.25, halfHeight: 0.25)
      
      //x = RandomFloat(-1.0f, 1.0f)
      self.x = 0.20352793
      bd.position.set(self.x, 10.0)
      bd.bullet = true
      
      self.bullet = self.world.createBody(bd)
      self.bullet.createFixture(shape: box, density: 100.0)
      
      self.bullet.setLinearVelocity(b2Vec2(0.0, -50.0))
    }
  }
  
  func launch() {
    body.setTransform(position: b2Vec2(0.0, 4.0), angle: 0.0)
    body.setLinearVelocity(b2Vec2_zero)
    body.setAngularVelocity(0.0)
  
    x = RandomFloat(-1.0, 1.0)
    bullet.setTransform(position: b2Vec2(x, 10.0), angle: 0.0)
    bullet.setLinearVelocity(b2Vec2(0.0, -50.0))
    bullet.setAngularVelocity(0.0)
  
    b2_gjkCalls = 0
    b2_gjkIters = 0
    b2_gjkMaxIters = 0
  
    b2_toiCalls = 0
    b2_toiIters = 0
    b2_toiMaxIters = 0
    b2_toiRootIters = 0
    b2_toiMaxRootIters = 0
  }

  override func step() {
    _customView?.update(gjkCalls: b2_gjkCalls,
                        gjkIters: b2_gjkIters,
                        gjkMaxIters: b2_gjkMaxIters,
                        toiCalls: b2_toiCalls,
                        toiIters: b2_toiIters,
                        toiMaxIters: b2_toiMaxIters,
                        toiRootIters: b2_toiRootIters,
                        toiMaxRootIters: b2_toiMaxRootIters)

    if stepCount % 60 == 0 {
      launch()
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
