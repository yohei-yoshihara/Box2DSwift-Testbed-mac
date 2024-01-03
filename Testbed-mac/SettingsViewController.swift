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

protocol SettingViewControllerDelegate: AnyObject {
  func didSettingsChanged(_ settings: Settings)
}

class SettingsViewController: NSTabViewController {
  static let lastPreferencesPaneIdentifier = "SettingsViewController.lastPreferencesPaneIdentifier"
  static let inset: CGFloat = 16
  var lastFrameSize: NSSize = .zero

  weak var settings: Settings? = nil {
    didSet {
      basicSettingsViewController.settings = settings
      drawSettingsViewController.settings = settings
    }
  }
  weak var delegate: SettingViewControllerDelegate? = nil {
    didSet {
      basicSettingsViewController.delegate = delegate
      drawSettingsViewController.delegate = delegate
    }
  }

  lazy var basicSettingsViewController = BasicSettingsViewController()
  lazy var drawSettingsViewController = DrawSettingsViewController()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tabStyle = .toolbar
    
    let basicItem = NSTabViewItem(viewController: basicSettingsViewController)
    basicItem.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!
    basicItem.label = "Basic"
    addTabViewItem(basicItem)
    
    let drawItem = NSTabViewItem(viewController: drawSettingsViewController)
    drawItem.image = NSImage(systemSymbolName: "pencil", accessibilityDescription: nil)!
    drawItem.label = "Draw"
    addTabViewItem(drawItem)
    
    if let identifier = UserDefaults.standard.object(forKey: SettingsViewController.lastPreferencesPaneIdentifier) as? String {
      for i in 0 ..< tabViewItems.count {
        let item = tabViewItems[i]
        if item.identifier as? String == identifier {
          selectedTabViewItemIndex = i
        }
      }
    }
  }

  override var selectedTabViewItemIndex: Int {
    didSet {
      if self.isViewLoaded {
        UserDefaults.standard.set(self.tabViewItems[selectedTabViewItemIndex].identifier as? String, forKey: SettingsViewController.lastPreferencesPaneIdentifier)
      }
    }
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    self.view.window!.title = self.tabViewItems[self.selectedTabViewItemIndex].label
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    if let window = view.window {
      window.styleMask.remove(.resizable)
    }
  }
  
  override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
    super.tabView(tabView, willSelect: tabViewItem)
    
    if let size = tabViewItem?.view?.frame.size {
      lastFrameSize = size
    }
  }
  
  override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
    super.tabView(tabView, willSelect: tabViewItem)
    
    guard let tabViewItem = tabViewItem else { return assertionFailure() }
    
    self.switchPane(to: tabViewItem)
  }
  
  private func switchPane(to tabViewItem: NSTabViewItem) {
    guard let gridView = tabViewItem.view?.subviews.first as? NSGridView else {
      return assertionFailure()
    }
    let inset = SettingsViewController.inset
    let gridViewSize = gridView.fittingSize
    let contentSize = NSSize(width: gridViewSize.width + inset*2,
                             height: gridViewSize.height + inset*2);
    
    guard let window = self.view.window else {
      self.view.frame.size = contentSize
      return
    }
    
    NSAnimationContext.runAnimationGroup({ _ in
      self.view.isHidden = true
      
      let frameSize = window.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize)).size
      let frame = NSRect(origin: window.frame.origin, size: frameSize)
        .offsetBy(dx: 0, dy: window.frame.height - frameSize.height)
      window.animator().setFrame(frame, display: false)
      
    }, completionHandler: { [weak self] in
      self?.view.isHidden = false
      window.title = tabViewItem.label
    })
  }
  
}

class BasicSettingsViewController : NSViewController {
  weak var settings: Settings? = nil {
    didSet {
      guard let settings else { return }
      velocityIterationsField.integerValue = settings.velocityIterations
      positionIterationsField.integerValue = settings.positionIterations
      hertzPopupButton.selectItem(at: settings.hz == 30.0 ? 1 : 0)
      sleepSwitch.state = settings.enableSleep ? .on : .off
      warmStartingSwitch.state = settings.enableWarmStarting ? .on : .off
      timeOfImpactSwitch.state = settings.enableContinuous ? .on : .off
      subSteppingSwitch.state = settings.enableSubStepping ? .on : .off
    }
  }
  weak var delegate: SettingViewControllerDelegate? = nil

  // MARK: row 1: Velocity Iterations
  let velocityIterationsField = NSTextField(string: "8")
  let velocityIterationsStepper = NSStepper(frame: .zero)

  @objc func onVelocityIterationsStepperAction(sender: NSStepper) {
    guard let settings else { return }
    
    view.window?.makeFirstResponder(velocityIterationsField)
    velocityIterationsField.integerValue = velocityIterationsStepper.integerValue
    
    settings.velocityIterations = positionIterationsField.integerValue
    delegate?.didSettingsChanged(settings)
  }

  @objc func onVelocityIterationsFieldChanged(sender: NSTextField) {
    guard let settings else { return }
    settings.velocityIterations = velocityIterationsField.integerValue
    delegate?.didSettingsChanged(settings)
  }
  
  // MARK: row 2: Position Iterations
  let positionIterationsField = NSTextField(string: "3")
  let positionIterationsStepper = NSStepper(frame: .zero)

  @objc func onPositionIterationsStepperAction(sender: NSStepper) {
    guard let settings else { return }
    
    view.window?.makeFirstResponder(positionIterationsField)
    positionIterationsField.integerValue = positionIterationsStepper.integerValue
    
    settings.positionIterations = positionIterationsField.integerValue
    delegate?.didSettingsChanged(settings)
  }

  @objc func onPositionIterationsFieldChanged(sender: NSTextField) {
    guard let settings else { return }
    settings.positionIterations = positionIterationsField.integerValue
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 3: Hertz
  let hertzPopupButton = NSPopUpButton(frame: .zero, pullsDown: false)

  @objc func onHertzPopupButtonAction(sender: NSPopUpButton) {
    guard let settings else { return }
    settings.hz = hertzPopupButton.indexOfSelectedItem == 1 ? 30 : 60
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 4: Sleep
  let sleepLabel = NSTextField(labelWithString: "Sleep:")
  
  lazy var sleepSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(BasicSettingsViewController.onSleepChanged)
    return ctl
  }()

  @objc func onSleepChanged(sender: Any) {
    guard let settings else { return }
    settings.enableSleep = sleepSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }
  
  // MARK: row 5: Warm Start
  let warmStartingLabel = NSTextField(labelWithString: "Warm Starting:")
  
  lazy var warmStartingSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(BasicSettingsViewController.onWarmStartChanged)
    return ctl
  }()

  @objc func onWarmStartChanged(sender: Any) {
    guard let settings else { return }
    settings.enableWarmStarting = warmStartingSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }
  
  // MARK: row 6: Time of Impact
  let timeOfImpactLabel = NSTextField(labelWithString: "Time of Impact:")
  
  lazy var timeOfImpactSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(BasicSettingsViewController.onTimeOfImpactChanged)
    return ctl
  }()
  
  @objc func onTimeOfImpactChanged(sender: Any) {
    guard let settings else { return }
    settings.enableContinuous = timeOfImpactSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }
  
  // MARK: row 7: Sub-Stepping
  let subSteppingLabel = NSTextField(labelWithString: "Sub-Stepping:")
  
  lazy var subSteppingSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(BasicSettingsViewController.onSubSteppingChanged)
    return ctl
  }()
  
  @objc func onSubSteppingChanged(sender: Any) {
    guard let settings else { return }
    settings.enableSubStepping = subSteppingSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: loadView
  override func loadView() {
    view = NSView(frame: .zero)
  }

  // MARK: viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Basic"
    
    // MARK: row 1: Velocity Iterations
    let velocityIterationsLabel = NSTextField(labelWithString: "Velocity Iterations:")
    
    velocityIterationsField.formatter = NumberFormatter()
    velocityIterationsField.placeholderString = "8"
    velocityIterationsField.target = self
    velocityIterationsField.action = #selector(onVelocityIterationsFieldChanged)
    
    velocityIterationsStepper.minValue = 0
    velocityIterationsStepper.maxValue = 100
    velocityIterationsStepper.increment = 1
    velocityIterationsStepper.integerValue = 8
    velocityIterationsStepper.valueWraps = false
    velocityIterationsStepper.target = self
    velocityIterationsStepper.action = #selector(onVelocityIterationsStepperAction)

    let velocityIterationsStack = NSStackView(views: [velocityIterationsField, velocityIterationsStepper])
    velocityIterationsStack.orientation = .horizontal
    
    // MARK: row 2: Position Iterations
    let positionIterationsLabel = NSTextField(labelWithString: "Position Iterations:")
    
    positionIterationsField.formatter = NumberFormatter()
    positionIterationsField.placeholderString = "3"
    positionIterationsField.target = self
    positionIterationsField.action = #selector(onPositionIterationsFieldChanged)
    
    positionIterationsStepper.minValue = 0
    positionIterationsStepper.maxValue = 100
    positionIterationsStepper.increment = 1
    positionIterationsStepper.integerValue = 3
    positionIterationsStepper.valueWraps = false
    positionIterationsStepper.target = self
    positionIterationsStepper.action = #selector(onPositionIterationsStepperAction)

    let positionIterationsStack = NSStackView(views: [positionIterationsField, positionIterationsStepper])
    positionIterationsStack.orientation = .horizontal

    // MARK: row 3: Hertz
    let hertzLabel = NSTextField(labelWithString: "Hertz:")

    hertzPopupButton.addItems(withTitles: ["60 Hz", "30 Hz"])
    hertzPopupButton.target = self
    hertzPopupButton.action = #selector(onHertzPopupButtonAction)
    
    let gridView = NSGridView(views: [
      [velocityIterationsLabel, velocityIterationsStack],
      [positionIterationsLabel, positionIterationsStack],
      [hertzLabel, hertzPopupButton],
      [sleepLabel, sleepSwitch],
      [warmStartingLabel, warmStartingSwitch],
      [timeOfImpactLabel, timeOfImpactSwitch],
      [subSteppingLabel, subSteppingSwitch],
    ])
    gridView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(600),
                                                     for: .horizontal)
    gridView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(600),
                                                     for: .vertical)
    gridView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(gridView)
    let inset = SettingsViewController.inset
    NSLayoutConstraint.activate([
      gridView.topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
      gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
      view.bottomAnchor.constraint(greaterThanOrEqualTo: gridView.bottomAnchor, constant: inset),
      view.trailingAnchor.constraint(greaterThanOrEqualTo: gridView.trailingAnchor, constant: inset),
    ])
    
    gridView.column(at: 0).xPlacement = .trailing
    gridView.rowSpacing = 12
    gridView.columnSpacing = 8
  }
}

class DrawSettingsViewController : NSViewController {
  weak var settings: Settings? = nil {
    didSet {
      guard let settings else { return }
      shapesSwitch.state = settings.drawShapes ? .on : .off
      jointsSwitch.state = settings.drawJoints ? .on : .off
      aabbsSwitch.state = settings.drawAABBs ? .on : .off
      contactPointsSwitch.state = settings.drawContactPoints ? .on : .off
      contactNormalsSwitch.state = settings.drawContactNormals ? .on : .off
      contactImpulsesSwitch.state = settings.drawContactImpulse ? .on : .off
      frictionImpulsesSwitch.state = settings.drawFrictionImpulse ? .on : .off
      centerOfMassesSwitch.state = settings.drawCOMs ? .on : .off
      statisticsSwitch.state = settings.drawStats ? .on : .off
      profileSwitch.state = settings.drawProfile ? .on : .off
    }
  }
  weak var delegate: SettingViewControllerDelegate? = nil
  
  // MARK: row 1: Shapes
  let shapesLabel = NSTextField(labelWithString: "Shapes:")

  lazy var shapesSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onShapesChanged)
    return ctl
  }()

  @objc func onShapesChanged(sender: Any) {
    guard let settings else { return }
    settings.drawShapes = shapesSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 2: Joints
  let jointsLabel = NSTextField(labelWithString: "Joints:")
  
  lazy var jointsSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onJointsChanged)
    return ctl
  }()

  @objc func onJointsChanged(sender: Any) {
    guard let settings else { return }
    settings.drawJoints = jointsSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 3: AABBs
  let aabbsLabel = NSTextField(labelWithString: "AABBs:")

  lazy var aabbsSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onAABBsChanged)
    return ctl
  }()

  @objc func onAABBsChanged(sender: Any) {
    guard let settings else { return }
    settings.drawAABBs = aabbsSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 4: Contact Points
  let contactPointsLabel = NSTextField(labelWithString: "Contact Points:")
  
  lazy var contactPointsSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onContactPointsChanged)
    return ctl
  }()

  @objc func onContactPointsChanged(sender: Any) {
    guard let settings else { return }
    settings.drawContactPoints = contactPointsSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 5: Contact Normals
  let contactNormalsLabel = NSTextField(labelWithString: "Contact Normals:")
  
  lazy var contactNormalsSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onContactNormalsChanged)
    return ctl
  }()
  
  @objc func onContactNormalsChanged(sender: Any) {
    guard let settings else { return }
    settings.drawContactNormals = contactNormalsSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 6: Contact Impulses
  let contactImpulsesLabel = NSTextField(labelWithString: "Contact Impulses:")
  
  lazy var contactImpulsesSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onContactImpulsesChanged)
    return ctl
  }()
  
  @objc func onContactImpulsesChanged(sender: Any) {
    guard let settings else { return }
    settings.drawContactImpulse = contactImpulsesSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 7: Friction Impulses
  let frictionImpulsesLabel = NSTextField(labelWithString: "Friction Impulses:")
  
  lazy var frictionImpulsesSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onFrictionImpulsesChanged)
    return ctl
  }()
  
  @objc func onFrictionImpulsesChanged(sender: Any) {
    guard let settings else { return }
    settings.drawFrictionImpulse = frictionImpulsesSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 8: Center of Masses
  let centerOfMassesLabel = NSTextField(labelWithString: "Center of Masses:")
  
  lazy var centerOfMassesSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onCenterOfMassesChanged)
    return ctl
  }()
  
  @objc func onCenterOfMassesChanged(sender: Any) {
    guard let settings else { return }
    settings.drawCOMs = centerOfMassesSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 9: Statistics
  let statisticsLabel = NSTextField(labelWithString: "Statistics:")
  
  lazy var statisticsSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onStatisticsChanged)
    return ctl
  }()
  
  @objc func onStatisticsChanged(sender: Any) {
    guard let settings else { return }
    settings.drawStats = statisticsSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  // MARK: row 10: Profile
  let profileLabel = NSTextField(labelWithString: "Profile:")
  
  lazy var profileSwitch = { () -> NSSwitch in
    let ctl = NSSwitch(frame: .zero)
    ctl.target = self
    ctl.action = #selector(DrawSettingsViewController.onProfileChanged)
    return ctl
  }()
  
  @objc func onProfileChanged(sender: Any) {
    guard let settings else { return }
    settings.drawProfile = profileSwitch.state == .on
    delegate?.didSettingsChanged(settings)
  }

  override func loadView() {
    view = NSView(frame: .zero)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Draw"
    
    let gridView = NSGridView(views: [
      [shapesLabel, shapesSwitch],
      [jointsLabel, jointsSwitch],
      [aabbsLabel, aabbsSwitch],
      [contactPointsLabel, contactPointsSwitch],
      [contactNormalsLabel, contactNormalsSwitch],
      [contactImpulsesLabel, contactImpulsesSwitch],
      [frictionImpulsesLabel, frictionImpulsesSwitch],
      [centerOfMassesLabel, centerOfMassesSwitch],
      [statisticsLabel, statisticsSwitch],
      [profileLabel, profileSwitch],
    ])
    gridView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(gridView)
    
    let inset = SettingsViewController.inset
    NSLayoutConstraint.activate([
      gridView.topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
      gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
      view.bottomAnchor.constraint(greaterThanOrEqualTo: gridView.bottomAnchor, constant: inset),
      view.trailingAnchor.constraint(greaterThanOrEqualTo: gridView.trailingAnchor, constant: inset),
    ])
    gridView.column(at: 0).xPlacement = .trailing
    gridView.rowSpacing = 12
    gridView.columnSpacing = 8
  }
  
}
