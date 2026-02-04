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
                    VStack(spacing: 0) {
                        
                        TodoRowView(todo: todo)
                        
                        Divider()
                            .padding(.leading, 20)
                            .background(Color("TextHint"))
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
                    )
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
            ZStack {
                Text("\(viewModel.todos.count) Задач")
                    .font(.regular11)
                    .foregroundStyle(Color("MainText"))
                
                HStack {
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.regular22)
                            .foregroundStyle(Color("Yellow"))
                    }
                    .padding(.trailing, 23)
                }
            }
            .frame(height: 56)
            .background(Color("Surface"))
        }
        .background(Color("Background"))
        .onAppear {
            viewModel.loadTodosIfNeeded()
        }
    }
}
