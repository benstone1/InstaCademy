//
//  FormViewModel.swift
//  FirebaseTestProject
//
//  Created by John Royal on 9/27/21.
//

import Foundation

// MARK: - FormViewModel

@MainActor
class FormViewModel<Content>: ObservableObject {
    typealias SubmitAction = (Content) async throws -> Void
    typealias InitialValueAction = () -> Content
    
    @Published var editable: Content
    @Published var error: Error?
    @Published var isLoading = false
    
    private let submitAction: SubmitAction
    private let initialValueAction: InitialValueAction
    
    init(submitAction: @escaping SubmitAction, initialValue: @autoclosure @escaping InitialValueAction) {
        self.editable = initialValue()
        self.submitAction = submitAction
        self.initialValueAction = initialValue
    }
    
    func submit() {
        Task {
            isLoading = true
            do {
                try await submitAction(editable)
                editable = initialValueAction()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}

// MARK: - PostFormViewModel

class PostFormViewModel: FormViewModel<Post.EditableFields> {
    convenience init(submitAction: @escaping SubmitAction) {
        self.init(submitAction: submitAction, initialValue: Post.EditableFields())
    }
}

// MARK: - CommentFormViewModel

class CommentFormViewModel: FormViewModel<Comment.EditableFields> {
    convenience init(submitAction: @escaping SubmitAction) {
        self.init(submitAction: submitAction, initialValue: Comment.EditableFields())
    }
}
