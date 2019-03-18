import Foundation

/** Scenes that can be transitioned to with their according viewmodel type */
enum Scene {
    case tasks(TasksViewModel)
    case editTask(EditTaskViewModel)
}
