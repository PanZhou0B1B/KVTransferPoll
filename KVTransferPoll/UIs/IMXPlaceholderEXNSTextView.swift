//
//  IMXPlaceholderEXNSTextView.swift
//  KVTransferPoll
//
//  Created by zhoupanpan on 2017/10/26.
//  Copyright © 2017年 panzhow. All rights reserved.
//
import Cocoa
import ObjectiveC.runtime
extension NSTextView{
    private struct AssociatedKey {
        static var NSTextViewExtension_PlaceholderAString = "NSTextViewExtension_PlaceholderAString"
        static var NSTextViewExtension_PlaceholderTF = "NSTextViewExtension_PlaceholderTF"
    }
    var IMXattributePlaceholder: NSAttributedString{
        set{
            objc_setAssociatedObject(self, &AssociatedKey.NSTextViewExtension_PlaceholderAString, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self,&AssociatedKey.NSTextViewExtension_PlaceholderAString) as! NSAttributedString
        }
    }
    private var placeholderTF: NSTextField?{
        set{
            objc_setAssociatedObject(self, &AssociatedKey.NSTextViewExtension_PlaceholderTF, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self,&AssociatedKey.NSTextViewExtension_PlaceholderTF) as? NSTextField
        }
    }
    
    override open func becomeFirstResponder() -> Bool {
        self.needsDisplay = true
        return super.becomeFirstResponder()
    }
    override open func resignFirstResponder() -> Bool {
        self.needsDisplay = true
        return super.resignFirstResponder()
    }
    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.placeholderTFConfig()
        
        if self.string == "" {
            self.placeholderTF?.isHidden = false
        }else{
            self.placeholderTF?.isHidden = true
        }
    }
    func placeholderTFConfig() {
        if(self.placeholderTF == nil){
            self.placeholderTF = NSTextField.init(frame: CGRect.init(origin: CGPoint.init(x: 8, y: 8), size: CGSize.init(width: 100, height: 20)))
            self.placeholderTF?.drawsBackground = false
            self.placeholderTF?.isEditable = false
            self.placeholderTF?.isSelectable = false
        }
        if self.placeholderTF?.superview == nil {
            self.addSubview(self.placeholderTF!)
        }
        self.placeholderTF?.attributedStringValue = self.IMXattributePlaceholder
    }
    
}
