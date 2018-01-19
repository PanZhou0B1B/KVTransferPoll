//
//  KVFuncHelperSwiftParse.swift
//  KVTransferPoll
//
//  Created by zhoupanpan on 2017/11/15.
//  Copyright © 2017年 panzhow. All rights reserved.
//

import Foundation
//MARK:Swift class转换
extension KVFuncHelper{
    
    public func parseValue2StringForSwift(_ input: Any?,_ key: String) -> (Header: String,imp: String) {
        guard let inputValue = input else { return ("","") }
        
        if inputValue is Dictionary<String, Any>{
            let (header,imp) = parseDicString2SwiftClass(inputValue as? Dictionary<String, Any>,key)
            return (header,imp)
        }else if inputValue is Array<Any>{
            let (header,imp) = parseArrayString2SwiftClass(inputValue as? Array<Any>,key)
            return (header,imp)
        }else{
            return ("","")
        }
    }
    
    /// 解析数组模式数据
    ///
    /// - Parameters:
    ///   - input: 数组Value
    ///   - key: 数组Key
    /// - Returns: 解析当前property和对应的类
    func parseArrayString2SwiftClass(_ input: Array<Any>?,_ key: String) -> (Header: String,imp: String) {
        guard let inputArray = input else { return ("","") }
        let className = wrapClassName(key, kvPrefix, kvSuffix)
        var HeaderString = ""
        if inputArray.count<=0{
            HeaderString = wrapHeaderName2SwiftClass(className)
            let exeTuple = wrapexe2SwiftClass([], className: key)
            HeaderString = "///can not parse successfully\n\r\(HeaderString);"
            
            HeaderString = "\(HeaderString)\n\(exeTuple.encode)\n\r\(exeTuple.decode)\n\r\(exeTuple.copy)\n\r\r}"
        }else{
            let firstValue = inputArray.first
            
            let (header,_) = parseValue2StringForSwift(firstValue, key)
            HeaderString = "\(header)"
        }
        return (HeaderString,"")
    }
    func parseDicString2SwiftClass(_ input: Dictionary<String, Any>?,_ key: String) -> (Header: String,imp: String) {
        guard let inputDic = input else { return ("","") }
        var HeaderString = ""
        
        let className = wrapClassName(key, kvPrefix, kvSuffix)
        HeaderString = wrapHeaderName2SwiftClass(className)
        var proptyValues: Array<Any> = Array.init()
        
        for (subKey,subValue) in inputDic{
            if subValue is Dictionary<String,Any>{
                let subClassName = wrapClassName(subKey, kvPrefix, kvSuffix)
                let subClassProperty = "    var \(subKey): \(subClassName)!"
                proptyValues.append((subKey,subClassName))
                HeaderString.append("\n\(subClassProperty)")
                
                let (header,_) = parseValue2StringForSwift(subValue as! Dictionary<String, Any>, subKey)
                HeaderString = "\(header)\n\r\(HeaderString)"
            }else if subValue is Array<Any>{
                let subClassName = wrapClassName(subKey, kvPrefix, kvSuffix)
                let subClassProperty = "    var \(subKey): [\(subClassName)]!"
                proptyValues.append((subKey,"[\(subClassName)]"))
                HeaderString.append("\n\(subClassProperty)")
                
                let (header,_) = parseValue2StringForSwift(subValue as! Array<Any>, subKey)
                HeaderString = "\(header)\n\r\(HeaderString)"
            }else if let subString = subValue as? String{
                if subString.isNumber{
                    let type = parseNumberString2SwiftClass(subString)
                    proptyValues.append((subKey,type))
                    let subClassProperty = "    var \(subKey): \(type)!"
                    HeaderString.append("\n\(subClassProperty)")
                }else{
                    let subClassProperty = "    var \(subKey): String!"
                    proptyValues.append((subKey,"String"))
                    HeaderString.append("\n\(subClassProperty)")
                }
            }
        }
        let CCImp = wrapexe2SwiftClass(proptyValues as! Array<(String, String)>, className: className)
        HeaderString = "\(HeaderString)\n\r\(CCImp.encode)\(CCImp.decode)\(CCImp.copy)}"
        return (HeaderString,"")
    }
    func parseNumberString2SwiftClass(_ input: String) -> String {
        let numfmt: NumberFormatter = NumberFormatter.init()
        numfmt.numberStyle = .none
        let inputNum: NSNumber = numfmt.number(from: input)!
        let numberType = CFNumberGetType(inputNum as CFNumber)
        var typeName : String!
        switch numberType{
        case .charType:
            if (inputNum.int32Value == 0 || inputNum.int32Value == 1){
                //it seems to be boolean
                typeName = "BOOL"
            }else{
                typeName = "char"
            }
        case .shortType, .intType:
            typeName = "NSInteger"
        case .floatType, .float32Type, .float64Type:
            typeName = "CGFloat"
        case .doubleType:
            typeName = "double"
        case .longType, .longLongType:
            typeName = "longlong"
        default:
            typeName = "NSInteger"
        }
        return typeName!
    }
}
//MARK: 支持coding、copying协议
extension KVFuncHelper{
    func wrapHeaderName2SwiftClass(_ className: String?) -> String {
        guard let classValue = className else { return "" }
        var header = "class \(classValue): NSObject {"
        if self.kvCodingEnable && self.kvCopyingEnable{
            header = "class \(classValue): NSObject,NSCoding,NSCopying {"
            return header
        }
        if self.kvCodingEnable{
            header = "class \(classValue): NSObject,NSCoding {"
        }
        if self.kvCopyingEnable{
            header = "class \(classValue): NSObject,NSCopying {"
            return header
        }
        return header
    }
    func wrapexe2SwiftClass(_ properties: Array<(String,String)>,className: String) -> (encode: String,decode: String,copy: String) {
        if properties.isEmpty{
            return ("","","")
        }
        if !self.kvCodingEnable && !self.kvCopyingEnable{
            return ("","","")
        }
        var codingEncode = ""
        var codingDecode = ""
        var copying = ""
        if self.kvCodingEnable{
            codingEncode = "func encode(with aCoder: NSCoder) {\n"
            codingDecode = "required init?(coder aDecoder: NSCoder) {\n"
        }
        if self.kvCopyingEnable{
            copying = "func copy(with zone: NSZone? = nil) -> Any {\n   let copyObj = \(className).copy(self)\n\r"
        }
        for (value,type) in properties {
            var encode = ""
            var decode = ""
            encode = "   aCoder.encode(\(value), forKey:\"\(value)\")\n"
            decode = "   \(value) = aDecoder.decodeObject(forKey: \"\(value)\") as! \(type)\n"
            
            codingEncode = "\(codingEncode)\(encode)"
            codingDecode = "\(codingDecode)\(decode)"
        }
        codingEncode = "\(codingEncode) }\n\r"
        codingDecode = "\(codingDecode) }\n\r"
        copying = "\(copying)\n   return copyObj\r }\n\n\r"
        if !self.kvCodingEnable{
            codingEncode = ""
            codingDecode = ""
        }
        if !self.kvCopyingEnable{
            copying = ""
        }
        return (codingEncode,codingDecode,copying)
    }
}
