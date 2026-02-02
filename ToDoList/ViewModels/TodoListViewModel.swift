//
//  TodoListViewModel.swift
//  ToDoList
//
//  Created by Medina Huseynova on 27.01.26.
//

import Foundation
import CoreData

final class TodoListViewModel: ObservableObject {
    
    @Published var todos: [ToDoEntity] = []
    @Published var searchText: String = ""
    
    private let context =
    PersistenceController.shared.container.viewContext
    
    func loadTodosIfNeeded() {
        let request: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
        let count = (try? context.count(for: request)) ?? 0
        
        guard count == 0 else {
            fetchTodos()
            return
        }
        
        NetworkService.shared.fetchTodos { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let dtos):
                self.saveTodos(dtos)
                self.fetchTodos()
                
            case .failure(let error):
                print("Network error:", error)
            }
        }
    }
    
    private func saveTodos(_ dtos: [TodoDTO]) {
        dtos.forEach { dto in
            let todo = ToDoEntity(context: context)
            todo.id = UUID()
            todo.title = dto.todo
            todo.details = nil
            todo.isCompleted = dto.completed
            todo.createdAt = Date()
        }
        
        try? context.save()
    }
    
    private func fetchTodos() {
        let request: NSFetchRequest<ToDoEntity> =
        ToDoEntity.fetchRequest()
        
        let result = (try? context.fetch(request)) ?? []
        
        DispatchQueue.main.async {
            self.todos = result
        }
    }
}
