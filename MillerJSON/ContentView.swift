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

    var body: some View {
        VStack {
            // MARK: - Miller Column View
            if let myItem = viewModel.myItem {
                LazyMillerView(
                    rootStream: singletonStream(myItem),
                    jumpTo: [],
                    ctx: Context()
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
    }
}

#Preview {
    ContentView()
}
