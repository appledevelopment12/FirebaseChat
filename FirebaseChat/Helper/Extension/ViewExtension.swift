//
//  ViewExtension.swift
//  FirebaseChat
import Foundation
import UIKit

let kSharedAppDelegate = UIApplication.shared.delegate as? AppDelegate
extension UIView {
    @IBInspectable
    var cornerRadius : CGFloat {
        get{
            return self.layer.cornerRadius
        }
        set(newValue) {
            self.layer.cornerRadius = newValue
        }
    }
    @IBInspectable
    var borderLineWidth : CGFloat {
        get {
            return self.layer.borderWidth
        }
        set(newValue) {
            self.layer.borderWidth = newValue
        }
    }
    @IBInspectable
    var borderColor : UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor ?? UIColor.clear.cgColor)
        }
        set(newValue) {
            self.layer.borderColor = newValue.cgColor
        }
    }
    @IBInspectable
    var offsetShadow : CGSize {
        get {
            return self.layer.shadowOffset
        }
        set(newValue) {
            self.layer.shadowOffset = newValue
        }
    }
    @IBInspectable
    var opacityShadow : Float {
        get{
            return self.layer.shadowOpacity
        }
        set(newValue) {
            self.layer.shadowOpacity = newValue
        }
    }
    @IBInspectable
    var colorShadow : UIColor? {
        get{
            return UIColor(cgColor: self.layer.shadowColor ?? UIColor.clear.cgColor)
        }
        set(newValue) {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable
    var radiusShadow : CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set(newValue) {
            self.layer.shadowRadius = newValue
        }
    }
    @IBInspectable
    var maskToBounds : Bool {
        get {
            return self.layer.masksToBounds
        }
        set(newValue) {
            self.layer.masksToBounds = newValue
        }
    }
    func makeRoundedCorner(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width/2
    }
}
extension UIButton {
    @IBInspectable
    var cornerRadiusBtn : CGFloat {
        get{
            return self.layer.cornerRadius
        }
        set(newValue) {
            self.layer.cornerRadius = newValue
        }
    }
    @IBInspectable
    var borderLineWidthBtn : CGFloat {
        get {
            return self.layer.borderWidth
        }
        set(newValue) {
            self.layer.borderWidth = newValue
        }
    }
    @IBInspectable
    var borderColorBtn : UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor ?? UIColor.clear.cgColor)
        }
        set(newValue) {
            self.layer.borderColor = newValue.cgColor
        }
    }
}
extension UITextField {
    @IBInspectable
    var cornerRadiusTF : CGFloat {
        get{
            return self.layer.cornerRadius
        }
        set(newValue) {
            self.layer.cornerRadius = newValue
        }
    }
    @IBInspectable
    var borderLineWidthTF : CGFloat {
        get {
            return self.layer.borderWidth
        }
        set(newValue) {
            self.layer.borderWidth = newValue
        }
    }
    @IBInspectable
    var borderColorTF : UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor ?? UIColor.clear.cgColor)
        }
        set(newValue) {
            self.layer.borderColor = newValue.cgColor
        }
    }
}
