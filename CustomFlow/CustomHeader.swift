//
//  CustomHeader.swift
//  CustomFlow
//
//  Created by Németh Gergely on 2018. 12. 19..
//  Copyright © 2018. Németh Gergely. All rights reserved.
//

import UIKit

class CustomLayer: CAGradientLayer {

    var minimumHeigth: CGFloat = 64

    var path: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: .zero)
        let startEndPointsHeight = bounds.height - max((bounds.height-minimumHeigth)/4, 0)
        let controlPointsHeight = bounds.height
        path.addLine(to: CGPoint(x: 0, y: startEndPointsHeight))
        path.addCurve(to: CGPoint(x: bounds.width, y: startEndPointsHeight),
                      controlPoint1: CGPoint(x: bounds.width * 1 / 5, y: controlPointsHeight),
                      controlPoint2: CGPoint(x: bounds.width * 4 / 5, y: controlPointsHeight))
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        path.close()
        return path
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        if let mask = mask as? CAShapeLayer, let anim = animation(forKey: "bounds.size") {
            CATransaction.begin()
            CATransaction.setAnimationDuration(anim.duration)
            CATransaction.setAnimationTimingFunction(anim.timingFunction)
            let pathAnimation = CABasicAnimation(keyPath: "path")
            self.mask?.add(pathAnimation, forKey: "path")

            mask.path = path.cgPath
            mask.frame = self.bounds

            CATransaction.commit()
        } else {
            mask?.frame = self.bounds
            (mask as? CAShapeLayer)?.path = path.cgPath
        }
    }
}

class CustomHeader: UIView {

    var minimumHeigth: CGFloat {
        get {
            guard let gradientLayer = layer as? CustomLayer else { return 0 }
            return gradientLayer.minimumHeigth
        }

        set {
            (layer as? CustomLayer)?.minimumHeigth = newValue
        }
    }

    override public class var layerClass: Swift.AnyClass {
        return CustomLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        guard let gradientLayer = layer as? CustomLayer else { return }
        gradientLayer.colors = [UIColor(red: 111/255, green: 133/255, blue: 238/255, alpha: 1.0).cgColor,
                                UIColor(red: 74/255, green: 66/255, blue: 211/255, alpha: 1.0).cgColor]

        let shapeMask = CAShapeLayer()
        shapeMask.path = gradientLayer.path.cgPath
        gradientLayer.mask = shapeMask
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }

    func setGradient(x: CGFloat) {
        guard let gradientLayer = layer as? CustomLayer else { return }
        gradientLayer.startPoint = CGPoint(x: min(2*x,1), y: max(2*x-1,0))
        gradientLayer.endPoint = CGPoint(x: max(2*(1-x)-1,0), y: min(2*(1-x),1))
    }
}
