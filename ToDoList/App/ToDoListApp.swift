//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Medina Huseynova on 27.01.26.
//

import SwiftUI

@main
struct ToDoListApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TodoListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
