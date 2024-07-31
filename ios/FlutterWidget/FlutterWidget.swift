import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FlutterEntry {
        FlutterEntry(date: Date(), widgetData: WidgetData(days: [], names: []), index: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (FlutterEntry) -> ()) {
        let entry = FlutterEntry(date: Date(), widgetData: WidgetData(days: [], names: []), index: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FlutterEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.beSober2")
        var flutterData: WidgetData?

        if let widgetDataString = sharedDefaults?.string(forKey: "FlutterWidget"),
           let data = widgetDataString.data(using: .utf8) {
            flutterData = try? JSONDecoder().decode(WidgetData.self, from: data)
        }

        var entries: [FlutterEntry] = []
        let currentDate = Date()
        var entryDate = currentDate

        let count = max(flutterData?.days.count ?? 0, flutterData?.names.count ?? 0)

        for index in 0..<count {
            let entry = FlutterEntry(date: entryDate, widgetData: flutterData, index: index)
            entries.append(entry)
            entryDate = Calendar.current.date(byAdding: .second, value: 5, to: entryDate)!
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct WidgetData: Decodable, Hashable {
    let days: [String]
    let names: [String]
}

struct FlutterEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData?
    let index: Int
}

struct FlutterIOSWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        
        VStack {
            if let widgetData = entry.widgetData,
               entry.index < widgetData.days.count,
               entry.index < widgetData.names.count {
                Text(widgetData.names[entry.index]).font(Font.custom("PlayfairDisplay-Regular", size: 18)).foregroundColor(.white).bold().multilineTextAlignment(.center)
                Spacer(minLength: 1).frame(height: 2)
                Text(daysDifference(from: widgetData.days[entry.index])).font(Font.custom("PlayfairDisplay-Italic", size: 16)).foregroundColor(.white)
            } else {
                Text("No data available")
            }
        }
    }
    
    func daysDifference(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        guard let parsedDate = dateFormatter.date(from: dateString) else {
            return "Invalid date format"
        }

        let currentDate = Date()
        let calendar = Calendar.current

        let components = calendar.dateComponents([.day], from: parsedDate, to: currentDate)

        if let days = components.day {
            return "\(days) days"
        } else {
            return "Could not calculate days"
        }
    }
}

struct FlutterIOSWidget: Widget {
    let kind: String = "FlutterIOSWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlutterIOSWidgetEntryView(entry: entry).containerBackground(for: .widget) {
                Color(red: 18/255, green: 18/255, blue: 18/255)
            }
        }
        
        .configurationDisplayName("Flutter iOS Widget")
        .description("This is an example Flutter iOS widget.")
    }
}

struct FlutterIOSWidgetBundle: WidgetBundle {
    var body: some Widget {
        FlutterIOSWidget()
    }
}
