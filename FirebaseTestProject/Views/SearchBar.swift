//
//  SearchBar.swift
//  SearchBar
//
//  Created by Bradley French on 8/15/21.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    @FocusState private var searchIsFocused: Bool
    
    var body: some View {
        HStack {
            TextField("", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
                .focused($searchIsFocused)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                )
            
            if isEditing {
                Button(action: {
                    text = ""
                    hideKeyboard()
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default, value: 0)
            }
        }
    }
    
    func hideKeyboard() {
        searchIsFocused = false
        isEditing = false
    }
}

struct SearchBar_Previews: PreviewProvider {
    @State static var text: String = ""
    static var previews: some View {
        SearchBar(text: $text)
    }
}
