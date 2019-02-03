//
//  Combinator.swift
//  SwCombinator
//
//  Created by Kota Mizushima on 2019/02/03.
//

import Foundation

enum Result<A> {
    case Success(value: A, next: String)
    case Failure(next: String)
}
class Parser<A> {
    let function: (String) -> Result<A>
    init(function: @escaping (String) -> Result<A>) {
        self.function = function
    }
    
    func parse(input: String) -> Result<A> {
        return self.function(input)
    }
}
typealias P<A> = Parser<A>
extension Parser {
    func rep0() -> Parser<Array<A>> {
        return Parser<Array<A>>(function:{(input: String) in
            func rep(input: String) -> Result<Array<A>> {
                switch self.function(input) {
                case let Result.Success(value, next1):
                    switch(rep(input:next1)) {
                    case let Result.Success(result, next2):
                        var newArray = result
                        newArray.insert(value, at:0)
                        return Result.Success(value:newArray, next:next2)
                    default:
                        abort()
                }
                case let Result.Failure(next):
                    return Result.Success(value:[], next:next)
                }
            }
            return rep(input:input)
        })
    }
    
    func plus<B>(right: Parser<B>) -> Parser<(A, B)> {
        return Parser<(A, B)>(function:{(input: String) in
            let result1 = self.function(input)
            switch result1 {
            case let Result.Success(value1, next1):
                let result2 = right.function(next1)
                switch result2 {
                case let Result.Success(value2, next2):
                    return Result.Success(value:(value1, value2), next: next2)
                default:
                    return Result.Failure(next: next1)
                }
            default:
                return Result.Failure(next: input)
            }
        })
    }
    
    func or(right: Parser<A>) -> Parser<A> {
        return Parser<A>(function:{(input: String) in
            switch self.function(input) {
            case let Result.Success(value, next):
                return Result.Success(value:value, next:next)
            case let Result.Failure(next):
                return right.function(next)
            }
        })
    }
    
    func map<B>(translator: @escaping (A) -> B) -> Parser<B> {
        return Parser<B>(function:{(input: String) in
            switch self.function(input) {
            case let Result.Success(value, next):
                return Result.Success(value:translator(value), next:next)
            case let Result.Failure(next):
                return Result.Failure(next:next)
            }
        })
    }
}
func rule<A>(body: @escaping () -> Parser<A>) -> Parser<A> {
    return Parser<A>(function:{(input: String) in
        return body().function(input)
    })
}
func +<A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<(A, B)> {
    return lhs.plus(right:rhs)
}
func |<A>(lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
    return lhs.or(right:rhs)
}
func s(literal: String) -> Parser<String> {
    return Parser<String>(function:{(input: String) in
        let literalLength = literal.lengthOfBytes(using:String.Encoding.utf8)
        let inputLength = input.lengthOfBytes(using: String.Encoding.utf8)
        if(literalLength > 0 && inputLength == 0) {
            return Result.Failure(next:input)
        }else if(input.starts(with: literal)) {
            let from = input.index(input.startIndex, offsetBy:literalLength)
            return Result.Success(value:literal, next:input.substring(from:from))
        }else {
            return Result.Failure(next:input)
        }
    })
}
