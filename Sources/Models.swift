import Foundation

struct Event: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var start: Date
    var allDay: Bool
    var notes: String = ""
    var done: Bool = false
    var calendarEventID: String? = nil
}

final class EventStore: ObservableObject {
    @Published var events: [Event] = [] {
        didSet { save() }
    }

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = dir.appendingPathComponent("nelo-events.json")
        load()
    }

    func upsert(_ event: Event) {
        if let i = events.firstIndex(where: { $0.id == event.id }) {
            events[i] = event
        } else {
            events.append(event)
        }
    }

    func delete(_ event: Event) {
        events.removeAll { $0.id == event.id }
    }

    func toggleDone(_ event: Event) {
        if let i = events.firstIndex(where: { $0.id == event.id }) {
            events[i].done.toggle()
        }
    }

    func events(on day: Date) -> [Event] {
        let cal = Calendar.current
        return events
            .filter { cal.isDate($0.start, inSameDayAs: day) }
            .sorted { $0.start < $1.start }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([Event].self, from: data) {
            events = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted]
        if let data = try? encoder.encode(events) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
