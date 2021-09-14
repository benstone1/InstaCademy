//
//  TaskViewModel.swift
//  TaskViewModel
//
//  Created by John Royal on 8/25/21.
//

import Foundation

@MainActor class TaskViewModel: ObservableObject {
    typealias Action = () async throws -> Void
    
    @Published var isInProgress = false
    @Published var isError = false
    @Published private(set) var error: Error?
    
    func perform(_ action: @escaping Action) {
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
    
    var confirmAction: (() -> Void)? {
        guard let action = pendingAction else {
            return nil
        }
        return {
            super.perform { [weak self] in
                try await action()
                self?.pendingAction = nil
            }
        }
    }
    private var pendingAction: Action?
    
    func request(_ action: @escaping Action) {
        pendingAction = action
        isPending = true
    }
    
    override func perform(_ action: @escaping Action) {
        fatalError("Cannot call perform(_:) directly on DeleteTaskViewModel")
    }
}
