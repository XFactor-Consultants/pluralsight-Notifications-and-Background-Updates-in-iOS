import SwiftUI

@Observable
final class TasksStore {
    private(set) var tasks: [TaskItem]
    let teammates: [Teammate]

    init() {
        let priya = Teammate(name: "Priya Raman")
        let marcus = Teammate(name: "Marcus Webb")
        let dana = Teammate(name: "Dana Ortiz")
        teammates = [priya, marcus, dana]

        let day: TimeInterval = 60 * 60 * 24
        tasks = [
            TaskItem(
                title: "Update emergency contact info",
                notes: "HR needs current emergency contacts on file before the offsite. Includes home address and phone numbers.",
                assignee: priya,
                dueDate: .now.addingTimeInterval(2 * day),
                priority: .high,
                isSensitive: true
            ),
            TaskItem(
                title: "Prepare sprint demo",
                notes: "Walk through the new filtering flow. Keep it under ten minutes.",
                assignee: marcus,
                dueDate: .now.addingTimeInterval(1 * day),
                priority: .high
            ),
            TaskItem(
                title: "Rotate shared server credentials",
                notes: "Quarterly rotation. Update the shared vault entry and notify the on-call channel.",
                assignee: dana,
                dueDate: .now.addingTimeInterval(5 * day),
                priority: .medium,
                isSensitive: true
            ),
            TaskItem(
                title: "Review Q3 roadmap draft",
                notes: "Leave comments directly in the doc before Thursday's planning meeting.",
                assignee: priya,
                dueDate: .now.addingTimeInterval(-1 * day),
                priority: .medium
            ),
            TaskItem(
                title: "Book venue for team offsite",
                notes: "Need space for twelve, projector, and decent coffee nearby.",
                assignee: dana,
                dueDate: .now.addingTimeInterval(9 * day),
                priority: .low
            ),
            TaskItem(
                title: "Fix onboarding flow copy",
                notes: "Second screen still says \"beta\" — swap in the approved wording.",
                assignee: marcus,
                dueDate: .now.addingTimeInterval(3 * day),
                priority: .low
            ),
            TaskItem(
                title: "Send weekly status update",
                notes: "Same format as last week. Include the demo recording link.",
                assignee: priya,
                dueDate: .now.addingTimeInterval(-2 * day),
                priority: .medium,
                isComplete: true
            )
        ]
    }

    func task(id: UUID) -> TaskItem? {
        tasks.first { $0.id == id }
    }

    func toggleComplete(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isComplete.toggle()
    }
}
