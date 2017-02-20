//
//  Calculator.swift
//  Calculator
//
//  Created by pipasese on 2017/2/9.
//  Copyright © 2017年 PIPASESE. All rights reserved.
//

import UIKit

extension Character{
    var cal_isOP:Bool{
        let op = "+-*/"
        return op.contains(String.init(self))
    }
}

extension String{
    var cal_priority:Int{
        switch self {
        case "*","/":
            return 2
        case "+","-":
            return 1
        default:
            return 0
        }
    }
}
/*
    let m = Calculate(str: "-2*9/(2+10)+22*2-13+11.9*(1+2*(2+2/1))*100+222")
    if let error = m.0 {
        print(error.domain)
    }
    if let result = m.1 {
        print(result)//10961.5
    }
*/
/// 解析表达式方法
///
/// - Parameter str: 字符串
/// - Returns: 元组数据
public func Calculate(str:String) -> (error:NSError?,result:Float?) {
    if let error = Calculator.checkAvailable(str: str) {
        return (error,nil)
    }
    return (nil,Calculator.calculate(str: str))
}

/// 解析数学表达式类
class Calculator: NSObject {
    
    /// 弹出栈
    ///
    /// - Parameters:
    ///   - op: 操作符栈
    ///   - np: 操作值栈
    class func popStack(op:inout Array<String>,np:inout Array<Float>){
        let lastOp = op.popLast()!
        let p1 = np.popLast()!
        let p2 = np.popLast()!
        var p3 = Float()
        switch lastOp {
        case "+":
            p3 = p1 + p2
        case "-":
            p3 = p2 - p1
        case "*":
            p3 = p1 * p2
        case "/":
            p3 = p2 / p1
        default:
            break
        }
        np.append(p3)
    }
    
    /// 解析数组，将数组解析成运算符栈和操作符栈
    ///
    /// - Parameter arr:
    /// - Returns:
    class func calculateArr(arr:Array<String>)->Array<Float>{
        var op = Array<String>()
        var np = Array<Float>()
        for x in arr {
            if let number = Float.init(x){
                np.append(number)
            }else{
                if op.isEmpty {
                    op.append(x)
                    continue
                }
                while !op.isEmpty && op.last!.cal_priority >= x.cal_priority  {
                    Calculator.popStack(op: &op , np: &np)
                }
                op.append(x)
            }
        }
        while np.count > 1 {
            Calculator.popStack(op: &op, np: &np)
        }
        return np
    }
    
    class func checkAvailable(str:String)->NSError?{
        if str.contains("()") {
            return NSError.init(domain: "空括号", code: -1, userInfo: nil)
        }
        var leftNumber = 0
        var rightNumber = 0
        var strCalculate = str
        if let m = str.characters.first {
            if String.init(m) == "-" {
                strCalculate = "0" + strCalculate
            }
        }
        var current = String()
        for i in 0..<strCalculate.characters.count {
            let x = String.init(strCalculate[strCalculate.index(strCalculate.startIndex, offsetBy: i)])
            if !"1234567890.+-*/()".contains(x)  {
                return NSError.init(domain: "非法字符"+x, code: -1, userInfo: nil)
            }
            if x == "("{
                leftNumber += 1
            }else if x == ")"{
                rightNumber += 1
            }else if current.cal_priority > 0 && x.cal_priority > 0 {
                return NSError.init(domain: "连续操作符"+x+current, code: -1, userInfo: nil)
            }
            current = x
        }
        if leftNumber != rightNumber {
            return NSError.init(domain: "括号不匹配", code: -1, userInfo: nil)
        }
        return nil
    }
    /// 计算数学表达式的值
    ///
    /// - Parameter str: 数学表达式
    /// - Returns: 返回值
    class func calculate(str:String)->Float{
        var begin = 0
        var end = 0
        var count = 0
        var strCalculate = str
        if let m = str.characters.first {
            if String.init(m) == "-" {
                strCalculate = "0" + strCalculate
            }
        }
        var subArr = [(String,Int,Int)]()
        for i in 0..<strCalculate.characters.count {
            let x = String.init(strCalculate[strCalculate.index(strCalculate.startIndex, offsetBy: i)])
            if x == "("{
                count += 1
                if begin == 0 {
                    begin = i
                }
            }else if x == ")"{
                count -= 1
                if count == 0 {
                    end = i
                    let subString = strCalculate[strCalculate.index(strCalculate.startIndex, offsetBy: begin+1)..<strCalculate.index(strCalculate.startIndex, offsetBy: end)]
                    if subString.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                        let subValue = Calculator.calculate(str:subString)
                        subArr.append((String(subValue),begin,end))
                    }
                    begin = 0
                    end = 0
                }
            }
        }
        for (subValue,beginOffset,endOffset) in subArr.reversed() {
            let range = Range<String.Index>.init(uncheckedBounds: (strCalculate.index(strCalculate.startIndex, offsetBy: beginOffset),strCalculate.index(strCalculate.startIndex, offsetBy: endOffset+1)))
            strCalculate.replaceSubrange(range, with: subValue)
        } 
        let arr = Calculator.anynalyze(str: strCalculate)
        return Calculator.calculateArr(arr: arr)[0]
    }
    
    /// 将字符串转换成数组
    ///
    /// - Parameter str: 字符串
    /// - Returns: 数组
    class func anynalyze(str:String) -> (Array<String>) {
        var items = [String]()
        var current = String()
        var strTer = str
        if str[str.index(str.startIndex, offsetBy: 0)..<str.index(str.startIndex, offsetBy: 1)] == "-" {
            strTer = "0"+str
        }
        for character in strTer.characters {
            if character.cal_isOP {
                if let cN = String.init(current) {
                    if !cN.isEmpty {
                        items.append(cN)
                        current = String()
                    }
                }
                items.append(String.init(character))
            }else{
                current.append(character)
            }
        }
        if !current.isEmpty {
            items.append(String.init(current)!)
        }
        return items
    }
}
