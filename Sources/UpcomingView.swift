import SwiftUI

struct DayGroup: Identifiable {
    let day: Date
    let events: [Event]
    var id: Date { day }
}

struct UpcomingView: View {
    @EnvironmentObject var store: EventStore
    var onEdit: (Event) -> Void
    var onAdd: () -> Void

    private var groups: [DayGroup] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let upcoming = store.events
            .filter { cal.startOfDay(for: $0.start) >= today }
            .sorted { $0.start < $1.start }
        let byDay = Dictionary(grouping: upcoming) { cal.startOfDay(for: $0.start) }
        return byDay.keys.sorted().map { DayGroup(day: $0, events: byDay[$0] ?? []) }
    }

    var body: some View {
        ScrollView {
            if groups.isEmpty {
                VStack(spacing: 12) {
                    Text("Nothing on the calendar yet")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("Tap + to add your first dates. Tests, due dates, practices, anything.")
                        .foregroundColor(Theme.muted)
                        .multilineTextAlignment(.center)
                    Button(action: onAdd) {
                        Text("Add your first date")
                            .font(.headline)
                            .foregroundColor(Theme.ink)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Theme.ribbon)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(alignment: .leading, spacing: 18) {
                    ForEach(groups) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(group.day.dayTitle)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Text(group.day.dayDetail)
                                    .font(.footnote)
                                    .foregroundColor(Theme.muted)
                            }
                            ForEach(group.events) { event in
                                EventRow(event: event, onEdit: onEdit)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            Color.clear.frame(height: 110)
        }
    }
}

struct EventRow: View {
    @EnvironmentObject var store: EventStore
    let event: Event
    var onEdit: (Event) -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(event.allDay ? "All day" : event.start.formatted(date: .omitted, time: .shortened))
                .font(.footnote.weight(.semibold))
                .monospacedDigit()
                .foregroundColor(event.allDay ? Theme.muted : Theme.sky)
                .frame(width: 66, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.body.weight(.semibold))
                    .strikethrough(event.done)
                    .foregroundColor(event.done ? Theme.muted : Color.white)
                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.footnote)
                        .foregroundColor(Theme.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                store.toggleDone(event)
            } label: {
                ZStack {
                    Circle()
                        .stroke(Theme.line, lineWidth: 2)
                        .background(Circle().fill(event.done ? Theme.violet : Color.clear))
                    if event.done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(Theme.ink)
                    }
                }
                .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(event.done ? "Mark not done" : "Mark done")
        }
        .padding(12)
        .background(Theme.surface)
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Theme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { onEdit(event) }
    }
}
