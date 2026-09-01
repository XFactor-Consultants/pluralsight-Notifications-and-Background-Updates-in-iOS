import SwiftUI

struct RootView: View {
    @Environment(TasksStore.self) private var tasksStore
    @Environment(NotificationNavigationState.self) private var navigationState

    var body: some View {
        TabView {
            Tab("Tasks", systemImage: "checklist") {
                TaskListView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .sheet(item: Binding(
            get: { navigationState.pendingTaskID.flatMap { id in tasksStore.task(id: id) } },
            set: { _ in navigationState.pendingTaskID = nil }
        )) { task in
            NavigationStack {
                TaskDetailView(task: task)
            }
        }
    }
}

#Preview {
    RootView()
        .environment(TasksStore())
}
