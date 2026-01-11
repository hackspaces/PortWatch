import Foundation
import Combine

final class PortScanner: ObservableObject {
    @Published private(set) var appPorts: [AppPortInfo] = []
    @Published private(set) var totalPortCount: Int = 0
    @Published private(set) var isScanning: Bool = false
    @Published private(set) var lastUpdated: Date = Date()

    private var timer: Timer?

    func startAutoRefresh(interval: TimeInterval = 5.0) {
        stopAutoRefresh()
        scan()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.scan()
            }
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    func scan() {
        guard !isScanning else { return }
        isScanning = true

        Task.detached { [weak self] in
            guard let self = self else { return }
            let results = self.executeLsof()
            await MainActor.run {
                self.appPorts = results
                self.totalPortCount = results.reduce(0) { $0 + $1.ports.count }
                self.lastUpdated = Date()
                self.isScanning = false
            }
        }
    }

    private func executeLsof() -> [AppPortInfo] {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        process.arguments = ["-iTCP", "-sTCP:LISTEN", "-n", "-P"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            return []
        }

        return parseLsofOutput(output)
    }

    private func parseLsofOutput(_ output: String) -> [AppPortInfo] {
        var appPortsMap: [String: (ports: Set<Int>, pids: Set<Int>)] = [:]

        let lines = output.components(separatedBy: .newlines)
        for line in lines.dropFirst() {
            guard !line.isEmpty else { continue }

            let components = line.split(separator: " ", omittingEmptySubsequences: true)
            guard components.count >= 9 else { continue }

            let command = String(components[0])
            let pid = Int(components[1]) ?? 0

            // Find the field containing the port (format: *:PORT or IP:PORT)
            var port: Int?
            for component in components {
                let str = String(component)
                if str.contains(":"), let extracted = extractPort(from: str) {
                    port = extracted
                    break
                }
            }

            guard let foundPort = port else { continue }

            if var existing = appPortsMap[command] {
                existing.ports.insert(foundPort)
                existing.pids.insert(pid)
                appPortsMap[command] = existing
            } else {
                appPortsMap[command] = (ports: [foundPort], pids: [pid])
            }
        }

        return appPortsMap.map { name, info in
            AppPortInfo(
                appName: name,
                ports: Array(info.ports).sorted(),
                pids: info.pids
            )
        }.sorted { $0.appName.lowercased() < $1.appName.lowercased() }
    }

    private func extractPort(from field: String) -> Int? {
        let portPattern = ":([0-9]+)"
        guard let regex = try? NSRegularExpression(pattern: portPattern),
              let match = regex.firstMatch(
                in: field,
                range: NSRange(field.startIndex..., in: field)
              ),
              let portRange = Range(match.range(at: 1), in: field) else {
            return nil
        }

        return Int(field[portRange])
    }
}
