//
//  ContentView.swift
//  MillerJSON
//
//  Created by Ladan Johari on 11/18/24.
//

import SwiftUI
import MillerKit
import TSCUtility

class ContentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var jsonInput: String = """
    {
      "Life": {
        "Eukaryotes": {
          "Animals": {
            "Mammals": ["Humans", "Elephants", "Whales"],
            "Birds": ["Eagles", "Parrots"],
            "Reptiles": ["Snakes", "Lizards"]
          },
          "Plants": {
            "Angiosperms": ["Roses", "Tulips"],
            "Gymnosperms": ["Pine trees", "Sequoias"]
          }
        },
        "Prokaryotes": {
          "Bacteria": ["Cyanobacteria", "E. coli"],
          "Archaea": ["Methanogens", "Halophiles"]
        }
      }
    }
    """
    @Published var myItem: LazyItem? = nil
    @Published var errorMessage: String? = nil

    // MARK: - Initialization
    init() {
        // Listen for file drop notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleFileOpen(_:)), name: .didOpenFile, object: nil)
    }
    
   
    
    @objc private func handleFileOpen(_ notification: Notification) {
        print("\(notification)")
        if let fileContents = notification.object as? String {
            DispatchQueue.main.async {
                self.jsonInput = fileContents
                self.updateMillerView(with: fileContents)
            }
        }
    }

    func updateMillerView(with json: String) {
        do {
            errorMessage = nil
            myItem = try LazyItem.fromJSON(from: json)
        } catch {
            errorMessage = "Invalid JSON format"
            myItem = nil
        }
    }
}



struct ContentView: View {

    // MARK: - ViewModel
    @StateObject private var viewModel = ContentViewModel()
    @State private var recivedURLs: [Foundation.URL] = []

    var body: some View {
        VStack {
            //JSON Link
            Text(recivedURLs.map{$0.absoluteString}
                .joined(separator: "\n"))
            .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
            .background(Color.white)
            .cornerRadius(8)
            // Display dropped URLs or errors
            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
            // MARK: - Miller Column View
            if let myItem = viewModel.myItem {
                LazyMillerView(
                    rootStream: singletonStream(myItem),
                    jumpTo: [],
                    ctx: Context(),
                    showPrompt: true
                )
            } else if let errorMessage = viewModel.errorMessage {
                // Error View
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
                    .cornerRadius(8)
            }
            Divider()

            // JSON Input View
            TextEditor(text: $viewModel.jsonInput)
                .frame(maxWidth: .infinity, maxHeight: 200)
                .cornerRadius(8)
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: .didOpenFile)) { notification in
            print("\(notification)")
            if let urls = notification.userInfo?["URLs"] as? [Foundation.URL] {
                recivedURLs = urls
                if let onlyURL = urls.first {
                    if let jsonContent = try? String(contentsOf: onlyURL, encoding: .utf8) {
                        viewModel.updateMillerView(with: jsonContent)
                    } else {
                        print("Cannot read file")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
