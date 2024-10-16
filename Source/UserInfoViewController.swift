import UIKit
import SafariServices

class UserInfoViewController: UIViewController, SFSafariViewControllerDelegate {
    var toHomeButton: UIButton!
    var logoutButton: UIButton!
    var verifyButton: UIButton!
    var accessToken: String?
    var safariViewController: SFSafariViewController?

    private var responseLabel = UILabel()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white

        let tokenLabel = UILabel()
        tokenLabel.textAlignment = .center
        tokenLabel.numberOfLines = 0
        tokenLabel.textColor = .black
        tokenLabel.translatesAutoresizingMaskIntoConstraints = false
        if let token = accessToken {
            let shortToken = token.prefix(5) + "..." + token.suffix(5)
            tokenLabel.text = "Access Token: \(shortToken)"
        }
        view.addSubview(tokenLabel)
        
        logoutButton = UIButton(type: .custom)
        logoutButton.setTitle("Log-out", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        logoutButton.backgroundColor = UIColor.red
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        logoutButton.layer.cornerRadius = 5
        logoutButton.clipsToBounds = true
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        view.addSubview(logoutButton)

        toHomeButton = UIButton(type: .custom)
        toHomeButton.setTitle("Home", for: .normal)
        toHomeButton.setTitleColor(.white, for: .normal)
        toHomeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        toHomeButton.backgroundColor = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1)
        toHomeButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        toHomeButton.layer.cornerRadius = 5
        toHomeButton.clipsToBounds = true
        toHomeButton.translatesAutoresizingMaskIntoConstraints = false
        toHomeButton.addTarget(self, action: #selector(toHomeAction), for: .touchUpInside)
        view.addSubview(toHomeButton)
        
        verifyButton = UIButton(type: .custom)
        verifyButton.setTitle("Validate Token", for: .normal)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        verifyButton.backgroundColor = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1)
        verifyButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        verifyButton.layer.cornerRadius = 5
        verifyButton.clipsToBounds = true
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        verifyButton.addTarget(self, action: #selector(verifyClientAction), for: .touchUpInside)
        view.addSubview(verifyButton)
        
        responseLabel.numberOfLines = 0
        responseLabel.textColor = .black
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(responseLabel)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            tokenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tokenLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tokenLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tokenLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            verifyButton.topAnchor.constraint(equalTo: tokenLabel.bottomAnchor, constant: 20),
            verifyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            responseLabel.topAnchor.constraint(equalTo: verifyButton.bottomAnchor, constant: 20),
            responseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            responseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: responseLabel.bottomAnchor, constant: 20),
            
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: toHomeButton.topAnchor, constant: -20),

            toHomeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toHomeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func toHomeAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func logoutAction() {
        guard let idToken = UserDefaults.standard.string(forKey: "idToken") else {
            print("ID Token not available")
            return
        }
        
        let urlString = Constants.logoutEndpoint
        var components = URLComponents(string: urlString)!
        
        components.queryItems = [
            URLQueryItem(name: "post_logout_redirect_uri", value: "myapp://callback/logout"),
            URLQueryItem(name: "id_token_hint", value: idToken),
            URLQueryItem(name: "client_id", value: "sephora")
        ]
        
        guard let url = components.url else {
            print("Failed to create URL from components")
            return
        }
        
        openLogoutURL(url)
    }

    
    func openLogoutURL(_ url: URL) {
        print("openLogoutURL: \(url)")
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        self.safariViewController = safariViewController
        present(safariViewController, animated: true, completion: nil)
    }

    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true) {
            self.safariViewController = nil
            self.navigateToLogin()
        }
    }

   
    @objc func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.removeObject(forKey: "idToken")
        UserDefaults.standard.synchronize()
    
        safariViewController?.dismiss(animated: true, completion: nil)
        
        dismiss(animated: true) {
            if let navigationController = self.navigationController {
                navigationController.popToRootViewController(animated: true)
            } else {
                let loginVC = ViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                if let window = UIApplication.shared.windows.first {
                    window.rootViewController = navController
                    window.makeKeyAndVisible()
                }
            }
        }
    }
    
    private func navigateToLogin() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.synchronize()

        if let window = UIApplication.shared.windows.first {
            let loginVC = ViewController()
            let navController = UINavigationController(rootViewController: loginVC)
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
    }
    
    @objc private func verifyClientAction() {
        guard let token = accessToken else { return }
        spinner.startAnimating()
        verifyClient(accessToken: token)
    }

    private func verifyClient(accessToken: String) {
        let url = Constants.verifyEndpoint
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "ClientId": Constants.clientId,
            "AccessToken": accessToken,
            "ClientSecret": Constants.clientSecret
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    self?.responseLabel.text = "Response: \(responseString)"
                } else if let error = error {
                    self?.responseLabel.text = "Failed to verify: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
