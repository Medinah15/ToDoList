//
//  TodoEditView.swift
//  ToDoList
//
//  Created by Medina Huseynova on 05.02.26.
//

import SwiftUI

struct TodoEditView: View {
    
    @ObservedObject var viewModel: TodoEditViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 10) {
                        Image("chevron")
                        Text("Назад")
                            .font(.regular17)
                    }
                    .foregroundStyle(Color("Yellow"))
                }
                .padding(.leading, 2)
                
                Spacer()
            }
            .frame(height: 44)
            .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                
                TextField("Название", text: $viewModel.title, axis: .vertical)
                    .font(.bold34)
                    .foregroundStyle(Color("MainText"))
                
                Text(viewModel.createdAtText) 
                    .font(.regular12)
                    .foregroundStyle(Color("TextHint"))
                
                TextEditor(text: $viewModel.details)
                    .font(.regular16)
                    .foregroundStyle(Color("MainText"))
                    .frame(minHeight: 120)
                    .padding(.leading, -4)
                
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
        }
        .background(Color("Background"))
        .navigationBarHidden(true)
    }
}
