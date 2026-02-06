//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Medina Huseynova on 27.01.26.
//

import XCTest
import CoreData
import Combine
@testable import ToDoList

final class ToDoListViewModelTests: XCTestCase {
    
    private var container: NSPersistentContainer!
    private var viewModel: TodoListViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        setupContainer()
        setupViewModel()
    }
    
    override func tearDown() {
        cancellables.removeAll()
        container = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Private Helpers
    private func setupContainer() {
        container = NSPersistentContainer(name: "ToDoList")
        let desc = NSPersistentStoreDescription()
        desc.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [desc]
        
        let exp = expectation(description: "loadPersistentStores")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load persistent stores")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private func setupViewModel() {
        let bgContext = container.newBackgroundContext()
        bgContext.automaticallyMergesChangesFromParent = true
        
        viewModel = TodoListViewModel(
            context: container.viewContext,
            backgroundContext: bgContext
        )
    }
    
    private func createTodo(title: String) {
        let todo = ToDoEntity(context: container.viewContext)
        todo.id = UUID()
        todo.title = title
        todo.isCompleted = false
        todo.createdAt = Date()
        try? container.viewContext.save()
    }
    
    func testFetchTodos_LoadsSavedTodos() {
        
        createTodo(title: "Купить продукты")
        createTodo(title: "Прогулка с собакой")
        
        let exp = expectation(description: "Todos loaded")
        viewModel.$todos
            .dropFirst()
            .prefix(1)
            .sink { todos in
                if todos.count == 2 {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchTodos()
        wait(for: [exp], timeout: 2.0)
        
        XCTAssertEqual(viewModel.todos.count, 2)
        XCTAssertTrue(viewModel.todos.contains { $0.title == "Купить продукты" })
    }
    
    func testSearch_FiltersTodosByTitle() {
        
        createTodo(title: "Apple")
        createTodo(title: "Banana")
        createTodo(title: "Apricot")
        
        let loadExp = expectation(description: "All todos loaded")
        viewModel.fetchTodos()
        viewModel.$todos
            .dropFirst()
            .prefix(1)
            .sink { todos in
                if todos.count == 3 {
                    loadExp.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [loadExp], timeout: 2.0)
        
        let searchExp = expectation(description: "Search filtered")
        viewModel.fetchTodos(searchText: "ap")
        viewModel.$todos
            .dropFirst()
            .prefix(1)
            .sink { todos in
                if todos.count == 2 {
                    searchExp.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [searchExp], timeout: 2.0)
        
        XCTAssertEqual(viewModel.todos.count, 2)
    }
    
    func testDelete_RemovesTodoFromList() {
        
        createTodo(title: "Удалить")
        createTodo(title: "Оставить")
        
        let loadExp = expectation(description: "Todos loaded")
        viewModel.fetchTodos()
        viewModel.$todos
            .dropFirst()
            .prefix(1)
            .sink { todos in
                if todos.count == 2 {
                    loadExp.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [loadExp], timeout: 2.0)
        
        guard let todoToDelete = viewModel.todos.first(where: { $0.title == "Удалить" }) else {
            XCTFail("Задача для удаления не найдена")
            return
        }
        
        let deleteExp = expectation(description: "Todo deleted")
        viewModel.delete(todo: todoToDelete)
        viewModel.$todos
            .dropFirst()
            .prefix(1)
            .sink { todos in
                if todos.count == 1 {
                    deleteExp.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [deleteExp], timeout: 2.0)
        
        XCTAssertEqual(viewModel.todos.count, 1)
        XCTAssertTrue(viewModel.todos.contains { $0.title == "Оставить" })
    }
    
    func testAddTodo_CreatesNewTodo() {
        let addExp = expectation(description: "Todo created")
        let listExp = expectation(description: "List updated")
        
        viewModel.addTodo { newTodo in
            XCTAssertNotNil(newTodo.objectID, "ObjectID должен существовать")
            XCTAssertNotNil(newTodo.id, "ID должен быть сгенерирован")
            XCTAssertNotNil(newTodo.createdAt, "Дата создания обязательна")
            addExp.fulfill()
        }
        
        viewModel.$todos
            .dropFirst()
            .prefix(1)
            .sink { todos in
                if todos.count == 1 {
                    listExp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [addExp, listExp], timeout: 2.0)
        XCTAssertEqual(viewModel.todos.count, 1)
    }
    
    func testFetchTodos_EmptyDatabaseReturnsEmptyArray() {
        let exp = expectation(description: "Empty todos")
        viewModel.$todos
            .dropFirst()
            .prefix(1)
            .sink { todos in
                if todos.isEmpty {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchTodos()
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(viewModel.todos.isEmpty)
    }
}
