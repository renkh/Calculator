//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Private on 11/26/16.
//  Copyright © 2016 Private. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var accumulator = 0.0
    
    // used for PropertyList program stores Double if Operand, String if Operation, mix of doubles and strings
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand: Double) {
        accumulator = operand
        // appends to array to remember operands
        internalProgram.append(operand as AnyObject)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
        
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> (Double))
        case BinaryOperation((Double, Double) -> (Double))
        case Equals
    }
    
    func performOperation(symbol: String){
        // appends to array to remember symbols
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation()
    {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> (Double)
        var firstOperand: Double
    }
    
    // create alias, PropertyList is now the same as AnyObject
    typealias PropertyList = AnyObject
    
    // PropertyList is AnyObject but also tells anyone reading that the program is also a PropertyList
    var program: PropertyList{
        get{
            // returns a copy of internal data structure
            return internalProgram as CalculatorBrain.PropertyList
        }
        set{
            // running a new program so clear itself out
            clear()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand: operand)
                    } else if let operand = op as? String{
                        performOperation(symbol: operand)
                    }
                }
            }
        }
    }
    
    func clear(){
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
