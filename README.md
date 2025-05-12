# MozzyKeychain

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/Swift-6+-orange.svg)](https://swift.org/)
[![Platform](https://img.shields.io/badge/platform-iOS%2013.0+-lightgrey.svg)](https://developer.apple.com/ios/)

A lightweight, secure, and easy-to-use keychain wrapper for iOS applications. MozzyKeychain provides a clean interface for storing sensitive data like tokens, API keys, and custom values in the iOS keychain.

## Features

- ✅ Simple and intuitive API for keychain operations
- ✅ Support for access and refresh tokens
- ✅ API key management
- ✅ Custom key-value pair storage
- ✅ Error handling with detailed error types
- ✅ Swift Package Manager support
- ✅ Comprehensive test coverage with Quick and Nimble

## Architecture

MozzyKeychain follows a clean layered architecture that provides both simplicity and flexibility:

![MozzyKeychain Architecture](https://raw.githubusercontent.com/mozzy-swift/MozzyKeychain/main/Documentation/architecture.svg)

The architecture consists of the following components:

1. **Public API Layer**:
   - `KeychainKit` protocol - The main interface for client code
   - `KeychainItemType` - Enum for different types of stored items
   - `TokenType` - Enum for token types (access, refresh)

2. **Implementation Layer**:
   - `KeychainKitImpl` - Concrete implementation of KeychainKit
   - `KeychainKitFactory` - Factory for creating KeychainKit instances

3. **Core Layer**:
   - `Keychain` protocol - Low-level keychain operations
   - `KeychainImpl` - Security framework wrapper
   - `KeychainResult` - Model for keychain operation results

This layered approach allows for clear separation of concerns, testability, and easy substitution of components when needed.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/mozzy-swift/MozzyKeychain.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Swift Packages → Add Package Dependency
2. Enter package URL: `https://github.com/mozzy-swift/MozzyKeychain.git`
3. Specify the version (or branch/commit)

## Quick Start

### Initialize KeychainKit

```swift
import MozzyKeychain

// Create an instance using the factory
let keychainKit = KeychainKitFactory.make()
```

### Managing Tokens

```swift
// Save tokens
try keychainKit.saveToken(.accessToken, value: "eyJhbGciOiJIUzI1NiIsInR5cCI...")
try keychainKit.saveToken(.refreshToken, value: "refresh-token-value")

// Read tokens
let accessToken = try keychainKit.readToken(.accessToken)
let refreshToken = try keychainKit.readToken(.refreshToken)

// Delete tokens
try keychainKit.deleteToken(.accessToken)
try keychainKit.deleteToken(.refreshToken)
```

### Managing API Keys

```swift
// Save an API key
try keychainKit.save(itemType: .apiKey("google-maps"), value: "AIzaSy...")

// Read an API key
let apiKey = try keychainKit.read(itemType: .apiKey("google-maps"))

// Delete an API key
try keychainKit.delete(itemType: .apiKey("google-maps"))
```

### Managing Custom Values

```swift
// Save a custom value
try keychainKit.save(itemType: .custom("my-setting"), value: "custom-value")

// Read a custom value
let customValue = try keychainKit.read(itemType: .custom("my-setting"))

// Delete a custom value
try keychainKit.delete(itemType: .custom("my-setting"))
```

### Using Custom Service Names

```swift
// By default, the app's bundle identifier is used as the service name
// You can specify a custom service name if needed:

let customService = "com.myapp.specialservice"

try keychainKit.save(
    itemType: .custom("special-key"), 
    value: "special-value", 
    by: customService
)

let value = try keychainKit.read(
    itemType: .custom("special-key"), 
    by: customService
)

try keychainKit.delete(
    itemType: .custom("special-key"), 
    by: customService
)
```

### Error Handling

```swift
do {
    let token = try keychainKit.readToken(.accessToken)
    print("Token: \(token)")
} catch KeychainError.noPassword {
    print("Token not found in keychain")
} catch {
    print("Error reading token: \(error.localizedDescription)")
}
```

## Demo Application

The repository includes a demo application that demonstrates all features of MozzyKeychain. This example app provides a simple user interface to test all keychain operations.

![MozzyKeychain Example App](https://raw.githubusercontent.com/mozzy-swift/MozzyKeychain/main/Documentation/example-app-screenshot.svg)

### Example App Features

The example app allows you to:

1. **Manage Authentication Tokens**
   - Save, load, and delete access tokens and refresh tokens
   - See immediate feedback on operation success or failure

2. **Handle API Keys**
   - Store API keys with custom identifiers
   - Retrieve and delete stored API keys

3. **Store Custom Values**
   - Create and manage custom key-value pairs
   - Optionally use custom service identifiers

### Running the Example App

To run the demo application:

1. Clone the repository
2. Open the package in Xcode
3. Select the `KeychainExample` scheme
4. Run the app on a simulator or device

The example app is designed to be intuitive and provides immediate feedback for all operations. It's a great way to explore the capabilities of MozzyKeychain before integrating it into your own projects.

## Advanced Usage

### Integration with Network Requests

MozzyKeychain works great with networking layers for managing authentication tokens:

```swift
import MozzyKeychain
import URLSession // or any networking library

class AuthenticatedAPIClient {
    let keychainKit = KeychainKitFactory.make()
    
    func authenticatedRequest(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(url: url)
        
        do {
            // Get the access token from keychain
            let token = try keychainKit.readToken(.accessToken)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle response
                if let data = data {
                    completion(.success(data))
                } else if let error = error {
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
```

### Using with SwiftUI

Example of using MozzyKeychain in a SwiftUI view:

```swift
import SwiftUI
import MozzyKeychain

struct TokenManagerView: View {
    @State private var accessToken = ""
    @State private var statusMessage = ""
    
    private let keychainKit = KeychainKitFactory.make()
    
    var body: some View {
        VStack {
            TextField("Access Token", text: $accessToken)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Save") {
                    saveToken()
                }
                
                Button("Load") {
                    loadToken()
                }
                
                Button("Delete") {
                    deleteToken()
                }
            }
            .padding()
            
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func saveToken() {
        do {
            try keychainKit.saveToken(.accessToken, value: accessToken)
            statusMessage = "Token saved successfully"
        } catch {
            statusMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    private func loadToken() {
        do {
            let token = try keychainKit.readToken(.accessToken)
            accessToken = token
            statusMessage = "Token loaded successfully"
        } catch {
            statusMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    private func deleteToken() {
        do {
            try keychainKit.deleteToken(.accessToken)
            accessToken = ""
            statusMessage = "Token deleted successfully"
        } catch {
            statusMessage = "Error: \(error.localizedDescription)"
        }
    }
}
```

## Types

### TokenType

```swift
public enum TokenType: CustomStringConvertible {
    case accessToken
    case refreshToken
}
```

### KeychainItemType

```swift
public enum KeychainItemType {
    case token(TokenType)
    case apiKey(String)
    case userCredential(String)
    case custom(String)
}
```

### KeychainError

```swift
public enum KeychainError: Error, Equatable {
    case noPassword
    case encodingError
    case unhandledError(message: String)
    case updateValueMissing
    case unexpectedPasswordData
}
```

## Requirements

- iOS 13.0+
- macOS 11.0+ (for Mac Catalyst)
- Swift 6+
- Xcode 13.0+

## Testing

MozzyKeychain includes a comprehensive test suite using Quick and Nimble. To run the tests:

1. Open the package in Xcode
2. Select the `MozzyKeychainTests` scheme
3. Press ⌘+U to run the tests

## Feedback and Contributions

I'd love to hear your feedback! If you have comments, suggestions, or find any issues, please feel free to:

- Open an issue on [GitHub](https://github.com/mozzy-swift/MozzyKeychain/issues)
- Send me an email at catmasterdeveloper@gmail.com
- Connect with me on [LinkedIn](https://www.linkedin.com/in/euntaek-lee-30a682360)

For direct code comments or PR reviews, you can also email me directly. I'm always interested in improving this library.

## License

MozzyKeychain is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Author

Created by [mozzy-swift](https://github.com/mozzy-swift)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgements

- Apple's [Security Framework](https://developer.apple.com/documentation/security)
- [Quick and Nimble](https://github.com/Quick/Quick) for testing
