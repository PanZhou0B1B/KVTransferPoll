//
//  KVTPMainViewController.swift
//  KVTransferPoll
//
//  Created by zhoupanpan on 2017/10/20.
//  Copyright © 2017年 panzhow. All rights reserved.
//

import Cocoa
import SnapKit

class KVTPMainViewController: NSViewController {

    private lazy var originalSV = NSStackView.init()
    private lazy var headerOrSwiftSV = NSStackView.init()
    private lazy var implementSV = NSStackView.init()
    private lazy var funcSV = NSStackView.init()
    
    private lazy var hlineOri2Header = NSBox.init()
    private lazy var vlineHeader2IMP = NSBox.init()
    
    private lazy var originalTV = IMXTextView.init()
    private lazy var headerOrSwiftTV = IMXTextView.init()
    private lazy var implementTV = IMXTextView.init()
    
    private lazy var prefixTF = NSTextField.init()
    private lazy var suffixTF = NSTextField.init()
    private lazy var languageBtn = NSPopUpButton.init()
    private lazy var codingCheckBtn = NSButton.init()
    private lazy var copyingCheckBtn = NSButton.init()
    private lazy var transferBtn = NSButton.init()
    
    // transferHelper
    private lazy var transferHelper = KVFuncHelper.init()
    
    override func loadView() {
        self.view = NSView.init()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        viewsConfigs()
        initialConfigs()
    }
    override func updateViewConstraints() {
        super.updateViewConstraints()
        refreshUIs()
    }
}
//MARK:logics
extension KVTPMainViewController{
    func initialConfigs() {
        let oriAtt = [NSAttributedStringKey.foregroundColor:NSColor.white,NSAttributedStringKey.backgroundColor:NSColor.clear,NSAttributedStringKey.font:NSFont.KVOriFont]
        let modelAtt = [NSAttributedStringKey.foregroundColor:NSColor.KVDarkGreenColor,NSAttributedStringKey.backgroundColor:NSColor.clear,NSAttributedStringKey.font:NSFont.KVModelFont]
        
        originalTV.imxplaceholderString = NSAttributedString.init(string: "请输入原始JSON数据", attributes: oriAtt)
        headerOrSwiftTV.imxplaceholderString = NSAttributedString.init(string: ".h文件：自动生成的Model头文件", attributes:modelAtt)
        
        implementTV.imxplaceholderString = NSAttributedString.init(string: ".m文件：自动生成的Model源文件", attributes: modelAtt)
        
    }
}
//MARK:actions
extension KVTPMainViewController{
    @objc func stateChange(btn: NSButton) {
        if btn == copyingCheckBtn{
            if btn.state == .off{
                transferHelper.kvCopyingEnable = false
            }else{
                transferHelper.kvCopyingEnable = true
            }
        }else{//coding btn
            if btn.state == .off{
                transferHelper.kvCodingEnable = false
            }else{
                transferHelper.kvCodingEnable = true
            }
        }
        transferAction(btn: transferBtn)
    }
    @objc func transferAction(btn:NSButton){
        transferHelper.kvPrefix = prefixTF.stringValue
        transferHelper.kvSuffix = suffixTF.stringValue
        var lantype = KVFuncHelper.LanType.objc
        lantype.refresh(type: languageBtn.indexOfSelectedItem)
        transferHelper.kvLan = lantype
        var originalText = originalTV.textView.string
        originalText.IMXtrim()
        let (readableOri,objc) = transferHelper.transferOri(originalText)
        if objc.header.isEmpty{
            let alert = NSAlert.init()
            alert.alertStyle = .critical
            alert.informativeText = "请检查JSON数据是否正确"
            alert.messageText = "提示"
            alert.addButton(withTitle: "知道了")
            
            alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) in
                
            })
            return
        }
        originalTV.textView.string = readableOri
        headerOrSwiftTV.textView.string = "\(KVFuncHelper.copyrightInfo())\r\r\r\r\(objc.header)"
        implementTV.textView.string = "\(KVFuncHelper.copyrightInfo())\r\r\r\r\(objc.imp)"
    }
}
//MARK: UIs
extension KVTPMainViewController {
    func viewsConfigs() -> Void {
        self.view.addSubview(originalSV)
        self.view.addSubview(headerOrSwiftSV)
        self.view.addSubview(implementSV)
        self.view.addSubview(funcSV)
        
        originalTV.imxBackGroundColor = NSColor.KVGreyColor
        originalTV.textColor = NSColor.white
        originalTV.font = NSFont.KVOriFont
        headerOrSwiftTV.imxBackGroundColor = NSColor.KVGreyColor
        headerOrSwiftTV.font = NSFont.KVModelFont
        headerOrSwiftTV.textColor = NSColor.KVDarkGreenColor
        headerOrSwiftTV.textView.isEditable = false
        implementTV.imxBackGroundColor = NSColor.KVGreyColor
        implementTV.textColor = NSColor.KVDarkGreenColor
        implementTV.font = NSFont.KVModelFont
        implementTV.textView.isEditable = false
        originalSV.addArrangedSubview(originalTV)
        headerOrSwiftSV.addArrangedSubview(headerOrSwiftTV)
        implementSV.addArrangedSubview(implementTV)
        bottomConfigs()
        
    }
    func bottomConfigs() -> Void {
        funcSV.distribution = .equalCentering;
       // funcSV.edgeInsets = NSEdgeInsetsMake(0, 10, 0, 10);
//        funcSV.alignment = .centerX
        //funcSV.spacing = 20
        funcSV.orientation = .horizontal
        
        hlineOri2Header.boxType = .custom
        vlineHeader2IMP.boxType = .custom
        vlineHeader2IMP.borderColor = NSColor.gray
        hlineOri2Header.borderColor = NSColor.gray
        self.view.addSubview(hlineOri2Header)
        self.view.addSubview(vlineHeader2IMP)
        prefixTF.placeholderString = "prefix string"
        suffixTF.placeholderString = "suffix string"
        languageBtn.addItems(withTitles: KVFuncHelper.LanType.allValues)
        languageBtn.selectItem(at: 0)
        codingCheckBtn.setButtonType(.switch)
        codingCheckBtn.title = "NSCoding"
        codingCheckBtn.state = .off
        codingCheckBtn.action = #selector(stateChange)
        codingCheckBtn.target = self
        copyingCheckBtn.setButtonType(.switch)
        copyingCheckBtn.title = "NSCopying"
        copyingCheckBtn.state = .off
        copyingCheckBtn.action = #selector(stateChange)
        copyingCheckBtn.target = self
        transferBtn.title = "转换"
        transferBtn.setButtonType(.momentaryPushIn)
        transferBtn.action = #selector(transferAction)
        transferBtn.target = self
        funcSV.addArrangedSubview(prefixTF)
        funcSV.addArrangedSubview(suffixTF)
        funcSV.addArrangedSubview(languageBtn)
        funcSV.addArrangedSubview(codingCheckBtn)
        funcSV.addArrangedSubview(copyingCheckBtn)
        funcSV.addArrangedSubview(transferBtn)
    }
    func refreshUIs() -> Void {
        originalSV.snp.updateConstraints { (make) in
            make.left.equalTo(self.view)
            make.top.equalTo(self.view)
            make.width.equalTo(350)
            make.bottom.equalTo(self.view).offset(-60);
        }
        headerOrSwiftSV.snp.updateConstraints { (make) in
            make.left.equalTo(originalSV.snp.right).offset(1)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
        }
        implementSV.snp.updateConstraints { (make) in
            make.left.equalTo(originalSV.snp.right).offset(1)
            make.right.equalTo(self.view)
            make.top.equalTo(headerOrSwiftSV.snp.bottom).offset(1)
            make.bottom.equalTo(self.view).offset(-60);
            make.height.equalTo(headerOrSwiftSV.snp.height);
        }
        hlineOri2Header.snp.updateConstraints { (make) in
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-60);
            make.left.equalTo(originalSV.snp.right)
            make.width.equalTo(1)
        }
        vlineHeader2IMP.snp.updateConstraints { (make) in
            make.top.equalTo(headerOrSwiftSV.snp.bottom)
            make.left.equalTo(hlineOri2Header.snp.right);
            make.right.equalTo(self.view)
            make.height.equalTo(1)
        }
        implementSV.snp.updateConstraints { (make) in
            make.left.equalTo(originalSV.snp.right).offset(1)
            make.right.equalTo(self.view)
            make.top.equalTo(headerOrSwiftSV.snp.bottom).offset(1)
            make.bottom.equalTo(self.view).offset(-60);
            make.height.equalTo(headerOrSwiftSV.snp.height);
        }
        //UI about bottom
        refreshBottoms()
    }
    func refreshBottoms() -> Void {
        prefixTF.snp.updateConstraints { (make) in
            make.left.equalTo(funcSV)
            make.centerY.equalTo(funcSV)
            make.width.equalTo(120)
            make.height.equalTo(22)
        }
        suffixTF.snp.updateConstraints { (make) in
            make.left.equalTo(prefixTF.snp.right).offset(20)
            make.centerY.equalTo(funcSV)
            make.width.equalTo(120)
            make.height.equalTo(22)
        }
        languageBtn.snp.updateConstraints { (make) in
            make.left.equalTo(suffixTF.snp.right).offset(20)
            make.centerY.equalTo(funcSV)
            make.width.equalTo(100)
            make.height.equalTo(26)
        }
        codingCheckBtn.snp.updateConstraints { (make) in
            make.left.equalTo(languageBtn.snp.right).offset(20)
            make.centerY.equalTo(funcSV)
            make.width.equalTo(80)
            make.height.equalTo(18)
        }
        copyingCheckBtn.snp.updateConstraints { (make) in
            make.left.equalTo(codingCheckBtn.snp.right).offset(20)
            make.centerY.equalTo(funcSV)
            make.width.equalTo(80)
            make.height.equalTo(18)
        }
        transferBtn.snp.updateConstraints { (make) in
            make.left.equalTo(copyingCheckBtn.snp.right).offset(20)
            make.centerY.equalTo(funcSV)
            make.width.equalTo(80)
            make.height.equalTo(18)
        }
        
        funcSV.snp.updateConstraints { (make) in
            make.top.equalTo(originalSV.snp.bottom)
            make.bottom.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.width.equalTo( 5*20 + 100 + 120 + 120 + 80 + 80 + 80)
        }
    }
}

//MARK:color
extension NSColor{
    class var KVGreyColor: NSColor{
        get{
            return NSColor.init(red: 74/255.0, green: 67/255.0, blue: 49/255.0, alpha: 1.0)
        }
    }
    class var KVDarkGreenColor: NSColor{
        get{
            return NSColor.init(red: 0/255.0, green: 129/255.0, blue: 36/255.0, alpha: 1.0)
        }
    }
}
//MARK:font
extension NSFont{
    class var KVOriFont: NSFont{
        get{
            return  NSFont.systemFont(ofSize: 14)
        }
    }
    class var KVModelFont: NSFont{
        get{
            return NSFont.systemFont(ofSize: 16)
        }
    }
}
