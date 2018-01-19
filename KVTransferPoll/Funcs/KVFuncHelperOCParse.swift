//
//  KVFuncHelperOCParse.swift
//  KVTransferPoll
//
//  Created by zhoupanpan on 2017/11/14.
//  Copyright © 2017年 panzhow. All rights reserved.
//

import Foundation
//MARK:Object-C转换
extension KVFuncHelper{
    
    public func parseValue2StringForOC(_ input: Any?,_ key: String) -> (Header: String,imp: String) {
        guard let inputValue = input else { return ("","") }
        
        if inputValue is Dictionary<String, Any>{
            let (header,imp) = parseDic2String(inputValue as? Dictionary<String, Any>,key)
            return (header,imp)
        }else if inputValue is Array<Any>{
            let (header,imp) = parseArray2String(inputValue as? Array<Any>,key)
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
    func parseArray2String(_ input: Array<Any>?,_ key: String) -> (Header: String,imp: String) {
        guard let inputArray = input else { return ("","") }
        let className = wrapClassName(key, kvPrefix, kvSuffix)
        var HeaderString = ""
        var impString = ""
        
        if inputArray.count<=0{
            HeaderString = wrapHeaderName(className)
            impString = "@implementation \(className)"
            HeaderString = "///can not parse successfully\n\r\(HeaderString);"
            
            HeaderString = "\(HeaderString)\n\r@end"
            impString = "\(impString)\n\r@end"
        }else{
            let firstValue = inputArray.first
            
            let (header,imp) = parseValue2StringForOC(firstValue, key)
            HeaderString = "\(header)"
            impString = "\(imp)"
        }
        return (HeaderString,impString)
    }
    func parseDic2String(_ input: Dictionary<String, Any>?,_ key: String) -> (Header: String,imp: String) {
        guard let inputDic = input else { return ("","") }
        var HeaderString = ""
        var impString = ""
        
        let className = wrapClassName(key, kvPrefix, kvSuffix)
        HeaderString = wrapHeaderName(className)
        impString = "@implementation \(className)"
        var proptyValues: Array<Any> = Array.init()
        
        for (subKey,subValue) in inputDic{
            var isBaseType: Bool = false
            if subValue is Dictionary<String,Any>{
                let subClassName = wrapClassName(subKey, kvPrefix, kvSuffix)
                let subClassProperty = "@property (nonatomic,strong)\(subClassName)*  \(subKey);"
                proptyValues.append((subKey,isBaseType))
                HeaderString.append("\n\(subClassProperty)")
                
                let (header,imp) = parseValue2StringForOC(subValue as! Dictionary<String, Any>, subKey)
                HeaderString = "\(header)\n\r\(HeaderString)"
                impString = "\(imp)\n\r\(impString)"
            }else if subValue is Array<Any>{
                let subClassName = wrapClassName(subKey, kvPrefix, kvSuffix)
                let subClassProperty = "@property (nonatomic,copy)NSArray<\(subClassName) *> *\(subKey);"
                proptyValues.append((subKey,isBaseType))
                HeaderString.append("\n\(subClassProperty)")
                
                let (header,imp) = parseValue2StringForOC(subValue as! Array<Any>, subKey)
                HeaderString = "\(header)\n\r\(HeaderString)"
                impString = "\(imp)\n\r\(impString)"
            }else if let subString = subValue as? String{
                if subString.isNumber{
                    let subClassProperty = parseNumber2String(subString , subKey)
                    isBaseType = true
                    proptyValues.append((subKey,isBaseType))
                    HeaderString.append("\n\(subClassProperty)")
                }else{
                    let subClassProperty = "@property (nonatomic,copy)NSString  *\(subKey);"
                    proptyValues.append((subKey,isBaseType))
                    HeaderString.append("\n\(subClassProperty)")
                }
            }
        }
        let CCImp = wrapImp(proptyValues as! Array<(String, Bool)>, className: className)
        HeaderString = "\(HeaderString)\n\r@end"
        impString = "\(impString)\n\r\(CCImp.encode)\(CCImp.decode)\(CCImp.copy)\n\r@end"
        return (HeaderString,impString)
    }
    func parseNumber2String(_ input: String,_ key: String) -> String {
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
        return "@property (nonatomic,assign)\(typeName!) \(key);"
    }
}
//MARK: 支持coding、copying协议
extension KVFuncHelper{
    func wrapHeaderName(_ className: String?) -> String {
        guard let classValue = className else { return "" }
        var header = "@interface \(classValue): NSObject"
        if self.kvCodingEnable && self.kvCopyingEnable{
            header = "\(header)<NSCoding,NSCopying>"
            return header
        }
        if self.kvCodingEnable{
            header = "\(header)<NSCoding>"
        }
        if self.kvCopyingEnable{
            header = "\(header)<NSCopying>"
            return header
        }
        return header
    }
    func wrapImp(_ properties: Array<(String,Bool)>,className: String) -> (encode: String,decode: String,copy: String) {
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
            codingEncode = "- (void)encodeWithCoder:(NSCoder *)aCoder{\n"
            codingDecode = "- (instancetype)initWithCoder:(NSCoder *)aDecoder{\n   self = [super init];\n\n"
        }
        if self.kvCopyingEnable{
            copying = "- (instancetype)copyWithZone:(NSZone *)zone{\n   \(className) *copy = [\(className) new];\n\r"
        }
        for (value,isBaseType) in properties {
            var encode = ""
            var decode = ""
            var copy = ""
            if isBaseType{
                encode = "   [aCoder encodeObject:@(_\(value)) forKey:@\"\(value)\"];\n"
                decode = "   self.\(value) = [[aDecoder decodeObjectForKey:@\"\(value)\"] integerValue];\n"
                copy = "   copy.\(value) = self.\(value);\n"
            }else{
                encode = "   [aCoder encodeObject:_\(value) forKey:@\"\(value)\"];\n"
                decode = "   self.\(value) = [aDecoder decodeObjectForKey:@\"\(value)\"];\n"
                copy = "   copy.\(value) = [self.\(value) copy];\n"
            }
            codingEncode = "\(codingEncode)\(encode)"
            codingDecode = "\(codingDecode)\(decode)"
            copying = "\(copying)\(copy)"
        }
        codingEncode = "\(codingEncode)}\n\r"
        codingDecode = "\(codingDecode)\n   return self;\n}\n\r"
        copying = "\(copying)\n   return copy;\r}\n\n\r"
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
