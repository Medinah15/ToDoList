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
    
    func fetchTodos() {
        let request: NSFetchRequest<ToDoEntity> =
        ToDoEntity.fetchRequest()
        
        let result = (try? context.fetch(request)) ?? []
        todos = result
    }
}
