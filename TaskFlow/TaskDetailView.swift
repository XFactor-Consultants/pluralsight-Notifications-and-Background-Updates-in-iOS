import SwiftUI

struct TaskDetailView: View {
    @Environment(TasksStore.self) private var tasksStore
    let task: TaskItem

    var body: some View {
        Form {
            Section {
                HStack {
                    Text(task.title)
                        .font(.headline)
                    if task.isSensitive {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Details") {
                if let assignee = task.assignee {
                    LabeledContent("Assigned to", value: assignee.name)
                }
                if let dueDate = task.dueDate {
                    LabeledContent("Due") {
                        Text(dueDate.formatted(date: .long, time: .omitted))
                            .foregroundStyle(task.isOverdue ? .red : .secondary)
                    }
                }
                LabeledContent("Priority") {
                    Label(task.priority.label, systemImage: task.priority.systemImage)
                }
                if task.isSensitive {
                    LabeledContent("Sensitive", value: "Yes")
                }
            }

            Section {
                Button(task.isComplete ? "Mark as Not Complete" : "Mark as Complete") {
                    tasksStore.toggleComplete(task)
                }
            }
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ShareLink(item: task.shareSummary) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: TasksStore().tasks[0])
    }
    .environment(TasksStore())
}
