//
//  LoginViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 02.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    @IBOutlet weak var goButton:UIButton!
    @IBOutlet var webView: WKWebView! {
        didSet {
            webView.navigationDelegate = self
        }
    }
    
    let networkService = NetworkService()

//MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.vk.com"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "7585203"),
            URLQueryItem(name: "scope", value: "262150"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.92")
        ]
        
        let request = URLRequest(url: components.url!)
        webView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc func keyboardWillShown(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let keyboardSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func hideKeyboard() {
        scrollView.endEditing(true)
    }
    
//    private func checkLogin() -> Bool {
//        guard let loginText = loginTextField.text else { return false}
//        guard let passwordText = passwordTextField.text else { return false}
//        
//        if loginText == "admin", passwordText == "12345" {
//            print("Вход выполнен!")
//            return true
//        } else {
//            print("Ошибка! Вход не выполнен.")
//            return false
//        }
//    }
//    
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if identifier == "loginSegue" {
//            if checkLogin() {
//                return true
//            } else {
//                showLoginError()
//                return false
//            }
//        }
//        return true
//    }
//    
//    private func showLoginError() {
//        let alert = UIAlertController(title: "Ошибка!", message: "Логин и/или пароль введены неверно", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Ок", style: .cancel, handler: nil)
//        alert.addAction(action)
//        
//        present(alert, animated: true, completion: nil)
//    }
    
    @IBAction func goButtonTap(_ sender: Any) {
        goButtonAnimation()
        guard let login = loginTextField.text, let password = passwordTextField.text else { return }
        
        webView.evaluateJavaScript("document.querySelector('input[name=email]').value = '\(login)'; document.querySelector('input[name=pass]').value = '\(password)'") { [weak self] (_, _) in
            self?.webView.isHidden = false
        }
    }
    
    func goButtonAnimation() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.85
        animation.toValue = 1
        animation.stiffness = 300
        animation.mass = 0.5
        animation.duration = 0.5
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        
        self.goButton.layer.add(animation, forKey: nil)
    }
}

extension LoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url,
            url.path == "/blank.html",
            let fragment = url.fragment else { decisionHandler(.allow); return }
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
        
        guard let token = params["access_token"],
            let userIdString = params["user_id"],
            let _ = Int(userIdString) else {
                decisionHandler(.allow)
                return
        }
        
        Session.instance.token = token
        Session.instance.userID = Int(userIdString) ?? 0
        
        performSegue(withIdentifier: "loginSegue", sender: nil)
        decisionHandler(.cancel)
    }
}
