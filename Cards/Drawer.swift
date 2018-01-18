//
//  Drawer.swift
//  Cards
//
//  Created by Joshua Fisher on 1/11/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

protocol DrawerDelegate: class {
    func drawerDidBeginDragging(_: Drawer)
    func drawer(_: Drawer, didMoveToStop: Drawer.Stop)
}

class Drawer: PassThroughView {
    
    enum Stop: Int {
        case fullscreen = 0
        case expanded
        case minimized
        
        static var ordered: [Stop] = [.fullscreen, .expanded, .minimized]
    }
    
    private enum StopSearchCriterion {
        case closest, above, below
    }
    
    private var _stop = Stop.fullscreen {
        didSet {
            let top = self.stops[stop.rawValue] * self.frame.height
            self.scrollView.transform = CGAffineTransform(translationX: 0, y: top)
        }
    }
    
    var stop: Stop {
        get { return _stop }
        set { set(stop: newValue, animated: false) }
    }
    private(set) var stops: [CGFloat] = [0.1, 0.5, 0.85]
    
    weak var drawerDelegate: DrawerDelegate?
    
    var bounceOverdrawCoverage = CGFloat(30)
    
    private var scrollView: UIScrollView
    private var panGesture: UIPanGestureRecognizer

    private var startY = CGFloat(0)
    private var freeScrolling: Bool = false
    
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        panGesture = UIPanGestureRecognizer()
        
        super.init(frame: .zero)
        
        scrollView.delegate = self
        scrollView.frame = frame.with(height: frame.height + bounceOverdrawCoverage)
        scrollView.autoresizingMask = [.flexibleWidth]
        scrollView.contentInset.bottom = bounceOverdrawCoverage
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)

        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(panGestureChanged))
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            if frame != oldValue {
                let top = stops[Stop.fullscreen.rawValue] * frame.height
                scrollView.transform = CGAffineTransform(translationX: 0, y: top)
                let distanceToBottom = (1 - stops[Stop.fullscreen.rawValue]) * frame.height
                scrollView.frame.size.height = distanceToBottom + bounceOverdrawCoverage
            }
        }
    }
    
    func set(stop: Stop, animated: Bool) {
        if animated {
            let options: UIViewAnimationOptions = [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]
            UIView.animate(withDuration: 0.2, delay: 0, options: options, animations: {
                self._stop = stop
            }, completion: { _ in
                self.drawerDelegate?.drawer(self, didMoveToStop: stop)
            })
        } else {
            _stop = stop
            drawerDelegate?.drawer(self, didMoveToStop: stop)
        }
    }

    @objc private func panGestureChanged(_ gesture: UIGestureRecognizer) {
        guard gesture === panGesture else { return }
        
        switch panGesture.state {
        case .began:
            startY = scrollView.frame.minY - scrollView.contentOffset.y
            
        case .changed:
            // prevent attempting to drag above fullscreen stop
            let fullscreenPct = stops[Stop.fullscreen.rawValue]
            let closedPct = stops[Stop.minimized.rawValue]
            
            let translationY = panGesture.translation(in: nil).y
            let proposedPct = (startY + translationY) / frame.height
            
            freeScrolling = !(fullscreenPct ... closedPct ~= proposedPct)
            
            let cappedPct = min(closedPct, max(fullscreenPct, proposedPct))
            let top = cappedPct * frame.height
            scrollView.transform = CGAffineTransform(translationX: 0, y: top)
            
        case .ended:
            guard !freeScrolling else { return }
            
            let velocityY = panGesture.velocity(in: nil).y
            
            let criterion: StopSearchCriterion
            if velocityY < -150 {
                criterion = .above
            } else if velocityY > 150 {
                criterion = .below
            } else {
                criterion = .closest
            }
            
            let pct = scrollView.frame.minY / frame.height
            set(stop: self.nextStop(after: pct, using: criterion), animated: true)
            
        case .possible, .failed, .cancelled:
            break
        }
    }
    
    private func nextStop(after position: CGFloat, using criterion: StopSearchCriterion) -> Stop {
        switch criterion {
        case .closest:
            // find the closest stop value to position
            return zip(Stop.ordered, stops).min { a, b in
                return abs(a.1 - position) < abs(b.1 - position)
            }!.0
            
        case .above:
            // find the stop value above & closest to position
            for stop in Stop.ordered.reversed() {
                let value = stops[stop.rawValue]
                if value < position {
                    return stop
                }
            }
            return .fullscreen
            
        case .below:
            for stop in Stop.ordered {
                let value = stops[stop.rawValue]
                if value > position {
                    return stop
                }
            }
            return .minimized
        }
    }
}

extension Drawer: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
        guard gesture === panGesture else {
            return super.gestureRecognizerShouldBegin(gesture)
        }
        
        let velocity = panGesture.velocity(in: nil)
        return abs(velocity.y) > abs(velocity.x)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer === panGesture
    }
}

extension Drawer: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        drawerDelegate?.drawerDidBeginDragging(self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !freeScrolling {
            targetContentOffset.pointee.y = 0
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !freeScrolling {
            scrollView.bounds.origin.y = 0
        }
    }
}
