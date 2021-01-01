class Naturals : Sequence {
    
    __consuming func makeIterator() -> NaturalIterator {
        NaturalIterator()
    }
    
    class NaturalIterator: IteratorProtocol {
        init() {
            value = 0
        }
        var value: UInt
        func next() -> UInt? {
            value += 1
            return value
        }
        typealias Element = UInt
    }
    
    typealias Element = UInt
    typealias Iterator = NaturalIterator
}
