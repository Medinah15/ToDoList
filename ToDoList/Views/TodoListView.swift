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
        NavigationStack {
            List {
                ForEach(viewModel.todos) { todo in
                    Text(todo.title ?? "")
                }
            }
            .navigationTitle("Задачи")
            .onAppear {
                viewModel.fetchTodos()
            }
        }
    }
}
