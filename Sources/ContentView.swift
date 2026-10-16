import SwiftUI

struct EditorTarget: Identifiable {
    let id = UUID()
    var event: Event?
}

struct ContentView: View {
    @EnvironmentObject var store: EventStore
    @State private var tab = 0
    @State private var selectedDay = Date()
    @State private var target: EditorTarget?

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView()
                if tab == 0 {
                    UpcomingView(
                        onEdit: { target = EditorTarget(event: $0) },
                        onAdd: { target = EditorTarget(event: nil) }
                    )
                } else {
                    MonthView(
                        selected: $selectedDay,
                        onEdit: { target = EditorTarget(event: $0) },
                        onAdd: { target = EditorTarget(event: nil) }
                    )
                }
            }

            BottomBar(tab: $tab, onAdd: { target = EditorTarget(event: nil) })
        }
        .sheet(item: $target) { t in
            EventEditor(event: t.event, defaultDay: tab == 0 ? Date() : selectedDay)
                .environmentObject(store)
        }
        .preferredColorScheme(.dark)
    }
}

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text("Nelo")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.footnote)
                    .foregroundColor(Theme.muted)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }
}

struct BottomBar: View {
    @Binding var tab: Int
    var onAdd: () -> Void

    var body: some View {
        HStack {
            tabButton(index: 0, label: "Upcoming", icon: "list.bullet")

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Theme.ink)
                    .frame(width: 62, height: 62)
                    .background(Theme.ribbon)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Theme.violet.opacity(0.45), radius: 14, y: 6)
            }
            .accessibilityLabel("Add event")

            tabButton(index: 1, label: "Month", icon: "calendar")
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            LinearGradient(
                colors: [Theme.bg.opacity(0), Theme.bg],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.4)
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(index: Int, label: String, icon: String) -> some View {
        Button {
            tab = index
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon).font(.system(size: 20))
                Text(label).font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(tab == index ? Color.white : Theme.muted)
        }
    }
}
