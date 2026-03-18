import SwiftUI

struct GestureKeyboardView: View {
    let onKey: (String) -> Void
    let onBytes: ([UInt8]) -> Void
    @State private var inputText = ""

    private let quickActions = ["/commit", "/help", "yes", "no"]

    private let specialKeys: [(String, [UInt8])] = [
        ("Tab", [0x09]),
        ("Esc", [0x1b]),
        ("^C", [0x03]),
        ("\u{2191}", [0x1b, 0x5b, 0x41]),  // ↑
        ("\u{2193}", [0x1b, 0x5b, 0x42]),  // ↓
        ("\u{2190}", [0x1b, 0x5b, 0x44]),  // ←
        ("\u{2192}", [0x1b, 0x5b, 0x43]),  // →
        ("\u{23CE}", [0x0d]),               // ⏎
    ]

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(quickActions, id: \.self) { action in
                    Button(action) {
                        onKey(action + "\n")
                    }
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                }
            }

            HStack(spacing: 8) {
                ForEach(specialKeys, id: \.0) { label, bytes in
                    Button(label) {
                        onBytes(bytes)
                    }
                    .font(.system(.body, design: .monospaced))
                    .frame(minWidth: 36, minHeight: 36)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
                }
            }

            HStack {
                TextField("Type here...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onSubmit {
                        onKey(inputText + "\n")
                        inputText = ""
                    }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
