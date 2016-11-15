//
//  ViewController.swift
//  animation
//
//  Created by stvding on 2016/9/23.
//  Copyright © 2016年 shellCom. All rights reserved.
//

import UIKit

var gameCount = 0


class FruitNinjaViewController: UIViewController, UICollisionBehaviorDelegate {
    //MARK: Stroke mark
    private var activeSlicePoints = [CGPoint]()
    private var slicePath: CAShapeLayer = CAShapeLayer()
    
    //MARK: Timers
    private var newBatchOfBalls = NSTimer()
    private var clearCombo = NSTimer()
    
    //MARK: Fruit data
    private var fruitArray = [FruitView]()
    private var piecesArray = [FruitView]()
    private var bombArray = [Bomb]()
    private var fruitNinjaModel = FruitNinjaModel(lifeToBeginWith: 3)
    private let fruitPerRow = 10
    private var fruitSize:CGSize {
        let size = view.bounds.size.width / CGFloat(fruitPerRow)
        return CGSize(width: size, height: size)
    }
    
    //MARK: UIDynamics
    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.view)
    private var bottomLine: (CGPoint,CGPoint) {
        return (view.bounds.lowerLeft, view.bounds.lowerRight)
    }
    private var fruitBehavior = TossingBehavior()
    //    var playing: Bool = false {
    //        didSet{
    //            if playing {
    //                animator.addBehavior(fruitBehavior)
    //            } else {
    //                animator.removeBehavior(fruitBehavior)
    //            }
    //        }
    //    }
    
    //MARK: Label Outlets
    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var lifeLabel: UILabel!
    @IBOutlet weak var comboLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack2: UIStackView!
    @IBOutlet weak var pauseInfo: UILabel!
    
    //MARK: ViewController life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameCount += 1
        print ("load up a game, count = \(gameCount)")
        
        
        //Setup slice attributes
        slicePath.strokeColor = UIColor.blackColor().CGColor
        slicePath.fillColor = UIColor.clearColor().CGColor
        slicePath.lineWidth = 2
        view.layer.addSublayer(slicePath)
        
        comboLabel.text = " "
        plusLabel.text = " "
        
        fruitBehavior.setBottomLine(bottomLine.0, p2: bottomLine.1)
        fruitBehavior.collision.collisionDelegate = self
    }
    
    deinit {
        gameCount -= 1
        print ("game left the heap, count = \(gameCount)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        life = fruitNinjaModel.life
        score = fruitNinjaModel.score
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        playing = true
        animator.addBehavior(fruitBehavior)
        fireUpTimers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        newBatchOfBalls.invalidate()
        clearCombo.invalidate()
    }
    
    //MARK: Override touches methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard fruitNinjaModel.state == .playing else { return }
        activeSlicePoints.removeAll(keepCapacity: true)
        fruitNinjaModel.combo = 0
        if let touch = touches.first{
            let location = touch.locationInView(view)
            activeSlicePoints.append(location)
        }
        //        print("\(fruitBehavior.throwing.items.count) items in push behavior")
        //        print("\(fruitBehavior.itemBehavior.items.count) items in item behavior")
        //        print("\(fruitBehavior.collision.items.count) items in collision behavior")
        //        print("\(fruitBehavior.gravity.items.count) items in gravity behavior")
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard fruitNinjaModel.state == .playing else { return }
        guard let touch = touches.first else { return }
        let location = touch.locationInView(view)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        //            clearCombo = NSTimer.scheduledTimerWithTimeInterval(0.2, repeats: false) {_ in
        //                self.fruitNinjaModel.combo = 0
        //                self.touchesEnded(touches, withEvent: event)
        //            }
        
        for fruit in fruitArray {
            if CGRectContainsPoint(fruit.frame, location){
                fruitNinjaModel.combo += 1
                if fruitNinjaModel.combo >= 3 {
                    comboLabel.text = "\(fruitNinjaModel.combo) Fruits Combo!!!"
                    delay(0.8){ [unowned me = self] in
                        me.comboLabel.text = " "
                    }
                }
                let(left,right) = fruit.split()
                addFruit(left, type: .leftPiece)
                
                clean(fruit)
                addFruit(right, type: .rightPiece)
                score += 1
                //                    clearCombo.invalidate()
                break
            }
        }
        
        for bomb in bombArray {
            if CGRectContainsPoint(bomb.frame, location){
                stopGame()
                fruitNinjaModel.state = .over
                comboLabel.text = "You cut a bomb! Game Over!"
                for fruit in fruitArray { clean(fruit) }
                for pieces in piecesArray { clean(pieces) }
                pauseButton.setTitle("New game?", forState: .Normal)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        guard fruitNinjaModel.state == .playing else { return }
        activeSlicePoints.removeAll(keepCapacity: true)
        slicePath.path = nil
        
        clearCombo.invalidate()
        if fruitNinjaModel.combo >= 3 {
            score += fruitNinjaModel.combo
            plusLabel.text = "+\(fruitNinjaModel.combo) bonus!!"
            delay(0.3, closure: {[unowned me = self] in
                me.plusLabel.text = " "}
            )
        }
        fruitNinjaModel.combo = 0
        //        comboLabel.text = "\(model.combo) Balls Combo!!!"
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard fruitNinjaModel.state == .playing else { return }
        touchesEnded(touches, withEvent: event)
    }
    
    // MARK: game functions
    private var life: Int{
        get{
            return fruitNinjaModel.life
        }
        set{
            fruitNinjaModel.life = newValue
            lifeLabel.text = String(newValue)
        }
    }
    
    private var score: Int {
        get{
            return fruitNinjaModel.score
        }
        set{
            fruitNinjaModel.score = newValue
            scoreLabel.text = String(newValue)
            updateBestScoreInView()
        }
    }
    
    private func updateBestScoreInView(){
        bestScoreLabel.text = String(FruitNinjaModel.bestScore)
    }
    
    func addNewFruit(){
        addFruit(nil, type: .whole)
    }
    
    func addFruit(fruit: FruitView?, type: FruitBrain.FruitState) {
        if fruitNinjaModel.state == .playing {
            switch type {
            case .whole:
                var frame = CGRect(origin: CGPoint.zero, size: fruitSize)
                frame.origin.x = CGFloat.random(0, max: fruitPerRow) * fruitSize.width
                frame.origin.y = view.bounds.size.height - fruitSize.width - 10
                
                let newFruit  = FruitView(thisState: .whole, frame: frame)
                newFruit.backgroundColor = UIColor.clearColor()
                
                let direction: CGFloat = frame.origin.x > (view.bounds.size.width / 2) ? -1 : 1
                let launchForce = CGVector(dx: direction * view.bounds.size.width / 800,
                                           dy: -view.bounds.size.height * 0.75 / 100)
                
                view.addSubview(newFruit)
                fruitArray.append(newFruit)
                fruitBehavior.addItem(newFruit, angularVelocity: 0)
                animator.addBehavior(newFruit.throwing)
                newFruit.throwIt(launchForce)
//                print("add one!")
//                print("behavior = \(fruitBehavior.gravity)")
                
            case .leftPiece:
                guard fruit != nil else {
                    print("Give me a leftPiece to add!!")
                    return
                }
                //                print("left????\(fruit)")
                let leftSplitForce = CGVector(dx: -view.bounds.size.width / 1200, dy: 0)
                view.addSubview(fruit!)
                piecesArray.append(fruit!)
                fruitBehavior.addItem(fruit!, angularVelocity: fruitSize.width / 6)
                animator.addBehavior(fruit!.throwing)
                fruit!.throwIt(leftSplitForce)
                
            case .rightPiece:
                guard fruit != nil else {
                    print("Give me a rightPiece to add!!")
                    return
                }
                //                print("right????\(fruit)")
                let rightSplitForce = CGVector(dx: view.bounds.size.width / 1200, dy: 0)
                view.addSubview(fruit!)
                piecesArray.append(fruit!)
                fruitBehavior.addItem(fruit!, angularVelocity: fruitSize.width / 6)
                animator.addBehavior(fruit!.throwing)
                fruit!.throwIt(rightSplitForce)
            }
            
            
        }
        
    }
    
    
    func addBomb(){
        var frame = CGRect(origin: CGPoint.zero, size: fruitSize)
        frame.origin.x = CGFloat.random(0, max: fruitPerRow) * fruitSize.width
        frame.origin.y = view.bounds.size.height - fruitSize.width - 10
        
        let bomb  = Bomb(frame: frame)
        bomb.backgroundColor = UIColor.clearColor()
        
        let direction: CGFloat = frame.origin.x > (view.bounds.size.width / 2) ? -1 : 1
        let launchForce = CGVector(dx: direction * view.bounds.size.width / 800,
                                   dy: -view.bounds.size.height * 0.75 / 100)
        
        view.addSubview(bomb)
        bombArray.append(bomb)
        fruitBehavior.addItem(bomb, angularVelocity: 0)
        animator.addBehavior(bomb.throwing)
        bomb.throwIt(launchForce)
        print("add one!")
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let fruit = item as? FruitView {
            clean(fruit)
            if fruit.getState() == .whole {
                life -= 1
                if life == 0 {
                    //************************************//
                    /* !!!!!!stop the god damn game!!!!!! */
                    //************************************//
                    
                    stopGame()
                    fruitNinjaModel.state = .over
                    comboLabel.text = "Game Over!"
                    for fruit in fruitArray { clean(fruit) }
                    for pieces in piecesArray { clean(pieces) }
                    pauseButton.setTitle("New game?", forState: .Normal)
                }
            }
        }else if let bomb = item as? Bomb {
            clean(bomb)
        }
    }
    
    
    func setupNewGame(){
        fruitNinjaModel = FruitNinjaModel(lifeToBeginWith: 3)
        life = fruitNinjaModel.life
        score = fruitNinjaModel.score
    }
    
    func clean(thing: AnyObject) {
        if let fruit = thing as? FruitView {
            fruitBehavior.removeItem(fruit)
            fruit.removeFromSuperview()
            if fruit.getState() == .whole {
                fruitArray.removeAtIndex(fruitArray.indexOf(fruit)!)
            } else {
                piecesArray.removeAtIndex(piecesArray.indexOf(fruit)!)
            }
        }else if let bomb = thing as? Bomb{
            fruitBehavior.removeItem(bomb)
            bomb.removeFromSuperview()
            bombArray.removeAtIndex(bombArray.indexOf(bomb)!)
        }
    }
    
    func addMultipleFruits() {
        let quantityOfFruits = Int.random(1, max: 5)
        let firstBomb = CGFloat.random(1, max: 5) == 1
        let secondBomb = CGFloat.random(1, max: 10) == 1
        if firstBomb {addBomb()}
        for i in 1...quantityOfFruits {
            NSTimer.scheduledTimerWithTimeInterval(Double(i)*0.2, target: self, selector: #selector(addNewFruit), userInfo: nil, repeats: false)
            if secondBomb {
                NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(addBomb), userInfo: nil, repeats: false)
            }
        }
        
        
        //        print("addMultipleFruits")
    }
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            slicePath.path = nil
            return
        }
        while activeSlicePoints.count > 12 { activeSlicePoints.removeAtIndex(0) }
        
        let path = UIBezierPath()
        path.moveToPoint(activeSlicePoints[0])
        
        for i in 1..<(activeSlicePoints.count) { path.addLineToPoint(activeSlicePoints[i]) }
        slicePath.path = path.CGPath
    }
    
    
    func fireUpTimers(){
        newBatchOfBalls = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(addMultipleFruits), userInfo: nil, repeats: true)
        print("fire up timers")
        
        
    }
    
    func stopGame() {
        newBatchOfBalls.invalidate()
        animator.removeAllBehaviors()
        pauseButton.setTitle("Start", forState: .Normal)
        
    }
    
    @IBAction func pause() {
        switch fruitNinjaModel.state {
        case .playing:
            fruitNinjaModel.state = .pausing
            for fruit in fruitArray { fruit.saveVelocity(fruitBehavior) }
            for pieces in piecesArray { pieces.saveVelocity(fruitBehavior) }
            stopGame()
            pauseInfo.hidden = false
        case .pausing:
            fruitNinjaModel.state = .playing
            animator.addBehavior(fruitBehavior)
            for fruit in fruitArray {
                let velocity = fruit.getVelocity()
                fruitBehavior.setVeloctiy(fruit, linear: velocity.0, angular: velocity.1)
            }
            for pieces in piecesArray {
                let velocity = pieces.getVelocity()
                fruitBehavior.setVeloctiy(pieces, linear: velocity.0, angular: velocity.1)
            }
            fireUpTimers()
            pauseButton.setTitle("Pause", forState: .Normal)
            pauseInfo.hidden = true
        case .over:
            //Set up a new game
            for bomb in bombArray { clean(bomb) }
            setupNewGame()
            fruitBehavior = TossingBehavior()
            fruitBehavior.setBottomLine(bottomLine.0, p2: bottomLine.1)
            fruitBehavior.collision.collisionDelegate = self
            animator.addBehavior(fruitBehavior)
            fireUpTimers()
            //Update Button Text
            pauseButton.setTitle("Pause", forState: .Normal)
            comboLabel.text = " "
        }
    }
}
