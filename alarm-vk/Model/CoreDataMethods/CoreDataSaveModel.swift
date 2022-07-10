//
//  CoreDataSave.swift
//  Cats
//
//  Created by Mark Khmelnitskii on 10.04.2022.
//

import CoreData
import Combine

struct CoreDataSaveModelPublisher: Publisher {
    
    typealias Output = Bool
    typealias Failure = NSError
    private let action: () -> Void
    private let context: NSManagedObjectContext
    
    init(action: @escaping () -> Void, context: NSManagedObjectContext) {
        self.action = action
        self.context = context
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, context: context, action: action)
        subscriber.receive(subscription: subscription)
    }
    
    final class Subscription<S> where S : Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private let action: () -> Void
        private let context: NSManagedObjectContext
        init(subscriber: S, context: NSManagedObjectContext, action: @escaping () -> Void) {
            self.subscriber = subscriber
            self.context = context
            self.action = action
        }
    }
}

extension CoreDataSaveModelPublisher.Subscription: Subscription, Cancellable {
    func request(_ demand: Subscribers.Demand) {
        guard let subscriber = subscriber, demand > 0 else { return }
        var demand = demand
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                self.action()
                demand -= 1
                try self.context.save()
                demand += subscriber.receive(true)
            } catch {
                subscriber.receive(completion: .failure(error as NSError))
            }
        }
    }
    func cancel() {
        subscriber = nil
    }
}
