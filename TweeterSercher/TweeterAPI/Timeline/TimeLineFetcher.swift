//
//  TimeLineFetcher.swift
//  TweeterSercher
//
//  Created by Владимир Олейников on 27/4/2022.
//

import Foundation

import RxSwift
import RxCocoa
import RxRealm

import RealmSwift
import Reachability
import Unbox

class TimeLineFetcher {
    private let timerDelay = 30
    private let bag = DisposeBag()
    private let feedCursor = BehaviorRelay<TimelineCursor>(value: .none)
    
    // MARK: input
    let paused = BehaviorRelay<Bool>(value: false)
    
    // MARK: output
    let timeline: Observable<[Tweet]>
    
    private init(account: Driver<TwitterAccount.AccountStatus>,
                 jsonProvider: @escaping (Token, TimelineCursor) -> Observable<[JSONObject]>) {
        // subscribe for the current twitter account
        //
        let accountsToken: Observable<Token> = account
          .filter { account in
            switch account {
            case .authorised:
                return true
            default:
                return false
            }
          }
          .map { account -> Token in
            switch account {
            case .authorised(let token):
              return token
            default:
                fatalError()
            }
          }
          .asObservable()
        
        // timer that emits a reachable logged account
        let reachableTimerWithAccount = Observable.combineLatest(
          Observable<Int>.timer(.seconds(0), period: .seconds(timerDelay), scheduler: MainScheduler.instance),
          Reachability.rx.reachable,
          accountsToken,
          paused.asObservable(),
          resultSelector: { _, reachable, account, paused in
            return (reachable && !paused) ? account : nil
          })
          .filter { $0 != nil }
          .map { $0! }
    }
}
