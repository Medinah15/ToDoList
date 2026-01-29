//
//  TodoListView.swift
//  ToDoList
//
//  Created by Medina Huseynova on 27.01.26.
//

import SwiftUI

struct TodoListView: View {
    
    @StateObject private var viewModel = TodoListViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Задачи")
                .font(.bold34)
                .foregroundStyle(Color("NavigationTitle"))
                .padding(.leading, 12)
                .padding(.top, 21)
            
            List {
                ForEach(viewModel.todos) { todo in
                    Text(todo.title ?? "")
                }
            }
            .listStyle(.plain)
            
        }
        .background(Color("Background"))
        
        .onAppear {
            viewModel.fetchTodos()
        }
    }
}
