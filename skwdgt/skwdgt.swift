//
//  skwdgt.swift
//  skwdgt
//
//  Created by leo on 2023-07-17.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
        []
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        for dayOffset in 0 ..< 14 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let theDay = Calendar.current.startOfDay(for: entryDate)
            let entry = SimpleEntry(date: theDay, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct skwdgtEntryView : View {
    var entry: Provider.Entry
    
    let d = DateFormatter()
    var displayText: String {
        d.dateFormat = "e:MM MMM\nddEEE"
        return d.string(from: entry.date).replacingOccurrences(of: " ", with: "")
    }

    var body: some View {
        ZStack {
            HStack(spacing: 6) {
                Text(displayText.split(separator: ":")[0])
                    .font(.custom("SheikahGlyphs", size: 30)).padding(5)
                    .offset(x: 2, y: 0.5)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.black).offset(y: -1)
                    )
                VStack {
                    Text(displayText.split(separator: ":")[1])
                        .minimumScaleFactor(0.5)
                        .font(.custom("SheikahGlyphs", size: 20))
                }
            }
        }
    }
}

struct skwdgt: Widget {
    let kind: String = "com.wyw.sheikahwidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            skwdgtEntryView(entry: entry)
        }
        .configurationDisplayName("Sheikah Date")
        .description("e|MM,MMM;dd,EEE")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct skwdgt_Previews: PreviewProvider {
    static var previews: some View {
        skwdgtEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
