//
//  TodoSearchBarView.swift
//  ToDoList
//
//  Created by Medina Huseynova on 30.01.26.
//

import SwiftUI

struct TodoSearchBarView: View {
    
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("TextHint"))
                .font(.regular17)
            
            TextField(
                "",
                text: $text,
                prompt: Text("Search")
            )
            .textFieldStyle(.plain)
            .foregroundStyle(Color("TextHint"))
            .font(.regular17)
            
            Spacer()
            
            Image(systemName: "mic.fill")
                .foregroundStyle(Color("TextHint"))
                .font(.regular17)
        }
        .padding(.horizontal, 6)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("Surface"))
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
    }
}
