# WINK Biometric Authentication iOS App

This iOS app demonstrates the integration of biometric authentication services between an iOS app and Keycloak, specifically using the WINK service for user identification.

## Setup Instructions

To run this project, follow these steps:

1. **Signing Configuration**: Ensure that you have properly configured the signing capabilities for both the app and any extensions within the project.

2. **Customizing Variables**: The app relies on several key values located in the `kConstants.swift` file. These variables contain essential client information required for authentication. _Note:_ These values are placeholders and need to be replaced with actual data provided by your WINK representative. See the details below.

### Key Values in `kConstants.swift`

This file stores important client-related data that must be configured correctly for the app to function as expected:

- **clientId**: Identifies your client within the WINK API.
- **clientSecret**: The secret key assigned to your client for secure communication with the API.

You will need to adjust both `clientId` and `clientSecret` with the correct values provided by WINK.

Additionally, verify with WINK which environment will be used for your client. If you're using the STAGING environment, the `tokenEndpoint`, `verifyEndpoint`, and `logoutEndpoint` values are already correctly configured. For other environments you will need to request and update these URIs accordingly.

### URL Scheme Setup

The app is named "myapp," which is why a specific URL scheme (`myapp://`) is defined in the `info.plist` file to handle redirections. This scheme is used throughout the code for proper handling of redirects, making it mandatory that Keycloak includes `myapp://callback/*` as a valid redirect URI.

### Key Features

- **OAuth 2.0 Flow**: Implements OAuth 2.0 for authentication with Keycloak and WINK.
- **Login and Logout Handling**: Uses `SFSafariViewController` for login and logout, ensuring secure redirection and token management.
- **Token Security**: Tokens are securely handled, and SSL certificate validation is in place for all communications.
- **User Information Display**: Fetches and displays user profile details upon successful authentication.

## Detailed File Descriptions

### 1. kConstants.swift

This file defines constants for authentication and app configuration. Key values to be customized:

- `clientId`: The client identifier for the WINK API.
- `clientSecret`: The client secret for the WINK API.
- Endpoints for token requests, verification, and logout depending on the environment.

### 2. ViewController.swift

This file manages the main interface and the login flow:

- **Login Interface**: Creates a "Login with WINK" button that triggers the authentication process.
- **Authentication Flow**: Sends a request to Keycloak's auth endpoint and handles the redirect URI to extract the token and login information.
- **Callback Handling**: Intercepts navigation and processes the authentication results, including extracting tokens from the response URL.

### 3. UserInfoViewController.swift

This file manages the user profile display and logout process:

- **Post-login Interface**: Shows the user's token and profile data.
- **Logout Functionality**: Handles the logout process by interacting with the WINK API.

