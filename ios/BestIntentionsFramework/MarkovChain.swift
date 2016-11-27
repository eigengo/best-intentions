/*
 * Best Intentions
 * Copyright (C) 2016 Jan Machacek
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
import Foundation

///
/// A simple implementation of the markov chain that holds transitions from
/// state1 -> state2, where state1 is a non-empty sequence of individual states
///
/// Imagine a session that repeats 5 times:
///
/// * biceps-curl
/// * triceps-extension
/// * lateral-raise
/// * X
///
/// It can be represented as transitions
///
/// * [biceps-curl] -> triceps-extension
/// * [biceps-curl, triceps-extension] -> lateral-raise, [triceps-extension] -> lateral-raise
/// * [biceps-curl, triceps-extension, lateral-raise] -> X, [triceps-extension, lateral-raise] -> X, [lateral-raise] -> X
/// ...
///
///
struct MarkovChain<State> where State : Hashable {
    private(set) internal var transitionMap: [StateChain<State> : MarkovTransitionSet<State>] = [:]
    
    ///
    /// Convenience method that adds a transition [previous] -> next
    /// - parameter previous: the prior state
    /// - parameter next: the next state
    ///
    mutating func addTransition(previous: State, next: State) {
        addTransition(previous: StateChain(state: previous), next: next)
    }
    
    ///
    /// Adds a transition [previous] -> next
    /// - parameter previous: the prior state chain
    /// - parameter next: the next state
    ///
    mutating func addTransition(previous: StateChain<State>, next: State) {
        for p in previous.slices {
            var transitions = transitionMap[p] ?? MarkovTransitionSet()
            transitionMap[p] = transitions.addTransition(state: next)
        }
    }
    
    ///
    /// Computes probability of transition from state1 to state2
    /// - parameter state1: the from state
    /// - parameter state2: the to state
    /// - returns: the probability 0..1
    ///
    func transitionProbability(state1: State, state2: State) -> Double {
        return transitionProbability(state1: StateChain(state: state1), state2: state2)
    }
    
    ///
    /// Computes probability of transition from slices of state1 to state2
    /// - parameter state1: the from state
    /// - parameter state2: the to state
    /// - returns: the probability 0..1
    ///
    func transitionProbability(state1: StateChain<State>, state2: State) -> Double {
        return transitionMap[state1].map { $0.probabilityFor(state: state2) } ?? 0
    }
    
    ///
    /// Computes pairs of (state, probability) of transitions from ``from`` to the next
    /// state. If favours longer slices of ``from``.
    /// - parameter from: the completed state chain
    /// - returns: non-ordered array of (state -> score)
    ///
    func transitionProbabilities(from: StateChain<State>) -> [(State, Double)] {
        let states = Array(Set(transitionMap.keys.flatMap { $0.states }))
        
        return from.slices.flatMap { fromSlice in
            return states.map { to in
                return (to, self.transitionProbability(state1: fromSlice, state2: to) * Double(fromSlice.count))
            }
        }
    }
    
}

///
/// State chain that holds a sequence of states
///
struct StateChain<State> : Hashable where State : Hashable {
    private(set) internal var states: [State]
    
    ///
    /// Empty chain
    ///
    init() {
        self.states = []
    }
    
    ///
    /// Chain with a single entry
    /// - parameter state: the state
    ///
    init(state: State) {
        self.states = [state]
    }
    
    ///
    /// Chain with many states
    /// - parameter states: the states
    ///
    init(states: [State]) {
        self.states = states
    }
    
    ///
    /// Trims this chain by keeping the last ``maximumCount`` entries
    /// - parameter maximumCount: the maximum number of entries to keep
    ///
    mutating func trim(maximumCount: Int) {
        if states.count > maximumCount {
            states.removeSubrange(0..<states.count - maximumCount)
        }
    }
    
    ///
    /// Adds a new state
    /// - parameter state: the next state
    ///
    mutating func addState(state: State) {
        states.append(state)
    }
    
    ///
    /// The number of states
    ///
    var count: Int {
        return states.count
    }
    
    ///
    /// Slices of the states from the longest one to the shortest one
    ///
    var slices: [StateChain<State>] {
        // "a", "b", "c", "d"
        // [a, b, c, d]
        // [   b, c, d]
        // [      c, d]
        // [         d]
        return (0..<states.count).map { i in
            return StateChain(states: Array(self.states[i..<states.count]))
        }
    }
    
    /// the hash value
    var hashValue: Int {
        return self.states.reduce(0) { r, s in return Int.addWithOverflow(r, s.hashValue).0 }
    }
    
}

///
/// Implementation of ``Equatable`` for ``StateChain<S where S : Equatable>``
///
func ==<State>(lhs: StateChain<State>, rhs: StateChain<State>) -> Bool where State : Equatable {
    if lhs.states.count != rhs.states.count {
        return false
    }
    for (i, ls) in lhs.states.enumerated() {
        if rhs.states[i] != ls {
            return false
        }
    }
    return true
}

///
/// The transition set
///
struct MarkovTransitionSet<State> where State : Hashable {
    private(set) internal var transitionCounter: [State : Int] = [:]
    
    func countFor(state: State) -> Int {
        return transitionCounter[state] ?? 0
    }
    
    var totalCount: Int {
        return transitionCounter.values.reduce(0) { $0 + $1 }
    }
    
    func probabilityFor(state: State) -> Double {
        return Double(countFor(state: state)) / Double(totalCount)
    }
    
    mutating func addTransition(state: State) -> MarkovTransitionSet<State> {
        transitionCounter[state] = countFor(state: state) + 1
        return self
    }
    
}
