//
//  PersWidget.swift
//  PersWidget
//
//  Created by Buzzware Tech on 25/08/2021.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct PersWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack{
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
            VStack {
                VStack(alignment: .leading) {
                    Text("Capture Events Instantly")
                        .font(.system(size: 22))
                        .fontWeight(.medium)
                        .lineLimit(3)
                        .foregroundColor(.white)
                        .padding(.top,1)
                        .padding(.leading,8)
                        .padding(.trailing,8)
                    Text("Tap to start video recording")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .lineLimit(3)
                        .foregroundColor(.white)
                        .padding(.bottom,0.2)
                        .padding(.leading,8)
                }
                .padding(.top,4)
                
                Image("AppLogo1")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom,1)
                    
                
            }
            
        }
    }
}

@main
struct PersWidget: Widget {
    let kind: String = "PersWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PersWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct PersWidget_Previews: PreviewProvider {
    static var previews: some View {
        PersWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
