//
//  SceneDelegate.swift
//  TweeterSercher
//
//  Created by Владимир Олейников on 20/4/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let winScene = (scene as? UIWindowScene) else { return }
        
        let usersVC = UIViewController()
        usersVC.view.backgroundColor = .blue
        let navVC = UINavigationController(rootViewController: usersVC)
        
        window = UIWindow(windowScene: winScene)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }
}

