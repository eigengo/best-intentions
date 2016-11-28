import Foundation
import XCTest

class MarkovChainTests : XCTestCase {
    private let (labels, transitions): ([String], [String]) = {
        let a = "a"
        let b = "b"
        let c = "c"
        let transitions = [
                b, a, a, a, b, a,
                b, a, b, a, b, a,
                b, a, b, a, b, b,
                a, b, a, b, a, b,
                a, b, a, b, a, b,
                a, b, a, b, a, b,
                a, b, a, b, a, b]
        return ([a, b, c], transitions)
    }()

    func testTrivial() {
        var c: MarkovChain<String> = MarkovChain()
        let s = StateChain(states: transitions)
        c.addTransition(previous: s, next: labels.first!)
        
        for s1 in labels {
            for s2 in labels {
                let prob = c.transitionProbability(state1: s1, state2: s2)
                print("\(s1) -> \(s2): \(prob)")
            }
        }
        
    }
    
}
