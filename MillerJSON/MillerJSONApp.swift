//
//  MillerJSONApp.swift
//  MillerJSON
//
//  Created by Ladan Johari on 11/18/24.
//

import SwiftUI
import AppKit

@main
struct MillerJSONApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        guard !urls.isEmpty else {
            return
        }
        NotificationCenter.default.post(name: .didOpenFile, object: nil, userInfo: ["URLs": urls])
    }
}

extension Notification.Name {
    static let didOpenFile = Notification.Name("didOpenFile")
}
