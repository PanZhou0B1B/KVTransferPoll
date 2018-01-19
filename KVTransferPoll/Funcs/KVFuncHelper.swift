//
//  KVFuncHelper.swift
//  KVTransferPoll
//
//  Created by zhoupanpan on 2017/10/27.
//  Copyright © 2017年 panzhow. All rights reserved.
//
//TODO: 
import Cocoa

class KVFuncHelper: NSObject {
    enum LanType: String {
        case objc = "Object-C"
        case swiftClass = "Swift-Class"
        case swiftStruct = "Swift-Struct"
        static let allValues = [objc.rawValue,swiftClass.rawValue,swiftStruct.rawValue]
        
        init?(type: Int){
            switch type {
            case 0:
                self = .objc
            case 1:
                self = .swiftClass
            case 2:
                self = .swiftStruct
            default:
                return nil
            }
        }
        mutating func refresh(type: Int){
            switch type {
            case 0:
                self = .objc
            case 1:
                self = .swiftClass
            case 2:
                self = .swiftStruct
            default:
                break
            }
        }
    }
    var kvPrefix = ""
    var kvSuffix = ""
    var kvLan = LanType.objc
    var kvCodingEnable = false
    var kvCopyingEnable = false
    
    public func transferOri(_ original: String?) -> (readableOri: String,objc: (header: String,imp: String)) {
        guard let originalValue = original else { return ("",("","")) }
        var readable = originalValue
        let jsonData = originalValue.data(using: .utf8,allowLossyConversion:false)
        if jsonData == nil{
            return ("",("",""))
        }
        //MARK:json object
        var jsonObj = try? JSONSerialization.jsonObject(with:jsonData!, options: .mutableContainers ) as! Dictionary<String, Any>
        if((jsonObj) != nil){
            let readablejsonData = try? JSONSerialization.data(withJSONObject: jsonObj!, options: .prettyPrinted)
            let jsonStringReadable = String.init(data: readablejsonData!, encoding: .utf8)
            readable = jsonStringReadable!
        }
        if(jsonObj == nil){
            jsonObj = try? PropertyListSerialization.propertyList(from:jsonData!, options: [], format: nil) as! Dictionary<String, Any>
        }
        if jsonObj == nil{
            return ("",("",""))
        }
        if self.kvLan == .objc{
            //MARK:oc file string
            let (header,imp) = parseValue2StringForOC(jsonObj,"Root")
            return (readable,(header,imp))
        }else if self.kvLan == .swiftClass{
            let (header,_) = parseValue2StringForSwift(jsonObj,"Root")
            return (readable,(header,""))
        }else{
            let (header,_) = parseValue2StringForSwiftStruct(jsonObj,"Root")
            return (readable,(header,""))
        }
        
    }
}

//MARK: 类名、属性名命名方式
extension KVFuncHelper{
    func wrapClassName(_ key: String? ,_ prefix: String,_ suffix: String) -> String {
        guard let clzKey = key else { return "" }
        let first = clzKey.prefix(1)
        let other = clzKey.suffix(clzKey.count-1)
        var wrapClzKey = "\(first.uppercased())\(other)"
        wrapClzKey.IMXAddPrefix(prefix)
        wrapClzKey.IMXAppendSuffix(suffix)
        return wrapClzKey
    }
    func wrapPropertyName(_ value: String) -> String {
        guard value != "" else { return value }
        let first = value.prefix(0)
        let other = value.suffix(value.count-1)
        let wrapValue = "\(first.lowercased())\(other)"
        return wrapValue
    }
}

//MARK: copyright定义
extension KVFuncHelper{
    class func copyrightInfo()->String{
        var mString = String()
        mString.append("//\n")
        mString.append("//  <# file name #> \n")
        mString.append("//  <# pro name #> \n")
        mString.append("//\n")
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let result =  formatter.string(from: now)
        mString.append("//  Created by <# author #> on \(result). \n")
        formatter.dateFormat = "yyyy"
        let result_Year = formatter.string(from: now)
        mString.append("//  Copyright © \(result_Year)年 <# pro name #>. All rights reserved.\n")
        mString.append("//\n")
        return mString
    }
}
extension String{
    var isNumber: Bool{
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
   mutating func IMXtrim() {
        self = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    mutating func IMXAddPrefix(_ prefix: String?) {
        guard let prefixValue = prefix else { return self.IMXtrim() }
        self.IMXtrim()
        self = prefixValue+self
    }
    mutating func IMXAppendSuffix(_ suffix: String?) {
        guard let suffixValue = suffix else { return self.IMXtrim() }
        self.IMXtrim()
         self = self+suffixValue
    }
    
}
