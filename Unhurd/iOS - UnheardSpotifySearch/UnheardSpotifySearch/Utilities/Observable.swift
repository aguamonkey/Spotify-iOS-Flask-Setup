//
//  Observable.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 09/02/2024.
//

import Foundation

/// A generic class that allows a value to be observed for changes.
/// When the value changes, any registered listener is notified with the new value.
/// - Parameter T: The type of value that is being observed.
class Observable<T> {
    
    /// The value being observed. Whenever it is set (even to the same value),
    /// the `listener` closure is executed with the new value.
    var value: T? {
        didSet {
            // Notify the listener of the new value.
            listener?(value)
        }
    }
    
    /// A closure that can be registered to be notified when the `value` changes.
    /// - Parameter T?: The new value or nil if not set.
    private var listener: ((T?) -> Void)?
    
    /// Binds a listener to the `Observable`. The listener will be notified of the current
    /// value immediately, and then again whenever the value changes.
    /// - Parameter listener: A closure to be invoked when the value changes.
    func bind(_ listener: @escaping (T?) -> Void) {
        // Set the listener closure.
        self.listener = listener
        // Notify the listener of the current value.
        listener(value)
    }
}
