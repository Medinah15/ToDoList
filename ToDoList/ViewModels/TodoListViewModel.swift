//
//  TodoListViewModel.swift
//  ToDoList
//
//  Created by Medina Huseynova on 27.01.26.
//

import Foundation
import CoreData
import Combine

final class TodoListViewModel: ObservableObject {
    
    @Published var todos: [ToDoEntity] = []
    @Published var searchText: String = ""
    
    private let context =
    PersistenceController.shared.container.viewContext
    
    private let backgroundContext =
    PersistenceController.shared.backgroundContext
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearch()
    }
    
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
                self.backgroundContext.perform {
                    self.saveTodos(dtos, in: self.backgroundContext)
                    
                    DispatchQueue.main.async {
                        self.fetchTodos()
                    }
                }
                
            case .failure(let error):
                print("Network error:", error)
            }
        }
        
    }
    
    private func setupSearch() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.fetchTodos(searchText: text)
            }
            .store(in: &cancellables)
    }
    
    private func fetchTodos(searchText: String = "") {
        let viewContext = context
        
        backgroundContext.perform {
            let request: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
            
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ToDoEntity.createdAt, ascending: false)
            ]
            
            if !searchText.isEmpty {
                request.predicate = NSPredicate(
                    format: "title CONTAINS[cd] %@",
                    searchText
                )
            }
            
            do {
                let result = try self.backgroundContext.fetch(request)
                let objectIDs = result.map { $0.objectID }
                
                DispatchQueue.main.async {
                    self.todos = objectIDs.compactMap {
                        try? viewContext.existingObject(with: $0) as? ToDoEntity
                    }
                }
            } catch {
                print("Background fetch error:", error)
            }
        }
    }
    
    private func saveTodos(
        _ dtos: [TodoDTO],
        in context: NSManagedObjectContext
    ) {
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
    
    func delete(todo: ToDoEntity) {
        let objectID = todo.objectID
        
        backgroundContext.perform {
            if let todoInContext =
                try? self.backgroundContext.existingObject(with: objectID) {
                
                self.backgroundContext.delete(todoInContext)
                try? self.backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.fetchTodos(searchText: self.searchText)
                }
            }
        }
    }
    
    func addTodo(completion: @escaping (ToDoEntity) -> Void) {
        backgroundContext.perform {
            let todo = ToDoEntity(context: self.backgroundContext)
            todo.id = UUID()
            todo.title = ""
            todo.details = ""
            todo.isCompleted = false
            todo.createdAt = Date()
            
            do {
                try self.backgroundContext.save()
                let objectID = todo.objectID
                
                DispatchQueue.main.async {
                    let viewContext = self.context
                    if let todoInViewContext =
                        try? viewContext.existingObject(with: objectID) as? ToDoEntity {
                        
                        self.fetchTodos(searchText: self.searchText)
                        completion(todoInViewContext)
                    }
                }
            } catch {
                print("Add todo error:", error)
            }
        }
    }
}
