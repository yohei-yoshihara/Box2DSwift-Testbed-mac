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
import MetalKit
import Box2D

class MainViewController: NSViewController, RenderViewDelegate, SettingViewControllerDelegate {
  weak var infoViewController: InfoViewController?
  
  lazy var debugDraw = RenderView(frame: .zero)
  
  var testCase: TestCase?
  var world: b2World?
  var groundBody: b2Body?
  var contactListener: ContactListener?
  var bombLauncher: BombLauncher?
  var mouseJoint: b2MouseJoint?
  
  override func loadView() {
    view = NSView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    debugDraw.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(debugDraw)
    NSLayoutConstraint.activate([
      debugDraw.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      debugDraw.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      view.bottomAnchor.constraint(equalTo: debugDraw.bottomAnchor),
      view.trailingAnchor.constraint(equalTo: debugDraw.trailingAnchor),
    ])
    debugDraw.delegate = self
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(testCaseChanged),
                                           name: testCaseChangedNotification, object: nil)
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    didSettingsChanged(settings)
  }
  
  @objc func testCaseChanged(_ notification: NSNotification) {
    guard let testCaseClass = notification.userInfo?["testCase"] as? TestCase.Type else {
      return
    }
    let testCase = testCaseClass.init()
    self.testCase = testCase
    
    debugDraw.metalKitView.preferredFramesPerSecond = Int(settings.hz)
    infoViewController?.customView = testCase.customView

    let gravity = b2Vec2(0.0, -10.0)
    let world = b2World(gravity: gravity)
    let contactListener = ContactListener()
    world.setContactListener(contactListener)
    world.setDebugDraw(debugDraw)
    debugDraw.setFlags(settings.debugDrawFlag)
    
    let bombLauncher = BombLauncher(world: world, renderView: debugDraw, viewCenter: settings.viewCenter)
    infoViewController?.infoView.world = world
    
    testCase.world = world
    testCase.bombLauncher = bombLauncher
    testCase.contactListener = contactListener
    testCase.stepCount = 0
    testCase.debugDraw = debugDraw
    
    let bodyDef = b2BodyDef()
    groundBody = world.createBody(bodyDef)
    
    testCase.prepare()
    
    self.world = world
    self.contactListener = contactListener
    self.bombLauncher = bombLauncher
  }
  
  func simulationLoop(renderView: RenderView) {
    guard let testCase, let world else { return }
    
    updateCoordinate()
    bombLauncher?.render()
    let timeStep = settings.calcTimeStep()
    settings.apply(world)
    contactListener?.clearPoints()
    world.step(timeStep: timeStep,
               velocityIterations: settings.velocityIterations,
               positionIterations: settings.positionIterations)
    world.drawDebugData()
    
    if timeStep > 0.0 {
      testCase.stepCount += 1
    }
    
    infoViewController?.infoView.updateProfile(testCase.stepCount)
    contactListener?.drawContactPoints(settings, renderView: renderView)
    
    testCase.step()
  }
  
  func updateCoordinate() {
    let (lower, upper) = calcViewBounds(viewSize: debugDraw.frame.size,
                                        viewCenter: settings.viewCenter,
                                        extents: Settings.extents)
    debugDraw.setOrtho2D(left: lower.x, right: upper.x, bottom: lower.y, top: upper.y)
  }
  
  var wp = b2Vec2(0, 0)
  
  override func mouseDown(with event: NSEvent) {
    guard let world else { return }
    let p = debugDraw.convert(event.locationInWindow, from: nil)
    wp = convertScreenToWorld(p, size: debugDraw.bounds.size, viewCenter: settings.viewCenter)
    
    let d = b2Vec2(0.001, 0.001)
    var aabb = b2AABB()
    aabb.lowerBound = wp - d
    aabb.upperBound = wp + d
    let callback = QueryCallback(point: wp)
    world.queryAABB(callback: callback, aabb: aabb)
    if callback.fixture != nil {
      let body = callback.fixture!.body
      let md = b2MouseJointDef()
      md.bodyA = groundBody
      md.bodyB = body
      md.target = wp
      md.maxForce = 1000.0 * body.mass
      mouseJoint = world.createJoint(md)
      body.setAwake(true)
    }
    else {
      bombLauncher?.mouseDown(position: wp)
    }
  }
  
  override func mouseDragged(with event: NSEvent) {
    let p = debugDraw.convert(event.locationInWindow, from: nil)
    wp = convertScreenToWorld(p, size: debugDraw.bounds.size, viewCenter: settings.viewCenter)
    
    if let mouseJoint {
      mouseJoint.setTarget(wp)
    }
    else {
      bombLauncher?.mouseDragged(position: wp)
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    let p = debugDraw.convert(event.locationInWindow, from: nil)
    let wp = convertScreenToWorld(p,
                                  size: debugDraw.bounds.size,
                                  viewCenter: settings.viewCenter)
    if mouseJoint != nil {
      world?.destroyJoint(mouseJoint!)
      mouseJoint = nil
    }
    else {
      bombLauncher?.mouseUp(position: wp)
    }
  }
  
  override func mouseExited(with event: NSEvent) {
    bombLauncher?.mouseExited()
  }

  // MARK: Settings
  
  let settings = Settings()
  lazy var settingsViewController = { () -> SettingsViewController in
    let vc = SettingsViewController()
    vc.settings = settings
    vc.delegate = self
    return vc
  }()
  lazy var settingsWindow = NSWindow(contentViewController: settingsViewController)
  
  @IBAction
  func openSettings(_ sender: Any) {
    settingsWindow.makeKeyAndOrderFront(self)
  }

  @IBAction
  func onPlay(_ sender: Any) {
    settings.pause = false
  }

  @IBAction
  func onPause(_ sender: Any) {
    settings.pause = true
  }
  
  @IBAction
  func onSingleStep(_ sender: Any) {
    settings.pause = true
    settings.singleStep = true
  }

  func didSettingsChanged(_ settings: Settings) {
    infoViewController?.infoView.enableProfile = settings.drawProfile
    infoViewController?.infoView.enableStats = settings.drawStats
    debugDraw.metalKitView.preferredFramesPerSecond = Int(settings.hz)
    debugDraw.setFlags(settings.debugDrawFlag)
  }
}

