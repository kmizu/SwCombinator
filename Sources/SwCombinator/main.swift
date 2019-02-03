class Expression {
    static let E: P<Int> = rule(body:{() in A})
    static let A: P<Int> = rule(body:{() in
        (M + ((s(literal:"+") + M) | (s(literal:"-") + M)).rep0()).map{(v) in
            let (l, rs) = v
            return rs.reduce(l, {(l:Int, b:(String, Int)) in
                let (op, r) = b
                return op == "+" ? l + r : l - r
            })
        }
    })
    static let M: P<Int> = rule(body:{() in
        (P + ((s(literal:"*") + P) | (s(literal:"/") + P)).rep0()).map{(v) in
            let (l, rs) = v
            return rs.reduce(l, {(l:Int, b:(String, Int)) in
                let (op, r) = b
                return op == "*" ? l * r : l / r
            })
        }
    })
    static let P: P<Int> = rule(body:{
        () in
        (
            (s(literal:"(") + E + s(literal:")")).map {(v) in
                let ((_, r), _) = v
                return r
            }
        |   N)
    })
    static let N: P<Int> = rule(body:{
        () in Digit.map(translator: {v in Int(v)!})
    })

    static let Digit: Parser<String> = rule(body:{
        () in
        s(literal:"0") | s(literal:"1") | s(literal:"2") | s(literal:"3") | s(literal:"4")
      | s(literal:"5") | s(literal:"6") | s(literal:"7") | s(literal:"8") | s(literal:"9")
    })
}
let E = Expression.E
print(E.parse(input:"(1+2)*3"))
