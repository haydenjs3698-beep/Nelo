import SwiftUI

struct EventEditor: View {
    @EnvironmentObject var store: EventStore
    @Environment(\.dismiss) private var dismiss

    let event: Event?
    @State private var title: String
    @State private var start: Date
    @State private var allDay: Bool
    @State private var notes: String
    @State private var addToCalendar = false

    init(event: Event?, defaultDay: Date) {
        self.event = event
        let cal = Calendar.current
        let nineAM = cal.date(bySettingHour: 9, minute: 0, second: 0, of: defaultDay) ?? defaultDay
        _title = State(initialValue: event?.title ?? "")
        _start = State(initialValue: event?.start ?? nineAM)
        _allDay = State(initialValue: event?.allDay ?? false)
        _notes = State(initialValue: event?.notes ?? "")
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        let cal = Calendar.current
        var e = event ?? Event(title: "", start: start, allDay: allDay)
        e.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        e.allDay = allDay
        e.start = allDay ? cal.startOfDay(for: start) : start
        e.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        store.upsert(e)

        if addToCalendar && e.calendarEventID == nil {
            let saved = e
            CalendarSync.add(saved) { id in
                guard let id = id else { return }
                var updated = saved
                updated.calendarEventID = id
                store.upsert(updated)
            }
        }
        dismiss()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What is it?", text: $title)
                    Toggle("All day", isOn: $allDay)
                    DatePicker(
                        "When",
                        selection: $start,
                        displayedComponents: allDay ? [.date] : [.date, .hourAndMinute]
                    )
                    TextField("Notes (optional)", text: $notes)
                }
                .listRowBackground(Theme.surface)

                if event?.calendarEventID == nil {
                    Section(footer: Text("Adds a copy to the Calendar app on this iPhone.").foregroundColor(Theme.muted)) {
                        Toggle("Also add to iPhone Calendar", isOn: $addToCalendar)
                    }
                    .listRowBackground(Theme.surface)
                }

                if let event = event {
                    Section {
                        Button("Delete event", role: .destructive) {
                            store.delete(event)
                            dismiss()
                        }
                    }
                    .listRowBackground(Theme.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle(event == nil ? "New event" : "Edit event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
        .tint(Theme.violet)
        .preferredColorScheme(.dark)
    }
}
