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
                .foregroundStyle(Color("MainText"))
                .padding(.leading, 10)
                .padding(.top, 21)
                .padding(.bottom, 1)
            
            TodoSearchBarView(text: $viewModel.searchText)
            
            List {
                ForEach(viewModel.todos) { todo in
                    TodoRowView(todo: todo)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color("Background"))
        
        .onAppear {
            viewModel.fetchTodos()
        }
    }
}
