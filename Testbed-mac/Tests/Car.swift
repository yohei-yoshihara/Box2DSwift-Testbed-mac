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

class Car: TestCase {
  override class var title: String { return "Car" }
  
  var car: b2Body!
  var wheel1: b2Body!
  var wheel2: b2Body!
  
  var hz: b2Float = 4.0
  let zeta: b2Float = 0.7
  let speed: b2Float = 50.0
  var spring1: b2WheelJoint!
  var spring2: b2WheelJoint!

  var _customView: NSView?
  override var customView: NSView? {
    if _customView == nil {
      let leftButton = NSButton(title: "Left", target: self, action: #selector(onLeft))
      let brakeButton = NSButton(title: "Brake", target: self, action: #selector(onBrake))
      let rightButton = NSButton(title: "Right", target: self, action: #selector(onRight))
      let hzDownButton = NSButton(title: "Hz Down", target: self, action: #selector(onHzDown))
      let hzUpButton = NSButton(title: "Hz Up", target: self, action: #selector(onHzUp))

      let stackView = NSStackView(views: [leftButton, brakeButton, rightButton, hzDownButton, hzUpButton])
      stackView.orientation = .vertical
      stackView.alignment = .leading
      _customView = stackView
    }
    return _customView
  }
  
  @objc func onLeft(_ sender: NSButton) {
    spring1.setMotorSpeed(speed)
  }

  @objc func onBrake(_ sender: NSButton) {
    spring1.setMotorSpeed(0.0)
  }

  @objc func onRight(_ sender: NSButton) {
    spring1.setMotorSpeed(-speed)
  }
  
  @objc func onHzDown(_ sender: NSButton) {
    hz = max(0.0, hz - 1.0)
    spring1.setSpringFrequencyHz(hz)
    spring2.setSpringFrequencyHz(hz)
  }

  @objc func onHzUp(_ sender: NSButton) {
    hz += 1.0
    spring1.setSpringFrequencyHz(hz)
    spring2.setSpringFrequencyHz(hz)
  }


  override func prepare() {
    var ground: b2Body! = nil
    do {
      let bd = b2BodyDef()
      ground = self.world.createBody(bd)
      
      let shape = b2EdgeShape()
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 0.0
      fd.friction = 0.6
      
      shape.set(vertex1: b2Vec2(-20.0, 0.0), vertex2: b2Vec2(20.0, 0.0))
      ground.createFixture(fd)
      
      let hs: [b2Float] = [0.25, 1.0, 4.0, 0.0, 0.0, -1.0, -2.0, -2.0, -1.25, 0.0]
      
      var x: b2Float = 20.0, y1: b2Float = 0.0
      let dx: b2Float = 5.0
      
      for i in 0 ..< 10 {
        let y2 = hs[i]
        shape.set(vertex1: b2Vec2(x, y1), vertex2: b2Vec2(x + dx, y2))
        ground.createFixture(fd)
        y1 = y2
        x += dx
      }
      
      for i in 0 ..< 10 {
        let y2 = hs[i]
        shape.set(vertex1: b2Vec2(x, y1), vertex2: b2Vec2(x + dx, y2))
        ground.createFixture(fd)
        y1 = y2
        x += dx
      }
      
      shape.set(vertex1: b2Vec2(x, 0.0), vertex2: b2Vec2(x + 40.0, 0.0))
      ground.createFixture(fd)
      
      x += 80.0
      shape.set(vertex1: b2Vec2(x, 0.0), vertex2: b2Vec2(x + 40.0, 0.0))
      ground.createFixture(fd)
      
      x += 40.0
      shape.set(vertex1: b2Vec2(x, 0.0), vertex2: b2Vec2(x + 10.0, 5.0))
      ground.createFixture(fd)
      
      x += 20.0
      shape.set(vertex1: b2Vec2(x, 0.0), vertex2: b2Vec2(x + 40.0, 0.0))
      ground.createFixture(fd)
      
      x += 40.0
      shape.set(vertex1: b2Vec2(x, 0.0), vertex2: b2Vec2(x, 20.0))
      ground.createFixture(fd)
    }
    
    // Teeter
    do {
      let bd = b2BodyDef()
      bd.position.set(140.0, 1.0);
      bd.type = b2BodyType.dynamicBody
      let body = self.world.createBody(bd)
      
      let box = b2PolygonShape()
      box.setAsBox(halfWidth: 10.0, halfHeight: 0.25)
      body.createFixture(shape: box, density: 1.0)
      
      let jd = b2RevoluteJointDef()
      jd.initialize(ground, bodyB: body, anchor: body.position)
      jd.lowerAngle = -8.0 * b2_pi / 180.0
      jd.upperAngle = 8.0 * b2_pi / 180.0
      jd.enableLimit = true
      self.world.createJoint(jd)
      
      body.applyAngularImpulse(100.0, wake: true)
    }
    
    // Bridge
    do {
      let N = 20
      let shape = b2PolygonShape()
      shape.setAsBox(halfWidth: 1.0, halfHeight: 0.125)
      
      let fd = b2FixtureDef()
      fd.shape = shape
      fd.density = 1.0
      fd.friction = 0.6
      
      let jd = b2RevoluteJointDef()
      
      var prevBody = ground!
      for i in 0 ..< N {
        let bd = b2BodyDef()
        bd.type = b2BodyType.dynamicBody
        bd.position.set(161.0 + 2.0 * b2Float(i), -0.125)
        let body = self.world.createBody(bd)
        body.createFixture(fd)
        
        let anchor = b2Vec2(160.0 + 2.0 * b2Float(i), -0.125)
        jd.initialize(prevBody, bodyB: body, anchor: anchor)
        self.world.createJoint(jd)
        
        prevBody = body
      }
      
      let anchor = b2Vec2(160.0 + 2.0 * b2Float(N), -0.125)
      jd.initialize(prevBody, bodyB: ground, anchor: anchor)
      self.world.createJoint(jd)
    }
    
    // Boxes
    do {
      let box = b2PolygonShape()
      box.setAsBox(halfWidth: 0.5, halfHeight: 0.5)
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      
      bd.position.set(230.0, 0.5)
      var body = self.world.createBody(bd)
      body.createFixture(shape: box, density: 0.5)
      
      bd.position.set(230.0, 1.5)
      body = self.world.createBody(bd)
      body.createFixture(shape: box, density: 0.5)
      
      bd.position.set(230.0, 2.5)
      body = self.world.createBody(bd)
      body.createFixture(shape: box, density: 0.5)
      
      bd.position.set(230.0, 3.5)
      body = self.world.createBody(bd)
      body.createFixture(shape: box, density: 0.5)
      
      bd.position.set(230.0, 4.5)
      body = self.world.createBody(bd)
      body.createFixture(shape: box, density: 0.5)
    }
    
    // Car
    do {
      let chassis = b2PolygonShape()
      var vertices = [b2Vec2]()
      vertices.append(b2Vec2(-1.5, -0.5))
      vertices.append(b2Vec2(1.5, -0.5))
      vertices.append(b2Vec2(1.5, 0.0))
      vertices.append(b2Vec2(0.0, 0.9))
      vertices.append(b2Vec2(-1.15, 0.9))
      vertices.append(b2Vec2(-1.5, 0.2))
      chassis.set(vertices: vertices)
      
      let circle = b2CircleShape()
      circle.radius = 0.4
      
      let bd = b2BodyDef()
      bd.type = b2BodyType.dynamicBody
      bd.position.set(0.0, 1.0)
      self.car = self.world.createBody(bd)
      self.car.createFixture(shape: chassis, density: 1.0)
      
      let fd = b2FixtureDef()
      fd.shape = circle
      fd.density = 1.0
      fd.friction = 0.9
      
      bd.position.set(-1.0, 0.35)
      self.wheel1 = self.world.createBody(bd)
      self.wheel1.createFixture(fd)
      
      bd.position.set(1.0, 0.4)
      self.wheel2 = self.world.createBody(bd)
      self.wheel2.createFixture(fd)
      
      let jd = b2WheelJointDef()
      let axis = b2Vec2(0.0, 1.0)
      
      jd.initialize(bodyA: self.car, bodyB: self.wheel1, anchor: self.wheel1.position, axis: axis)
      jd.motorSpeed = 0.0
      jd.maxMotorTorque = 20.0
      jd.enableMotor = true
      jd.frequencyHz = self.hz
      jd.dampingRatio = self.zeta
      self.spring1 = self.world.createJoint(jd)
      
      jd.initialize(bodyA: self.car, bodyB: self.wheel2, anchor: self.wheel2.position, axis: axis)
      jd.motorSpeed = 0.0
      jd.maxMotorTorque = 10.0
      jd.enableMotor = false
      jd.frequencyHz = self.hz
      jd.dampingRatio = self.zeta
      self.spring2 = self.world.createJoint(jd)
    }
  }
  
  override func step() {
    settings.viewCenter.x = car.position.x
  }
  
}
