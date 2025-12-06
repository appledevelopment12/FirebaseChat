//
//  Designable.swift
//  FirebaseChat
//
//  Created by Rohit on 29/11/25.

import Foundation
import UIKit

@IBDesignable
class CornerView: UIView {
    
    @IBInspectable var leftTopRadius : CGFloat = 0 {
        didSet{
            self.applyMask()
        }
    }
    @IBInspectable var rightTopRadius : CGFloat = 0 {
        didSet{
            self.applyMask()
        }
    }
    @IBInspectable var rightBottomRadius : CGFloat = 0 {
        didSet{
            self.applyMask()
        }
    }
    @IBInspectable var leftBottomRadius : CGFloat = 0 {
        didSet {
            self.applyMask()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyMask()
    }
    func applyMask() {
        let shapeLayer = CAShapeLayer(layer: self.layer)
        shapeLayer.path = self.pathForCornersRounded(rect:self.bounds).cgPath
        shapeLayer.frame = self.bounds
        shapeLayer.masksToBounds = true
        self.layer.mask = shapeLayer
    }
    func pathForCornersRounded(rect:CGRect) ->UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0 + leftTopRadius , y: 0))
        path.addLine(to: CGPoint(x: rect.size.width - rightTopRadius , y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.size.width , y: rightTopRadius), controlPoint: CGPoint(x: rect.size.width, y: 0))
        path.addLine(to: CGPoint(x: rect.size.width , y: rect.size.height - rightBottomRadius))
        path.addQuadCurve(to: CGPoint(x: rect.size.width - rightBottomRadius , y: rect.size.height), controlPoint: CGPoint(x: rect.size.width, y: rect.size.height))
        path.addLine(to: CGPoint(x: leftBottomRadius , y: rect.size.height))
        path.addQuadCurve(to: CGPoint(x: 0 , y: rect.size.height - leftBottomRadius), controlPoint: CGPoint(x: 0, y: rect.size.height))
        path.addLine(to: CGPoint(x: 0 , y: leftTopRadius))
        path.addQuadCurve(to: CGPoint(x: 0 + leftTopRadius , y: 0), controlPoint: CGPoint(x: 0, y: 0))
        path.close()
        return path
    }
}
extension UIColor {
    static var themeMoreButton = UIColor.init(red: 226/255,green: 0/255, blue: 57.0/255, alpha: 1)
}

@IBDesignable
class CustomDashedView: UIView {
    @IBInspectable var dashWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var dashWidth2: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var dashColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var dashLength: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var betweenDashesSpace: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    private var dashBorder: CAShapeLayer?
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDashBorder()
    }
    private func updateDashBorder() {
        dashBorder?.removeFromSuperlayer()
        let border = CAShapeLayer()
        border.lineWidth = dashWidth
        border.strokeColor = dashColor.cgColor
        border.lineDashPattern = [NSNumber(value: Float(dashLength)), NSNumber(value: Float(betweenDashesSpace))]
        border.frame = bounds
        border.fillColor = nil
       
        let path: UIBezierPath
        if cornerRadius > 0 {
            path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        } else {
            path = UIBezierPath(rect: bounds)
        }
        border.path = path.cgPath
        
        layer.addSublayer(border)
        dashBorder = border
    }
}


