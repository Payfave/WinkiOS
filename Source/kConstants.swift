import Foundation

struct Constants {
    static let clientId = "<your-wink-client-id>"
    static let clientSecret = "<your-wink-client-secret>"
    
    static let tokenEndpoint = URL(string: "https://stageauth.winkapis.com/realms/wink/protocol/openid-connect/token")!
    static let verifyEndpoint = URL(string: "https://stagelogin-api.winkapis.com/api/ConfidentialClient/verify-client")!
    static let logoutEndpoint = "https://stageauth.winkapis.com/realms/wink/protocol/openid-connect/logout"
    static let authEndpoint = "https://stageauth.winkapis.com/realms/wink/protocol/openid-connect/auth"
    
    static func getAuthURL(redirectUri: String, state: String) -> URL? {
        var components = URLComponents(string: authEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid")
        ]
        return components?.url
    }
}
