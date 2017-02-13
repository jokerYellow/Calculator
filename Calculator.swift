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

/// 计算数学表达式类
class Calculator: NSObject {
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
                    let subValue = Calculator.calculate(str:subString)
                    subArr.append((String(subValue),begin,end))
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
