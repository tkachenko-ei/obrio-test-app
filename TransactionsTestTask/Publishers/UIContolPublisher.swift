//
//  UIContolPublisher.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

extension Publishers {
    struct UIControlPublisher<Control>: Publisher where Control: UIControl {
        typealias Output = Control
        typealias Failure = Never

        private var control: Control
        private let event: UIControl.Event

        init(control: Control, event: UIControl.Event) {
            self.control = control
            self.event = event
        }

        public func receive<S>(subscriber: S)
        where S: Subscriber, S.Input == Control, S.Failure == Never {
            let subscription = Subscription(
                subscriber: subscriber,
                control: control,
                event: event
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.UIControlPublisher {
    final class Subscription<S, C>: Combine.Subscription
    where S: Subscriber, C: UIControl, S.Input == C, S.Failure == Never {
        private var subscriber: S?
        private let control: C
        private let event: UIControl.Event
        
        init(subscriber: S, control: C, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            
            self.control.addTarget(self, action: #selector(eventHandler), for: event)
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            self.control.removeTarget(self, action: #selector(eventHandler), for: event)
            self.subscriber = nil
        }
        
        @objc private func eventHandler() {
            _ = self.subscriber?.receive(control)
        }
    }
}

extension UIControl {
    func publisher(for event: UIControl.Event) -> Publishers.UIControlPublisher<UIControl> {
        return Publishers.UIControlPublisher(control: self, event: event)
    }
}

