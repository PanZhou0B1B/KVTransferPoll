//
//  KVFuncHelperSwiftStruct.swift
//  KVTransferPoll
//
//  Created by zhoupanpan on 2017/11/15.
//  Copyright © 2017年 panzhow. All rights reserved.
//

import Foundation
//MARK:Swift struct转换
extension KVFuncHelper{
    
    public func parseValue2StringForSwiftStruct(_ input: Any?,_ key: String) -> (Header: String,imp: String) {
        guard let inputValue = input else { return ("","") }
        
        if inputValue is Dictionary<String, Any>{
            let (header,imp) = parseDicString2SwiftStruct(inputValue as? Dictionary<String, Any>,key)
            return (header,imp)
        }else if inputValue is Array<Any>{
            let (header,imp) = parseArrayString2SwiftStruct(inputValue as? Array<Any>,key)
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
    func parseArrayString2SwiftStruct(_ input: Array<Any>?,_ key: String) -> (Header: String,imp: String) {
        guard let inputArray = input else { return ("","") }
        let className = wrapClassName(key, kvPrefix, kvSuffix)
        var HeaderString = ""
        if inputArray.count<=0{
            HeaderString = wrapHeaderName2SwiftStruct(className)
            HeaderString = "///can not parse successfully\n\r\(HeaderString);"
            
            HeaderString = "\(HeaderString)\n\r}"
        }else{
            let firstValue = inputArray.first
            
            let (header,_) = parseValue2StringForSwiftStruct(firstValue, key)
            HeaderString = "\(header)"
        }
        return (HeaderString,"")
    }
    func parseDicString2SwiftStruct(_ input: Dictionary<String, Any>?,_ key: String) -> (Header: String,imp: String) {
        guard let inputDic = input else { return ("","") }
        var HeaderString = ""
        
        let className = wrapClassName(key, kvPrefix, kvSuffix)
        HeaderString = wrapHeaderName2SwiftStruct(className)
        
        for (subKey,subValue) in inputDic{
            if subValue is Dictionary<String,Any>{
                let subClassName = wrapClassName(subKey, kvPrefix, kvSuffix)
                let subClassProperty = "    var \(subKey): \(subClassName)!"
                HeaderString.append("\n\(subClassProperty)")
                
                let (header,_) = parseValue2StringForSwiftStruct(subValue as! Dictionary<String, Any>, subKey)
                HeaderString = "\(header)\n\r\(HeaderString)"
            }else if subValue is Array<Any>{
                let subClassName = wrapClassName(subKey, kvPrefix, kvSuffix)
                let subClassProperty = "    var \(subKey): [\(subClassName)]!"
                HeaderString.append("\n\(subClassProperty)")
                
                let (header,_) = parseValue2StringForSwiftStruct(subValue as! Array<Any>, subKey)
                HeaderString = "\(header)\n\r\(HeaderString)"
            }else if let subString = subValue as? String{
                if subString.isNumber{
                    let type = parseNumberString2SwiftStruct(subString)
                    let subClassProperty = "    var \(subKey): \(type)!"
                    HeaderString.append("\n\(subClassProperty)")
                }else{
                    let subClassProperty = "    var \(subKey): String!"
                    HeaderString.append("\n\(subClassProperty)")
                }
            }
        }
        HeaderString = "\(HeaderString)\n\r}"
        return (HeaderString,"")
    }
    func parseNumberString2SwiftStruct(_ input: String) -> String {
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
//MARK: Struct不需coding、copying协议
extension KVFuncHelper{
    func wrapHeaderName2SwiftStruct(_ className: String?) -> String {
        guard let classValue = className else { return "" }
        let header = "struct \(classValue) {"
        return header
    }
}
