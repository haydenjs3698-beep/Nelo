import SwiftUI

@main
struct NeloApp: App {
    @StateObject private var store = EventStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
