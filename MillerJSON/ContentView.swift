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
        updateMillerView(with: jsonInput)
        // Listen for file drop notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleFileOpen(_:)), name: .didOpenFile, object: nil)
        updateMillerView(with: jsonInput)
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

    // MARK: - Methods
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
            Text(recivedURLs.map{$0.absoluteString}
                .joined(separator: "\n"))
            // MARK: - Miller Column View
            if let myItem = viewModel.myItem {
                LazyMillerView(
                    rootStream: singletonStream(myItem),
                    jumpTo: [],
                    ctx: Context(),
                    showPrompt: false
                )
            } else if let errorMessage = viewModel.errorMessage {
                // Error View
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }

            Divider()

            // MARK: - JSON Input Text Editor
           /* TextEditor(text: $viewModel.jsonInput)
                .border(Color.gray, width: 1)
                .padding()
                .frame(height: 150)
                .onChange(of: viewModel.jsonInput) { newValue in
                    viewModel.updateMillerView(with: newValue)
                } */
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: .didOpenFile)) { notification in
            print("\(notification)")
            if let urls = notification.userInfo?["URLs"] as? [Foundation.URL] {
                recivedURLs = urls
                if let onlyURL = urls.first {
                    if let jsonContent = try? String(contentsOf: onlyURL, encoding: .utf8) {
                        viewModel.updateMillerView(with: jsonContent)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
