//
//  TwiterAccount.swift
//  TweeterSercher
//
//  Created by Владимир Олейников on 20/4/2022.
//

import UIKit

import RxSwift
import RxCocoa

import Unbox
import Alamofire

typealias Token = String

struct TwitterAccount {
    
    private var key = "DpeivMSFzjpw6ohJYsR6GdDVN"
    private var secret = "in1iNmD9wv8KRGAdzJu8HzmO66LUPuai93mTZa6hvvvZK4lR6n"
    
    enum ApiError: Error {
        case unableToGetToken
        case invalidResponse
    }
    
    enum AccountStatus {
        case unavailable
        case authorised(Token)
    }
    
    struct AccsessToken: Unboxable {
        var token: String
        
        init(unboxer: Unboxer) throws {
            guard try unboxer.unbox(key: "token_type") == "bearer"
            else { throw ApiError.invalidResponse }
            
            self.token = try unboxer.unbox(key: "accsess_token")
        }
    }
    
    private func startDataRequestForOAuth2Token (complition: @escaping (String?) -> ()) -> DataRequest {
        let base64EncodedKeyAndSecret = Data("\(key):\(secret)".utf8).base64EncodedString()
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded;charset=UTF-8",
                                    "Authorization":"Basic \(base64EncodedKeyAndSecret)"]
        let parameters: Parameters = ["grant_type":"client_credentials"]
        
        let request = AF.request("https://api.twitter.com/oauth2/token",
                                 method: .post,
                                 parameters: parameters,
                                 encoding: URLEncoding.httpBody,
                                 headers: headers)
        
        request.response(queue: .global(), completionHandler: { response in
            guard response.error == nil,
                  let data = response.data,
                  let accsessToken: AccsessToken = try? unbox(data: data)
            else {
                complition(nil)
                return
            }
            complition(accsessToken.token)
        })
        
        return request
    }
    
        var token: Driver<AccountStatus> {
            Observable.create({ observable in
                var request: DataRequest?
                
                if let storedToken = UserDefaults.standard.string(forKey: "AccessToken") {
                    observable.onNext(.authorised(storedToken))
                } else {
                    request = startDataRequestForOAuth2Token(complition: {
                        token in
                        guard let token = token
                        else {
                            observable.onNext(.unavailable)
                            return
                        }
                        UserDefaults.standard.set(token, forKey: "AccessToken")
                        observable.onNext(.authorised(token))
                    })
                }
                
                return Disposables.create {
                    request?.cancel()
                }
            })
            .asDriver(onErrorJustReturn: .unavailable)
        }
}
