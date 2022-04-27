//
//  Reachability+reachable.swift
//  TweeterSercher
//
//  Created by Владимир Олейников on 27/4/2022.
//

import Foundation
import Reachability
import RxSwift

extension Reachability {
    enum Errors: Error {
        case unavailable
    }
}

extension Reactive where Base: Reachability {
    
    static var reachable: Observable<Bool> {
        return Observable.create { observer in
            
            let reachability = try? Reachability()
            
            if let reachability = reachability {
                observer.onNext(reachability.connection != .unavailable)
                reachability.whenReachable = { _ in observer.onNext(true) }
                reachability.whenUnreachable = { _ in observer.onNext(false) }
                do {
                    try reachability.startNotifier()
                } catch {
                    print("Unable to start notifier")
                }
            } else {
                observer.onError(Reachability.Errors.unavailable)
            }
            return Disposables.create {
                reachability?.stopNotifier()
            }
        }
    }
}
