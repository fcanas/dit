/// Sequence of natural numbers. 1, 2, 3, etc.
public class Naturals : Sequence {
    
    __consuming public func makeIterator() -> NaturalIterator {
        NaturalIterator()
    }
    
    public init() { }
    
    public class NaturalIterator: IteratorProtocol {
        init() {
            value = 0
        }
        var value: UInt
        public func next() -> UInt? {
            value += 1
            return value
        }
        public typealias Element = UInt
    }
    
    public typealias Element = UInt
    public typealias Iterator = NaturalIterator
}
