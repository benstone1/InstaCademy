//
//  TaskViewModel.swift
//  TaskViewModel
//
//  Created by John Royal on 8/25/21.
//

import Foundation

@MainActor class TaskViewModel: ObservableObject {
    @Published var isError = false
    @Published var isInProgress = false
    private(set) var error: Error?
    
    typealias Action = () async throws -> Void
    
    func run(action: @escaping Action) {
        Task {
            isInProgress = true
            do {
                try await action()
            } catch {
                self.error = error
                isError = true
            }
            isInProgress = false
        }
    }
}

class DeleteTaskViewModel: TaskViewModel {
    @Published var isPending = false
    
    private(set) var confirmAction: (() -> Void)?
    
    func request(with deleteAction: @escaping Action) {
        confirmAction = { [weak self] in
            self?.run(action: deleteAction)
        }
        isPending = true
    }
}
