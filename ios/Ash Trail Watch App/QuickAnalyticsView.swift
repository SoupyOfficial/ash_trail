import SwiftUI

struct QuickAnalyticsView: View {
    @EnvironmentObject var sessionManager: WatchSessionManager

    @State private var timeSinceTimer: Timer?
    @State private var liveSinceLastHit: String = "--"

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Connection status
                if !sessionManager.isReachable {
                    HStack(spacing: 4) {
                        Image(systemName: "iphone.slash")
                        Text("Cached data")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }

                // Hits Today
                StatCard(
                    title: "Hits Today",
                    value: "\(sessionManager.analytics.hitsToday)",
                    icon: "flame.fill",
                    color: .orange
                )

                // Total Duration
                StatCard(
                    title: "Total Duration",
                    value: sessionManager.analytics.formattedTotalDuration,
                    icon: "timer",
                    color: .blue
                )

                // Time Since Last Hit (live-updating)
                StatCard(
                    title: "Since Last Hit",
                    value: liveSinceLastHit,
                    icon: "clock.arrow.circlepath",
                    color: .green
                )

                // Average Gap
                StatCard(
                    title: "Avg Gap",
                    value: sessionManager.analytics.formattedAverageGap,
                    icon: "arrow.left.and.right",
                    color: .purple
                )
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Stats")
        .onAppear {
            startLiveTimer()
            sessionManager.refreshAnalytics()
        }
        .onDisappear {
            stopLiveTimer()
        }
    }

    // MARK: - Live timer for "time since last hit"

    private func startLiveTimer() {
        updateLiveSinceLastHit()
        timeSinceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateLiveSinceLastHit()
        }
    }

    private func stopLiveTimer() {
        timeSinceTimer?.invalidate()
        timeSinceTimer = nil
    }

    private func updateLiveSinceLastHit() {
        guard let seconds = sessionManager.analytics.timeSinceLastHitSeconds else {
            liveSinceLastHit = "--"
            return
        }
        // Add time elapsed since analytics were last computed
        let elapsed = Date().timeIntervalSince(sessionManager.analytics.lastUpdated)
        let total = seconds + elapsed
        liveSinceLastHit = formatLiveDuration(total)
    }

    private func formatLiveDuration(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        } else if totalSeconds < 3600 {
            let m = totalSeconds / 60
            let s = totalSeconds % 60
            return "\(m)m \(s)s"
        } else {
            let h = totalSeconds / 3600
            let m = (totalSeconds % 3600) / 60
            return "\(h)h \(m)m"
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .minimumScaleFactor(0.7)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.15))
        )
    }
}

#Preview {
    QuickAnalyticsView()
        .environmentObject(WatchSessionManager.shared)
}
