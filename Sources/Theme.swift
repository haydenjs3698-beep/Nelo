import SwiftUI

enum Theme {
    static let bg = Color(red: 0.027, green: 0.031, blue: 0.047)
    static let surface = Color(red: 0.063, green: 0.067, blue: 0.106)
    static let surface2 = Color(red: 0.090, green: 0.100, blue: 0.160)
    static let line = Color(red: 0.150, green: 0.165, blue: 0.260)
    static let muted = Color(red: 0.600, green: 0.627, blue: 0.753)
    static let violet = Color(red: 0.627, green: 0.455, blue: 1.000)
    static let blue = Color(red: 0.310, green: 0.490, blue: 1.000)
    static let sky = Color(red: 0.560, green: 0.780, blue: 1.000)
    static let ink = Color(red: 0.030, green: 0.031, blue: 0.090)

    static let ribbon = LinearGradient(
        colors: [
            Color(red: 0.647, green: 0.470, blue: 0.973),
            Color(red: 0.306, green: 0.424, blue: 0.965),
            Color(red: 0.560, green: 0.800, blue: 1.000)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Date {
    var dayTitle: String {
        let cal = Calendar.current
        if cal.isDateInToday(self) { return "Today" }
        if cal.isDateInTomorrow(self) { return "Tomorrow" }
        return self.formatted(.dateTime.weekday(.wide))
    }

    var dayDetail: String {
        self.formatted(.dateTime.month(.abbreviated).day())
    }
}
