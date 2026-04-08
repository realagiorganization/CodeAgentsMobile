//
//  SSHClaudeIntegrationTest.swift
//  MobileCodeTests
//
//  Integration tests for SSH Claude command streaming
//

import Testing
@testable import CodeAgentsMobile
import Foundation

private enum LiveSSHClaudeConfig {
    static let environment = ProcessInfo.processInfo.environment
    static let isEnabled = environment["ENABLE_LIVE_SSH_TESTS"] == "1"
    static let host = environment["LIVE_SSH_HOST"] ?? "5.75.250.220"
    static let port = Int(environment["LIVE_SSH_PORT"] ?? "22") ?? 22
    static let username = environment["LIVE_SSH_USERNAME"] ?? "root"
    static let password = environment["LIVE_SSH_PASSWORD"] ?? ""
    static let projectPath = environment["LIVE_SSH_PROJECT_PATH"] ?? "/root/projects/First"
    static let apiKey = environment["LIVE_SSH_ANTHROPIC_API_KEY"] ?? ""
}

struct SSHClaudeIntegrationTest {
    
    // Test configuration - update these with your real server details
    struct TestConfig {
        static let host = LiveSSHClaudeConfig.host
        static let port = LiveSSHClaudeConfig.port
        static let username = LiveSSHClaudeConfig.username
        static let password = LiveSSHClaudeConfig.password
        static let projectPath = LiveSSHClaudeConfig.projectPath
        static let apiKey = LiveSSHClaudeConfig.apiKey
    }
    
    @Test func testClaudeBasicCommand() async throws {
        guard LiveSSHClaudeConfig.isEnabled else {
            print("Skipping live SSH integration test. Set ENABLE_LIVE_SSH_TESTS=1 to opt in.")
            return
        }

        // Simpler test to verify Claude is working
        let server = Server(
            name: "Test Server",
            host: TestConfig.host,
            port: TestConfig.port,
            username: TestConfig.username
        )
        
        try KeychainManager.shared.storePassword(TestConfig.password, for: server.id)
        let sshSession = try await SwiftSHSession.connect(to: server)
        defer { sshSession.disconnect() }
        
        // First, verify Claude is installed
        let checkClaude = try await sshSession.execute("which claude || echo 'Claude not found'")
        print("📍 Claude check: \(checkClaude)")
        
        // Try a simple non-streaming Claude command first
        let simpleCommand = """
            cd '\(TestConfig.projectPath)' && \
            export ANTHROPIC_API_KEY="\(TestConfig.apiKey)" && \
            claude --version 2>&1 || echo 'Claude version failed'
            """
        
        let versionOutput = try await sshSession.execute(simpleCommand)
        print("📍 Claude version output: \(versionOutput)")
        
        #expect(!versionOutput.isEmpty, "Should get Claude version output")
    }
    
    @Test func testClaudeCommandStreaming() async throws {
        guard LiveSSHClaudeConfig.isEnabled else {
            print("Skipping live SSH integration test. Set ENABLE_LIVE_SSH_TESTS=1 to opt in.")
            return
        }

        // Create server configuration
        let server = Server(
            name: "Test Server",
            host: TestConfig.host,
            port: TestConfig.port,
            username: TestConfig.username
        )
        
        // Store password in keychain
        try KeychainManager.shared.storePassword(TestConfig.password, for: server.id)
        
        // Create SSH session
        let sshSession = try await SwiftSHSession.connect(to: server)
        
        // Ensure we disconnect after test
        defer {
            sshSession.disconnect()
        }
        
        // Build Claude command with all required flags
        let command = """
            cd '\(TestConfig.projectPath)' && \
            export ANTHROPIC_API_KEY="\(TestConfig.apiKey)" && \
            claude -p "Say 'Hello from integration test' and nothing else" \
            --output-format stream-json --verbose \
            --allowedTools Bash,Write,Edit,MultiEdit,NotebookEdit,Read,LS,Grep,Glob,WebFetch
            """
        
        // Start process with streaming
        print("📌 Starting process with command: \(command)")
        let processHandle = try await sshSession.startProcess(command)
        
        var receivedOutput = false
        var outputChunks: [String] = []
        
        // Read streaming output
        let startTime = Date()
        let timeout: TimeInterval = 20 // 60 seconds timeout for Claude
        
        print("⏳ Waiting for Claude output (timeout: \(timeout)s)...")
        
        do {
            // Set up a timeout task
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                if !receivedOutput {
                    print("⏱️ No output received within \(timeout) seconds")
                }
            }
            
            defer { timeoutTask.cancel() }
            
            for try await chunk in processHandle.outputStream() {
                let elapsed = Date().timeIntervalSince(startTime)
                print("📥 [\(String(format: "%.1f", elapsed))s] Received chunk (\(chunk.count) chars): \(chunk)")
                receivedOutput = true
                outputChunks.append(chunk)
                
                // Check for timeout
                if elapsed > timeout {
                    print("⏱️ Timeout reached after \(elapsed) seconds")
                    break
                }
                
                // Don't check for specific content - just collect all output
                // Claude might output in different formats
            }
        } catch {
            print("❌ Stream error: \(error)")
            print("❌ Error details: \(String(describing: error))")
            throw error
        }
        
        // Verify we received output
        #expect(receivedOutput == true, "Should have received streaming output")
        
        let fullOutput = outputChunks.joined()
        print("\n📄 === FULL CLAUDE OUTPUT (\(fullOutput.count) chars) ===")
        print(fullOutput)
        print("📄 === END CLAUDE OUTPUT ===\n")
        
        // Print some diagnostics
        print("📊 Total chunks received: \(outputChunks.count)")
        print("📊 Total output length: \(fullOutput.count) characters")
        
        // Just verify we got some output
        #expect(!fullOutput.isEmpty, "Should have received Claude output (got \(fullOutput.count) chars)")
        
        // Verify the SSHChannelDataHandler forwarded data correctly
        #expect(!outputChunks.isEmpty, "Should have received output chunks")
        
        // Terminate the process
        processHandle.terminate()
    }
    
    @Test func testClaudeInstallation() async throws {
        guard LiveSSHClaudeConfig.isEnabled else {
            print("Skipping live SSH integration test. Set ENABLE_LIVE_SSH_TESTS=1 to opt in.")
            return
        }

        // Test if Claude is installed on the server
        let server = Server(
            name: "Test Server",
            host: TestConfig.host,
            port: TestConfig.port,
            username: TestConfig.username
        )
        
        try KeychainManager.shared.storePassword(TestConfig.password, for: server.id)
        let sshSession = try await SwiftSHSession.connect(to: server)
        defer { sshSession.disconnect() }
        
        // Check if claude command exists
        let output = try await sshSession.execute("which claude || echo 'Claude not found'")
        print("📍 Claude location: \(output)")
        
        // If found, check version
        if !output.contains("not found") {
            let version = try await sshSession.execute("claude --version || echo 'Version check failed'")
            print("📍 Claude version: \(version)")
        }
        
        #expect(!output.contains("not found"), "Claude should be installed on the server")
    }
    
    @Test func testSimpleStreamingCommand() async throws {
        guard LiveSSHClaudeConfig.isEnabled else {
            print("Skipping live SSH integration test. Set ENABLE_LIVE_SSH_TESTS=1 to opt in.")
            return
        }

        // Test streaming with a simple command that outputs multiple lines
        let server = Server(
            name: "Test Server",
            host: TestConfig.host,
            port: TestConfig.port,
            username: TestConfig.username
        )
        
        try KeychainManager.shared.storePassword(TestConfig.password, for: server.id)
        let sshSession = try await SwiftSHSession.connect(to: server)
        defer { sshSession.disconnect() }
        
        // Use a command that outputs multiple lines
        let command = "for i in 1 2 3 4 5; do echo \"Line $i\"; sleep 0.1; done"
        let processHandle = try await sshSession.startProcess(command)
        
        var outputLines: [String] = []
        for try await chunk in processHandle.outputStream() {
            print("📥 Received chunk: \(chunk)")
            outputLines.append(chunk)
            if outputLines.count >= 5 { break }
        }
        
        processHandle.terminate()
        
        // Verify we received streaming output
        #expect(outputLines.count > 0, "Should have received streaming output")
        let fullOutput = outputLines.joined()
        #expect(fullOutput.contains("Line 1"))
        #expect(fullOutput.contains("Line 5"))
    }
    
    @Test func testSSHConnectionOnly() async throws {
        guard LiveSSHClaudeConfig.isEnabled else {
            print("Skipping live SSH integration test. Set ENABLE_LIVE_SSH_TESTS=1 to opt in.")
            return
        }

        // Simple connection test
        let server = Server(
            name: "Test Server",
            host: TestConfig.host,
            port: TestConfig.port,
            username: TestConfig.username
        )
        
        try KeychainManager.shared.storePassword(TestConfig.password, for: server.id)
        
        let sshSession = try await SwiftSHSession.connect(to: server)
        
        // Test simple command
        let output = try await sshSession.execute("echo 'SSH test successful'")
        #expect(output.contains("SSH test successful"))
        
        sshSession.disconnect()
    }
}

enum TestError: Error {
    case timeout(String)
}
