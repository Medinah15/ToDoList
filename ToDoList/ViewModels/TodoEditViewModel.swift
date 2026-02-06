//
//  TodoEditViewModel.swift
//  ToDoList
//
//  Created by Medina Huseynova on 05.02.26.
//
import Foundation
import CoreData
import Combine

final class TodoEditViewModel: ObservableObject {
    
    @Published var title: String
    @Published var details: String
    
    private let todoID: NSManagedObjectID
    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init (App)
    init(todo: ToDoEntity, context: NSManagedObjectContext) {
        self.todoID = todo.objectID
        self.viewContext = context
        self.backgroundContext = PersistenceController.shared.backgroundContext
        
        let initialTodo = try? context.existingObject(with: todoID) as? ToDoEntity
        self.title = initialTodo?.title ?? ""
        self.details = initialTodo?.details ?? ""
        
        setupAutosave()
    }
    
    // MARK: - Init (Tests)
    init(todo: ToDoEntity, viewContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.todoID = todo.objectID
        self.viewContext = viewContext
        self.backgroundContext = backgroundContext
        
        let initialTodo = try? viewContext.existingObject(with: todoID) as? ToDoEntity
        self.title = initialTodo?.title ?? ""
        self.details = initialTodo?.details ?? ""
        
        setupAutosave()
    }
    
    // MARK: - Autosave
    private func setupAutosave() {
        Publishers.CombineLatest($title, $details)
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.global(qos: .userInitiated)) 
            .receive(on: RunLoop.main)
            .sink { [weak self] title, details in
                self?.save(title: title, details: details)
            }
            .store(in: &cancellables)
    }
    
    private func save(title: String, details: String) {
        backgroundContext.perform {
            guard let todo = try? self.backgroundContext.existingObject(with: self.todoID) as? ToDoEntity
            else { return }
            
            todo.title = title
            todo.details = details.isEmpty ? nil : details
            
            do {
                try self.backgroundContext.save()
            } catch {
                print("Save edit error:", error)
            }
        }
    }
    
    // MARK: - Computed Properties
    var createdAtText: String {
        let todo = try? viewContext.existingObject(with: todoID) as? ToDoEntity
        return todo?.createdAt?.formattedForTodo() ?? ""
    }
}
