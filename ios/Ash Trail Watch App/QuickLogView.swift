import SwiftUI
import WatchKit

struct QuickLogView: View {
    @EnvironmentObject var sessionManager: WatchSessionManager

    @State private var isRecording = false
    @State private var recordingStartTime: Date?
    @State private var elapsedSeconds: Double = 0
    @State private var timer: Timer?
    @State private var showConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let minimumDuration: Double = 1.0

    var body: some View {
        VStack(spacing: 12) {
            // Status indicator
            if !sessionManager.isReachable {
                Label("iPhone not connected", systemImage: "iphone.slash")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Duration display
            Text(formattedElapsed)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isRecording ? .orange : .primary)

            // Record button
            ZStack {
                Circle()
                    .fill(isRecording ? Color.orange : Color.accentColor)
                    .frame(width: 80, height: 80)
                    .scaleEffect(isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isRecording)

                if isRecording {
                    // Pulsing ring while recording
                    Circle()
                        .stroke(Color.orange.opacity(0.5), lineWidth: 3)
                        .frame(width: 90, height: 90)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .opacity(isRecording ? 0.0 : 1.0)
                        .animation(
                            .easeOut(duration: 1.0).repeatForever(autoreverses: false),
                            value: isRecording
                        )
                }

                Image(systemName: isRecording ? "stop.fill" : "circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isRecording {
                            startRecording()
                        }
                    }
                    .onEnded { _ in
                        if isRecording {
                            stopRecording()
                        }
                    }
            )

            Text(isRecording ? "Release to log" : "Press & hold")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 8)
        .navigationTitle("Log")
        .overlay {
            if showConfirmation {
                confirmationOverlay
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Confirmation overlay

    private var confirmationOverlay: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)

            Text("Logged!")
                .font(.headline)

            Text(formatDuration(elapsedSeconds))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showConfirmation = false
                }
                elapsedSeconds = 0
            }
        }
    }

    // MARK: - Recording Logic

    private func startRecording() {
        isRecording = true
        recordingStartTime = Date()
        elapsedSeconds = 0

        WKInterfaceDevice.current().play(.start)

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let start = recordingStartTime else { return }
            elapsedSeconds = Date().timeIntervalSince(start)
        }
    }

    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil

        guard let start = recordingStartTime else { return }
        let duration = Date().timeIntervalSince(start)
        elapsedSeconds = duration
        recordingStartTime = nil

        if duration < minimumDuration {
            elapsedSeconds = 0
            return
        }

        // Send to iPhone
        sessionManager.createLog(duration: duration) { success, result in
            if success {
                WKInterfaceDevice.current().play(.success)
                withAnimation {
                    showConfirmation = true
                }
            } else {
                WKInterfaceDevice.current().play(.failure)
                errorMessage = result ?? "Failed to log"
                showError = true
                elapsedSeconds = 0
            }
        }
    }

    // MARK: - Formatting

    private var formattedElapsed: String {
        if elapsedSeconds == 0 && !isRecording {
            return "0.0s"
        }
        return formatDuration(elapsedSeconds)
    }

    private func formatDuration(_ seconds: Double) -> String {
        if seconds < 60 {
            return String(format: "%.1fs", seconds)
        }
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return "\(m)m \(s)s"
    }
}

#Preview {
    QuickLogView()
        .environmentObject(WatchSessionManager.shared)
}
