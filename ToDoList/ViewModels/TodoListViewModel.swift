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
                self.saveTodos(dtos)
                self.fetchTodos()
                
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
        let request: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
        
        if !searchText.isEmpty {
            request.predicate = NSPredicate(
                format: "title CONTAINS[cd] %@",
                searchText
            )
        }
        
        do {
            let result = try context.fetch(request)
            DispatchQueue.main.async {
                self.todos = result
            }
        } catch {
            print("Fetch error:", error)
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
    
    func delete(todo: ToDoEntity) {
        DispatchQueue.global(qos: .background).async {
            self.context.delete(todo)
            
            do {
                try self.context.save()
                self.fetchTodos(searchText: self.searchText)
            } catch {
                print("Delete error:", error)
            }
        }
    }
}
