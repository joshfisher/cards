//
//  ViewController.swift
//  Cards
//
//  Created by Joshua Fisher on 12/18/17.
//  Copyright © 2017 Joshua Fisher. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var tapSink: UIView!
    private var cardsView: CardsView!
    private var drawer: Drawer!

    override func viewDidLoad() {
        super.viewDidLoad()

        tapSink = UIView(frame: view.bounds)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapSink.backgroundColor = Palette.d[0]
        tapSink.addGestureRecognizer(tapGesture)
        view.addSubview(tapSink)
        
        let insertButton = UIButton()
        insertButton.setTitle("Insert", for: .normal)
        insertButton.setTitleColor(.white, for: .normal)
        insertButton.showsTouchWhenHighlighted = true
        insertButton.addTarget(self, action: #selector(insertNewCard), for: .touchUpInside)
        insertButton.sizeToFit()
        insertButton.frame.origin = CGPoint(x: 10, y: view.bounds.minY + 20)
        view.addSubview(insertButton)
        
        let removeButton = UIButton()
        removeButton.setTitle("Remove", for: .normal)
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.showsTouchWhenHighlighted = true
        removeButton.addTarget(self, action: #selector(removeCard), for: .touchUpInside)
        removeButton.sizeToFit()
        removeButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        removeButton.center = CGPoint(x: view.bounds.midX, y: view.bounds.minY + 20)
        view.addSubview(removeButton)
        
        let moveButton = UIButton()
        moveButton.setTitle("Move", for: .normal)
        moveButton.setTitleColor(.white, for: .normal)
        moveButton.showsTouchWhenHighlighted = true
        moveButton.addTarget(self, action: #selector(moveCardFromEnd), for: .touchUpInside)
        moveButton.sizeToFit()
        moveButton.layer.anchorPoint = CGPoint(x: 1.0, y: 0)
        moveButton.center = CGPoint(x: view.bounds.maxX - 10, y: view.bounds.minY + 20)
        view.addSubview(moveButton)

        cardsView = CardsView(frame: view.bounds)
        view.addSubview(cardsView)

        var model = CardsViewModel()
        model.stop = .expanded
        model.cardModels = (0 ..< 3).map { _ in CardModel.plain(uid: UUID(), palette: Palette.g) }

        cardsView.model = model
    }
    
    @objc func tapped() {
        let randomIndex = Int(arc4random_uniform(UInt32(Palette.d.count)))
        tapSink.backgroundColor = Palette.d[randomIndex]
    }
    
    @objc func insertNewCard() {
        var model = cardsView.model
        let index = model.index + 1
        model.cardModels.insert(CardModel.plain(uid: UUID(), palette: Palette.h), at: index)
        model.index = index
        cardsView.setModel(model, animated: true)
    }
    
    @objc func removeCard() {
        guard cardsView.model.cardModels.count > 0 else { return }
        
        var model = cardsView.model
        model.cardModels.remove(at: model.index)
        model.index = min(model.index, model.cardModels.count - 1)
        cardsView.setModel(model, animated: true)
    }
    
    @objc func moveCardFromEnd() {
        
    }
}
