import SwiftUI

struct RecentEntriesView: View {
    @EnvironmentObject var sessionManager: WatchSessionManager

    var body: some View {
        Group {
            if sessionManager.recentEntries.isEmpty {
                emptyState
            } else {
                entryList
            }
        }
        .navigationTitle("Recent")
        .onAppear {
            sessionManager.refreshRecentEntries()
        }
    }

    // MARK: - Entry List

    private var entryList: some View {
        List(sessionManager.recentEntries) { entry in
            NavigationLink {
                EntryDetailView(entry: entry)
            } label: {
                EntryRow(entry: entry)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("No entries yet")
                .font(.headline)

            if !sessionManager.isReachable {
                Text("Connect to iPhone to sync")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Log your first session!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Entry Row

struct EntryRow: View {
    let entry: WatchLogEntry

    var body: some View {
        HStack(spacing: 8) {
            // Event type indicator
            Circle()
                .fill(colorForEventType(entry.eventType))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.relativeTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(entry.formattedDuration)
                    .font(.system(.body, design: .rounded, weight: .medium))
            }

            Spacer()
        }
    }

    private func colorForEventType(_ type: String) -> Color {
        switch type {
        case "vape": return .indigo
        case "inhale": return .blue
        case "sessionStart": return .green
        case "sessionEnd": return .red
        case "note": return .yellow
        case "purchase": return .mint
        default: return .gray
        }
    }
}

// MARK: - Entry Detail

struct EntryDetailView: View {
    let entry: WatchLogEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Event type
                HStack {
                    Circle()
                        .fill(colorForEventType(entry.eventType))
                        .frame(width: 12, height: 12)
                    Text(entry.eventTypeDisplayName)
                        .font(.headline)
                }

                Divider()

                // Duration
                DetailRow(label: "Duration", value: entry.formattedDuration)

                // Time
                DetailRow(label: "Time", value: formattedTime)

                // Relative
                DetailRow(label: "Ago", value: entry.relativeTime)

                // Mood (if available)
                if let mood = entry.moodRating {
                    DetailRow(label: "Mood", value: String(format: "%.0f/10", mood))
                }

                // Physical (if available)
                if let physical = entry.physicalRating {
                    DetailRow(label: "Physical", value: String(format: "%.0f/10", physical))
                }

                // Note (if available)
                if let note = entry.note, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Note")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(note)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Detail")
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: entry.eventAt)
    }

    private func colorForEventType(_ type: String) -> Color {
        switch type {
        case "vape": return .indigo
        case "inhale": return .blue
        case "sessionStart": return .green
        case "sessionEnd": return .red
        case "note": return .yellow
        case "purchase": return .mint
        default: return .gray
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .medium))
        }
    }
}

#Preview {
    RecentEntriesView()
        .environmentObject(WatchSessionManager.shared)
}
