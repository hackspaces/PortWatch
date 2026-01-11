import SwiftUI

struct MenuView: View {
    @ObservedObject var scanner: PortScanner
    @State private var hoveredApp: UUID?

    var body: some View {
        VStack(spacing: 0) {
            headerView

            if scanner.appPorts.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(scanner.appPorts) { app in
                            PortRowView(app: app, isHovered: hoveredApp == app.id)
                                .onHover { hovering in
                                    hoveredApp = hovering ? app.id : nil
                                }
                        }
                    }
                    .padding(.vertical, 6)
                }
                .frame(maxHeight: 320)
            }

            footerView
        }
        .frame(width: 280)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var headerView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "network")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Active Ports")
                    .font(.system(size: 13, weight: .semibold))
                Text("\(scanner.appPorts.count) services")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(scanner.totalPortCount)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.green)
            }

            VStack(spacing: 4) {
                Text("All Clear")
                    .font(.system(size: 14, weight: .semibold))
                Text("No services listening on ports")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
    }

    private var footerView: some View {
        HStack(spacing: 0) {
            Button(action: { scanner.scan() }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .rotationEffect(.degrees(scanner.isScanning ? 360 : 0))
                        .animation(
                            scanner.isScanning
                                ? .linear(duration: 0.8).repeatForever(autoreverses: false)
                                : .default,
                            value: scanner.isScanning
                        )
                    Text("Refresh")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(scanner.isScanning)

            Spacer()

            Text(timeAgoString)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)

            Spacer()

            Button(action: { NSApp.terminate(nil) }) {
                HStack(spacing: 6) {
                    Image(systemName: "power")
                        .font(.system(size: 11, weight: .medium))
                    Text("Quit")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(nsColor: .separatorColor).opacity(0.2))
    }

    private var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: scanner.lastUpdated, relativeTo: Date())
    }
}

struct PortRowView: View {
    let app: AppPortInfo
    let isHovered: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(app.iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: app.iconName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(app.iconColor)
            }

            // App name and ports
            VStack(alignment: .leading, spacing: 3) {
                Text(app.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)

                Text(app.portsDisplay)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Port count badge
            Text("\(app.ports.count)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(nsColor: .separatorColor).opacity(0.3))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color(nsColor: .selectedContentBackgroundColor).opacity(0.5) : Color.clear)
        )
        .padding(.horizontal, 6)
    }
}

#Preview {
    MenuView(scanner: PortScanner())
        .frame(width: 280, height: 400)
}
