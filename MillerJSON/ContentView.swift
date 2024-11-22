//
//  ContentView.swift
//  MillerJSON
//
//  Created by Ladan Johari on 11/18/24.
//

import SwiftUI
import MillerKit

struct ContentView: View {
    // MARK: - State Variables
    @State private var jsonInput: String = """
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
    @State private var myItem: Item? = nil
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            // MARK: - Miller Column View
            if let myItem {
                MillerView(minedSymbols: .constant([myItem]))
            } else if let errorMessage {
                // Error View
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }

            Divider()

            // MARK: - JSON Input Text Editor
            TextEditor(text: $jsonInput)
                .border(Color.gray, width: 1)
                .padding()
                .frame(height: 150)
                .onChange(of: jsonInput) { newValue in
                    updateMillerView(with: newValue)
                }
        }
        .padding()
        .onAppear {
            // Initialize the Miller view with default JSON
            updateMillerView(with: jsonInput)
        }
    }

    // MARK: - Helper Method
    private func updateMillerView(with json: String) {
        do {
            errorMessage = nil
            myItem = try Item.fromJSON(from: json)
        } catch {
            errorMessage = "Invalid JSON format"
            myItem = nil
        }
    }
}

#Preview {
    ContentView()
}
