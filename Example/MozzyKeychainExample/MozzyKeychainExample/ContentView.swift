//
//  ContentView.swift
//  MozzyKeychainExample
//
//  Created by Eun Taek Lee on 5/8/25.
//

import SwiftUI
import MozzyKeychain

struct ContentView: View {
    // Create KeychainKit instance
    private let keychainKit = KeychainKitFactory.make()
    
    // State variables
    @State private var accessToken: String = ""
    @State private var refreshToken: String = ""
    @State private var apiKeyName: String = "google-maps"
    @State private var apiKeyValue: String = ""
    @State private var customKey: String = "custom-setting"
    @State private var customValue: String = ""
    @State private var statusMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var activeTab: Tab = .tokens
    
    enum Tab {
        case tokens, apiKeys, custom
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab selection picker
                Picker("Category", selection: $activeTab) {
                    Text("Tokens").tag(Tab.tokens)
                    Text("API Keys").tag(Tab.apiKeys)
                    Text("Custom").tag(Tab.custom)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Display different view based on selected tab
                        switch activeTab {
                        case .tokens:
                            tokensView
                        case .apiKeys:
                            apiKeysView
                        case .custom:
                            customView
                        }
                        
                        // Display status message
                        if !statusMessage.isEmpty {
                            statusMessageView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("KeychainKit Demo")
            .overlay(loadingOverlay)
        }
    }
    
    // Token management view
    private var tokensView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Access & Refresh Token Management")
                .font(.headline)
            
            // Access token
            VStack(alignment: .leading) {
                Text("Access Token").font(.subheadline).foregroundColor(.secondary)
                TextField("Enter access token", text: $accessToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Button("Save") {
                        saveToken(.accessToken, value: accessToken)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Load") {
                        loadToken(.accessToken)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Delete") {
                        deleteToken(.accessToken)
                    }
                    .buttonStyle(DestructiveButtonStyle())
                }
            }
            .padding(.bottom, 8)
            
            // Refresh token
            VStack(alignment: .leading) {
                Text("Refresh Token").font(.subheadline).foregroundColor(.secondary)
                TextField("Enter refresh token", text: $refreshToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Button("Save") {
                        saveToken(.refreshToken, value: refreshToken)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Load") {
                        loadToken(.refreshToken)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Delete") {
                        deleteToken(.refreshToken)
                    }
                    .buttonStyle(DestructiveButtonStyle())
                }
            }
        }
    }
    
    // API key management view
    private var apiKeysView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("API Key Management")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text("API Key Name").font(.subheadline).foregroundColor(.secondary)
                TextField("Enter API key name", text: $apiKeyName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("API Key Value").font(.subheadline).foregroundColor(.secondary)
                TextField("Enter API key value", text: $apiKeyValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Button("Save") {
                        saveApiKey(name: apiKeyName, value: apiKeyValue)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Load") {
                        loadApiKey(name: apiKeyName)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Delete") {
                        deleteApiKey(name: apiKeyName)
                    }
                    .buttonStyle(DestructiveButtonStyle())
                }
            }
        }
    }
    
    // Custom item management view
    private var customView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Custom Item Management")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text("Key").font(.subheadline).foregroundColor(.secondary)
                TextField("Enter key", text: $customKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Value").font(.subheadline).foregroundColor(.secondary)
                TextField("Enter value", text: $customValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Button("Save") {
                        saveCustomItem(key: customKey, value: customValue)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Load") {
                        loadCustomItem(key: customKey)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Delete") {
                        deleteCustomItem(key: customKey)
                    }
                    .buttonStyle(DestructiveButtonStyle())
                }
            }
        }
    }
    
    // Status message view
    private var statusMessageView: some View {
        HStack {
            if statusMessage.contains("failed") || statusMessage.contains("error") {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            Text(statusMessage)
                .font(.footnote)
            
            Spacer()
            
            Button {
                statusMessage = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(statusMessage.contains("failed") || statusMessage.contains("error")
                     ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(statusMessage.contains("failed") || statusMessage.contains("error")
                       ? Color.red.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 1)
        )
        .animation(.easeInOut, value: statusMessage)
    }
    
    // Loading overlay
    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 10)
                    )
            }
        }
    }
    
    // MARK: - KeychainKit Operations
    
    // Save token
    private func saveToken(_ type: TokenType, value: String) {
        guard !value.isEmpty else {
            statusMessage = "Token value cannot be empty"
            return
        }
        
        executeKeychainOperation {
            try keychainKit.saveToken(type, value: value)
            statusMessage = "\(type == .accessToken ? "Access" : "Refresh") token saved successfully"
        }
    }
    
    // Load token
    private func loadToken(_ type: TokenType) {
        executeKeychainOperation {
            let token = try keychainKit.readToken(type)
            if type == .accessToken {
                accessToken = token
            } else {
                refreshToken = token
            }
            statusMessage = "\(type == .accessToken ? "Access" : "Refresh") token loaded successfully"
        }
    }
    
    // Delete token
    private func deleteToken(_ type: TokenType) {
        executeKeychainOperation {
            try keychainKit.deleteToken(type)
            if type == .accessToken {
                accessToken = ""
            } else {
                refreshToken = ""
            }
            statusMessage = "\(type == .accessToken ? "Access" : "Refresh") token deleted successfully"
        }
    }
    
    // Save API key
    private func saveApiKey(name: String, value: String) {
        guard !name.isEmpty else {
            statusMessage = "API key name cannot be empty"
            return
        }
        
        guard !value.isEmpty else {
            statusMessage = "API key value cannot be empty"
            return
        }
        
        executeKeychainOperation {
            try keychainKit.save(itemType: .apiKey(name), value: value)
            statusMessage = "API key saved successfully"
        }
    }
    
    // Load API key
    private func loadApiKey(name: String) {
        guard !name.isEmpty else {
            statusMessage = "API key name cannot be empty"
            return
        }
        
        executeKeychainOperation {
            let value = try keychainKit.read(itemType: .apiKey(name))
            apiKeyValue = value
            statusMessage = "API key loaded successfully"
        }
    }
    
    // Delete API key
    private func deleteApiKey(name: String) {
        guard !name.isEmpty else {
            statusMessage = "API key name cannot be empty"
            return
        }
        
        executeKeychainOperation {
            try keychainKit.delete(itemType: .apiKey(name))
            apiKeyValue = ""
            statusMessage = "API key deleted successfully"
        }
    }
    
    // Save custom item
    private func saveCustomItem(key: String, value: String) {
        guard !key.isEmpty else {
            statusMessage = "Key cannot be empty"
            return
        }
        
        guard !value.isEmpty else {
            statusMessage = "Value cannot be empty"
            return
        }
        
        executeKeychainOperation {
            try keychainKit.save(itemType: .custom(key), value: value)
            statusMessage = "Custom item saved successfully"
        }
    }
    
    // Load custom item
    private func loadCustomItem(key: String) {
        guard !key.isEmpty else {
            statusMessage = "Key cannot be empty"
            return
        }
        
        executeKeychainOperation {
            let value = try keychainKit.read(itemType: .custom(key))
            customValue = value
            statusMessage = "Custom item loaded successfully"
        }
    }
    
    // Delete custom item
    private func deleteCustomItem(key: String) {
        guard !key.isEmpty else {
            statusMessage = "Key cannot be empty"
            return
        }
        
        executeKeychainOperation {
            try keychainKit.delete(itemType: .custom(key))
            customValue = ""
            statusMessage = "Custom item deleted successfully"
        }
    }
    
    // Helper method to execute keychain operations
    private func executeKeychainOperation(_ operation: @escaping () throws -> Void) {
        // Set loading state
        isLoading = true
        
        // Create and start an asynchronous task
        Task {
            do {
                // Execute the operation on a background thread
                try await Task.detached(priority: .userInitiated) {
                    try operation()
                }.value
                
                // Update UI on the main thread using MainActor
                await MainActor.run {
                    isLoading = false
                }
            } catch KeychainError.noPassword {
                // Handle "item not found" error on the main thread
                await MainActor.run {
                    statusMessage = "Item not found"
                    isLoading = false
                }
            } catch {
                // Handle all other errors on the main thread
                await MainActor.run {
                    statusMessage = "Operation failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.1))
            .foregroundColor(.red)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
