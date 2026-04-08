//
//  DirectSSHTest.swift
//  MobileCodeTests
//
//  Direct test to verify SSH streaming works
//

import Testing
@testable import CodeAgentsMobile
import Foundation

private enum LiveSSHTestConfig {
    static let environment = ProcessInfo.processInfo.environment
    static let isEnabled = environment["ENABLE_LIVE_SSH_TESTS"] == "1"
    static let host = environment["LIVE_SSH_HOST"] ?? "5.75.250.220"
    static let port = Int(environment["LIVE_SSH_PORT"] ?? "22") ?? 22
    static let username = environment["LIVE_SSH_USERNAME"] ?? "root"
    static let password = environment["LIVE_SSH_PASSWORD"] ?? ""
    static let projectPath = environment["LIVE_SSH_PROJECT_PATH"] ?? "/root/projects/First"
    static let apiKey = environment["LIVE_SSH_ANTHROPIC_API_KEY"] ?? ""
}

struct DirectSSHTest {
    
    @Test func testDirectSSHStreaming() async throws {
        guard LiveSSHTestConfig.isEnabled else {
            print("Skipping live SSH test. Set ENABLE_LIVE_SSH_TESTS=1 to opt in.")
            return
        }

        print("🚀 Starting Direct SSH Streaming Test")
        
        // Server configuration
        let server = Server(
            name: "Test Server",
            host: LiveSSHTestConfig.host,
            port: LiveSSHTestConfig.port,
            username: LiveSSHTestConfig.username
        )
        
        // Store password
        try KeychainManager.shared.storePassword(LiveSSHTestConfig.password, for: server.id)
        
        // Connect
        print("📡 Connecting to server...")
        let sshSession = try await SwiftSHSession.connect(to: server)
        defer { 
            print("🔌 Disconnecting...")
            sshSession.disconnect() 
        }
        
        print("✅ Connected successfully!")
        
        // Test 1: Simple execute
        print("\n📌 Test 1: Simple execute command")
        let echoResult = try await sshSession.execute("echo 'Hello from SSH'")
        print("Result: \(echoResult)")
        #expect(echoResult.contains("Hello from SSH"))
        
        // Test 2: Streaming command
        print("\n📌 Test 2: Streaming command")
        let streamCommand = "for i in 1 2 3; do echo \"Stream $i\"; sleep 0.1; done"
        let processHandle = try await sshSession.startProcess(streamCommand)
        
        var chunks: [String] = []
        print("⏳ Waiting for stream output...")
        
        for try await chunk in processHandle.outputStream() {
            print("📥 Received: '\(chunk)'")
            chunks.append(chunk)
            if chunks.count >= 3 { break }
        }
        
        processHandle.terminate()
        
        let fullOutput = chunks.joined()
        print("📄 Full output: '\(fullOutput)'")
        #expect(!chunks.isEmpty, "Should receive streaming chunks")
        #expect(fullOutput.contains("Stream 1"))
        
        // Test 3: Claude command
        print("\n📌 Test 3: Claude command")
        let claudeCommand = """
            cd '\(LiveSSHTestConfig.projectPath)' && \
            export ANTHROPIC_API_KEY="\(LiveSSHTestConfig.apiKey)" && \
            timeout 20 claude --print "Say hello" \
            --output-format stream-json --verbose \
            --allowedTools Bash,Write,Edit,MultiEdit,NotebookEdit,Read,LS,Grep,Glob,WebFetch 2>&1
            """
        
        print("🤖 Starting Claude process...")
        let claudeHandle = try await sshSession.startProcess(claudeCommand)
        
        var claudeChunks: [String] = []
        let timeout = Task {
            try await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
            print("⏱️ Timeout reached")
        }
        
        print("⏳ Waiting for Claude output...")
        for try await chunk in claudeHandle.outputStream() {
            print("🤖 Claude says: '\(chunk)'")
            claudeChunks.append(chunk)
            if chunk.contains("hello") || chunk.contains("Hello") {
                print("✅ Found hello in output!")
                break
            }
        }
        
        timeout.cancel()
        claudeHandle.terminate()
        
        let claudeOutput = claudeChunks.joined()
        print("📄 Claude full output: '\(claudeOutput)'")
        print("📊 Received \(claudeChunks.count) chunks, total \(claudeOutput.count) characters")
        
        #expect(!claudeChunks.isEmpty, "Should receive Claude output")
        
        print("\n✅ All tests completed!")
    }
}
