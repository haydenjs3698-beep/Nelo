import EventKit
import Foundation

/// Adds a Nelo event to the iPhone's own Calendar app.
enum CalendarSync {
    private static let store = EKEventStore()

    static func add(_ event: Event, completion: @escaping (String?) -> Void) {
        let handler: EKEventStoreRequestAccessCompletionHandler = { granted, _ in
            DispatchQueue.main.async {
                guard granted, let calendar = store.defaultCalendarForNewEvents else {
                    completion(nil)
                    return
                }
                let ek = EKEvent(eventStore: store)
                ek.title = event.title
                ek.notes = event.notes
                ek.calendar = calendar
                ek.startDate = event.start
                if event.allDay {
                    ek.isAllDay = true
                    ek.endDate = event.start
                } else {
                    ek.endDate = event.start.addingTimeInterval(3600)
                }
                do {
                    try store.save(ek, span: .thisEvent)
                    completion(ek.eventIdentifier)
                } catch {
                    completion(nil)
                }
            }
        }

        if #available(iOS 17.0, *) {
            store.requestWriteOnlyAccessToEvents(completion: handler)
        } else {
            store.requestAccess(to: .event, completion: handler)
        }
    }
}
