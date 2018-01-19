//
//  IMXTextView.swift
//  KVTransferPoll
//
//  Created by zhoupanpan on 2017/10/20.
//  Copyright © 2017年 panzhow. All rights reserved.
//

import Cocoa

class IMXTextView: NSView {

    lazy var textView = NSTextView.init()
    lazy var scrollView = NSScrollView.init()
    fileprivate lazy var placeholderTF = NSTextField.init()
    fileprivate var placeholderString: NSAttributedString?
    
    deinit{
    }
    override  init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        UIsConfig()
    }
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        UIsConfig()
    }
    override func  updateConstraints() {
        super.updateConstraints()
        refreshUIs()
    }
    override public func layout() {
        super.layout()
    }
}

extension IMXTextView: NSTextViewDelegate{
    func UIsConfig() -> Void {
        self.addSubview(scrollView)
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = false
        scrollView.borderType = .noBorder
        
        textView.minSize = NSMakeSize(0, scrollView.contentSize.height)
        textView.maxSize = NSMakeSize(.greatestFiniteMagnitude, .greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.delegate = self
        scrollView.documentView = textView
        
        placeholderTF = NSTextField.init()
        placeholderTF.isBezeled = false
        placeholderTF.drawsBackground = false
        placeholderTF.isEditable = false
        placeholderTF.isSelectable = false
        placeholderTF.alphaValue = 0.6
        textView.addSubview(placeholderTF)
        let gesture = NSClickGestureRecognizer()
        gesture.buttonMask = 0x1 // left mouse
        gesture.target = self
        gesture.action = #selector(TFClick)
        placeholderTF.addGestureRecognizer(gesture)
    }
    func refreshUIs(){
        scrollView.snp.updateConstraints { (make) in
            make.edges.equalTo(self)
        }
        placeholderTF.snp.updateConstraints { (make) in
            make.left.equalTo(textView).offset(12)
            make.top.equalTo(textView).offset(8)
            make.right.equalTo(textView).offset(8)
            make.height.equalTo(20)
        }
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        if textView.string == ""{
            placeholderTF.isHidden = false
        }else{
            placeholderTF.isHidden = true
        }
    }
    @objc func TFClick(){
        if textView.acceptsFirstResponder{
            textView.window?.makeFirstResponder(textView)
        }
    }
}
extension IMXTextView{
    public var textColor: NSColor{
        set { textView.textColor = newValue }
        get { return textView.textColor ?? .black}
    }
    public var imxBackGroundColor: NSColor{
        set { textView.backgroundColor = newValue
            scrollView.backgroundColor = newValue
        }
        get { return textView.textColor ?? .black}
    }
    public var font: NSFont? {
        set { textView.font = newValue }
        get { return textView.font }
    }
    public var imxplaceholderString: NSAttributedString? {
        set {
            placeholderString = newValue
            placeholderTF.attributedStringValue = (newValue)!
            placeholderTF.isHidden = false
        }
        get { return placeholderString }
    }
    
}
