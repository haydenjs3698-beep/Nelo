import SwiftUI

struct DayCell: View {
    let day: Date
    let month: Date
    let selected: Date
    let eventCount: Int
    var onTap: () -> Void

    var body: some View {
        let cal = Calendar.current
        let inMonth = cal.isDate(day, equalTo: month, toGranularity: .month)
        let isSelected = cal.isDate(day, inSameDayAs: selected)
        let isToday = cal.isDateInToday(day)
        let border: Color = isToday ? Theme.violet : (isSelected ? Theme.sky : Color.clear)

        Button(action: onTap) {
            VStack(spacing: 5) {
                Text("\(cal.component(.day, from: day))")
                    .font(.system(size: 16, weight: .semibold))
                    .monospacedDigit()
                HStack(spacing: 3) {
                    ForEach(0..<min(eventCount, 3), id: \.self) { _ in
                        Circle().fill(Theme.sky).frame(width: 6, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isSelected ? Theme.surface2 : Theme.surface)
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(inMonth ? 1 : 0.35)
        }
        .buttonStyle(.plain)
    }
}

struct MonthView: View {
    @EnvironmentObject var store: EventStore
    @Binding var selected: Date
    var onEdit: (Event) -> Void
    var onAdd: () -> Void

    @State private var month: Date = {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
    }()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    private var weekdays: [String] {
        let cal = Calendar.current
        let symbols = cal.shortWeekdaySymbols
        let first = cal.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    private var days: [Date] {
        let cal = Calendar.current
        guard let interval = cal.dateInterval(of: .month, for: month) else { return [] }
        let firstWeekday = cal.component(.weekday, from: interval.start)
        let lead = (firstWeekday - cal.firstWeekday + 7) % 7
        let count = cal.range(of: .day, in: .month, for: month)?.count ?? 30
        guard let start = cal.date(byAdding: .day, value: -lead, to: interval.start) else { return [] }
        let total = Int(ceil(Double(lead + count) / 7.0)) * 7
        return (0..<total).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private func shiftMonth(_ delta: Int) {
        if let next = Calendar.current.date(byAdding: .month, value: delta, to: month) {
            month = next
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    Button { shiftMonth(-1) } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 40, height: 40)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .accessibilityLabel("Previous month")
                    Spacer()
                    Text(month.formatted(.dateTime.month(.wide).year()))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Spacer()
                    Button { shiftMonth(1) } label: {
                        Image(systemName: "chevron.right")
                            .frame(width: 40, height: 40)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .accessibilityLabel("Next month")
                }

                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(Array(weekdays.enumerated()), id: \.offset) { item in
                        Text(item.element)
                            .font(.caption)
                            .foregroundColor(Theme.muted)
                    }
                    ForEach(days, id: \.self) { day in
                        DayCell(
                            day: day,
                            month: month,
                            selected: selected,
                            eventCount: store.events(on: day).count,
                            onTap: { selected = day }
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(selected.dayTitle)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text(selected.dayDetail)
                            .font(.footnote)
                            .foregroundColor(Theme.muted)
                        Spacer()
                    }
                    let todays = store.events(on: selected)
                    if todays.isEmpty {
                        Button(action: onAdd) {
                            Text("Nothing planned. Add something")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(Theme.sky)
                        }
                    } else {
                        ForEach(todays) { event in
                            EventRow(event: event, onEdit: onEdit)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            Color.clear.frame(height: 110)
        }
    }
}
