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
    
    private let todo: ToDoEntity
    private let context: NSManagedObjectContext
    
    private var cancellables = Set<AnyCancellable>()
    
    init(todo: ToDoEntity, context: NSManagedObjectContext) {
        self.todo = todo
        self.context = context
        
        self.title = todo.title ?? ""
        self.details = todo.details ?? ""
        
        setupAutosave()
    }
    
    private func setupAutosave() {
        Publishers
            .CombineLatest($title, $details)
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] title, details in
                self?.save(title: title, details: details)
            }
            .store(in: &cancellables)
    }
    
    private func save(title: String, details: String) {
        todo.title = title
        todo.details = details
        
        do {
            try context.save()
        } catch {
            print("Save edit error:", error)
        }
    }
    
    var createdAtText: String? {
        guard let date = todo.createdAt else { return nil }
        return date.formattedForTodo()
    }
}
