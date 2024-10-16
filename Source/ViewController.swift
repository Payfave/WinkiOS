    import UIKit
    import AuthenticationServices
    import SafariServices


    class ViewController: UIViewController, SFSafariViewControllerDelegate {

        var loginButton: UIButton!
        private var authCode: String = ""
        private var safariViewController: SFSafariViewController?
        private var isSafariViewControllerPresented = false
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            navigationController?.navigationBar.prefersLargeTitles = true
            setupUI()
        }
        
        func setupUI() {
            setupLoginButton()
            setupConstraints()
        }
        
        func setupLoginButton() {
            loginButton = UIButton(type: .custom)
            loginButton.setTitle("Login with WINK", for: .normal)
            loginButton.setTitleColor(.white, for: .normal)
            loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            loginButton.backgroundColor = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1)
            loginButton.layer.cornerRadius = 5
            loginButton.clipsToBounds = true
            loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
            loginButton.translatesAutoresizingMaskIntoConstraints = false

            if let semicolonImage = UIImage(named: "semicolon-red") {
                loginButton.setImage(semicolonImage, for: .normal)
                loginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
                loginButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
            }
            
            loginButton.setBackgroundImage(UIImage.init(color: UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 0.9)), for: .highlighted)

            view.addSubview(loginButton)
        }
        
        func setupConstraints() {
            NSLayoutConstraint.activate([
                loginButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                loginButton.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
        
        @objc func loginAction() {
            startAuthFlow()
        }
        
        func startAuthFlow() {
            let redirectUri = "myapp://callback/"
            let state = UUID().uuidString
                    
            guard let authURL = Constants.getAuthURL(redirectUri: redirectUri, state: state) else {
                return
            }
                    
            if isSafariViewControllerPresented {
                safariViewController?.dismiss(animated: false) {
                    self.openSafariViewController(with: authURL)
                }
            } else {
                openSafariViewController(with: authURL)
            }
        }
        
        private func openSafariViewController(with url: URL) {
            guard url.scheme == "http" || url.scheme == "https" else {
                return
            }
            
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = self
            safariViewController.preferredBarTintColor = .white
            safariViewController.preferredControlTintColor = .black
            safariViewController.dismissButtonStyle = .close
            
            safariViewController.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = safariViewController.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 20
                }
            }
            
            present(safariViewController, animated: true) {
                self.isSafariViewControllerPresented = true
            }
            self.safariViewController = safariViewController
        }
        
        func handleCallbackURL(_ url: URL) {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                return
            }
            
            if let loginSessionState = queryItems.first(where: { $0.name == "login_session_state" })?.value,
               loginSessionState == "1" {
                DispatchQueue.main.async {
                    self.startAuthFlow()
                }
                return
            }
            
            if let authCode = queryItems.first(where: { $0.name == "code" })?.value {
                exchangeAuthCodeForAccessToken(authCode)
                dismissSafariViewController()
            } else {
                print("Note code found")
            }
        }
        
        func exchangeAuthCodeForAccessToken(_ authCode: String) {
            let url = Constants.tokenEndpoint
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let bodyParameters = [
                "code": authCode,
                "grant_type": "authorization_code",
                "client_id": Constants.clientId,
                "redirect_uri": "myapp://callback/"
            ]
            
            request.httpBody = bodyParameters
                .map { key, value in "\(key)=\(value)" }
                .joined(separator: "&")
                .data(using: .utf8)
            
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error fetching token: \(error.localizedDescription)")
                    return
                }

                guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Full token response: \(json)")

                        if let accessToken = json["access_token"] as? String,
                           let refreshToken = json["refresh_token"] as? String,
                           let idToken = json["id_token"] as? String {
                            DispatchQueue.main.async {
                                
                                UserDefaults.standard.set(accessToken, forKey: "accessToken")
                                UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                                UserDefaults.standard.set(idToken, forKey: "idToken")
                                
                                let userInfoVC = UserInfoViewController()
                                userInfoVC.accessToken = accessToken
                                self.navigationController?.pushViewController(userInfoVC, animated: true)
                            }
                        }
                    }
                } catch {
                    print("Error in JSON response: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
        

        private func dismissSafariViewController() {
            safariViewController?.dismiss(animated: true) {
                self.isSafariViewControllerPresented = false
                self.safariViewController = nil
            }
        }
        
        // MARK: - SFSafariViewControllerDelegate
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            print("SFSafariViewController finished")
            isSafariViewControllerPresented = false
            safariViewController = nil
        }
    }



    extension URL {
        var queryParameters: [String: String]? {
            guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
                  let queryItems = components.queryItems else { return nil }
            return queryItems.reduce(into: [String: String]()) { (result, item) in
                result[item.name] = item.value
            }
        }
    }

    extension UIImage {
        convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
            let rect = CGRect(origin: .zero, size: size)
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
            color.setFill()
            UIRectFill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let cgImage = image?.cgImage else { return nil }
            self.init(cgImage: cgImage)
        }
    }

    extension String {
        func base64UrlToBase64() -> String {
            var base64 = self
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            if base64.count % 4 != 0 {
                base64.append(String(repeating: "=", count: 4 - base64.count % 4))
            }
            return base64
        }
    }
