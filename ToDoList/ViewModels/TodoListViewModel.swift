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
    
    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init (App)
    init() {
        self.context = PersistenceController.shared.container.viewContext
        self.backgroundContext = PersistenceController.shared.backgroundContext
        setupSearch()
    }
    
    // MARK: - Init (Tests)
    init(
        context: NSManagedObjectContext,
        backgroundContext: NSManagedObjectContext
    ) {
        self.context = context
        self.backgroundContext = backgroundContext
        setupSearch()
    }
    
    // MARK: - Load
    func loadTodosIfNeeded() {
        backgroundContext.perform {
            let request: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
            let count = (try? self.backgroundContext.count(for: request)) ?? 0
            
            guard count == 0 else {
                DispatchQueue.main.async {
                    self.fetchTodos()
                }
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
    }
    
    // MARK: - Search
    private func setupSearch() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.fetchTodos(searchText: text)
            }
            .store(in: &cancellables)
    }
    
    func fetchTodos(searchText: String = "") {
        let viewContext = context
        
        backgroundContext.perform {
            let request: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
            
            request.sortDescriptors = [
                NSSortDescriptor(
                    keyPath: \ToDoEntity.createdAt,
                    ascending: false
                )
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
                print("Fetch error:", error)
            }
        }
    }
    
    // MARK: - Save from API
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
    
    // MARK: - Delete
    func delete(todo: ToDoEntity) {
        let objectID = todo.objectID
        
        backgroundContext.perform {
            guard let todoInContext =
                    try? self.backgroundContext.existingObject(with: objectID)
            else { return }
            
            self.backgroundContext.delete(todoInContext)
            try? self.backgroundContext.save()
            
            DispatchQueue.main.async {
                self.fetchTodos(searchText: self.searchText)
            }
        }
    }
    
    // MARK: - Add
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
                    guard let todoInViewContext =
                            try? self.context
                        .existingObject(with: objectID) as? ToDoEntity
                    else { return }
                    
                    self.fetchTodos(searchText: self.searchText)
                    completion(todoInViewContext)
                }
            } catch {
                print("Add todo error:", error)
            }
        }
    }
}
