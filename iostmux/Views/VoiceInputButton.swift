import SwiftUI
import Speech
import AVFoundation

struct VoiceInputButton: View {
    let onText: (String) -> Void
    @State private var isRecording = false
    @State private var recognizedText = ""
    private let audioEngine = AVAudioEngine()
    @State private var recognitionTask: SFSpeechRecognitionTask?

    var body: some View {
        Button {
            if isRecording { stopRecording() }
            else { startRecording() }
        } label: {
            Image(systemName: isRecording ? "mic.fill" : "mic")
                .font(.title2)
                .foregroundStyle(isRecording ? .red : .white)
                .padding(12)
                .background(.ultraThinMaterial, in: Circle())
        }
    }

    private func startRecording() {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else { return }
            AVAudioApplication.requestRecordPermission { granted in
                guard granted else { return }
                DispatchQueue.main.async { beginSession() }
            }
        }
    }

    private func beginSession() {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-Hans"))
            ?? SFSpeechRecognizer()!
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        isRecording = true

        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                recognizedText = result.bestTranscription.formattedString
                if result.isFinal {
                    stopRecording()
                    onText(recognizedText)
                }
            }
            if error != nil { stopRecording() }
        }
    }

    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
    }
}
