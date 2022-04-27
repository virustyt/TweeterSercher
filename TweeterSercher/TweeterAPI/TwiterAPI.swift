//
//  TwiterAPI.swift
//  TweeterSercher
//
//  Created by Владимир Олейников on 22/4/2022.
//

import Foundation

import RxSwift
import RxCocoa

import Alamofire

typealias JSONObject = [String: Any]

protocol TwiterAPIProtocol {
    static func twits(of username: String) -> (Token,TimeLineCursor) -> Observable<[JSONObject]>
}


