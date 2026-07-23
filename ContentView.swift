import SwiftUI
import PhotosUI
import Vision

struct ContentView: View {

    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var recognizedText = ""
    @State private var isWorking = false
    @State private var didCopy = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Bild auswählen", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if isWorking {
                    ProgressView("Erkenne Text…")
                }

                ScrollView {
                    Text(recognizedText.isEmpty ? "Noch kein Text erkannt." : recognizedText)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity)

                Button {
                    UIPasteboard.general.string = recognizedText
                    didCopy = true
                } label: {
                    Label(didCopy ? "Kopiert" : "Text kopieren",
                          systemImage: didCopy ? "checkmark" : "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .disabled(recognizedText.isEmpty)
            }
            .padding()
            .navigationTitle("Textklar")
        }
        .onChange(of: pickerItem) { _, newItem in
            Task { await load(newItem) }
        }
    }

    private func load(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }

        image = uiImage
        recognizedText = ""
        didCopy = false
        isWorking = true
        recognizedText = recognize(uiImage)
        isWorking = false
    }

    private func recognize(_ uiImage: UIImage) -> String {
        guard let cgImage = uiImage.cgImage else { return "" }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["de-DE"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: cgOrientation(uiImage.imageOrientation)
        )

        do {
            try handler.perform([request])
        } catch {
            return "Fehler bei der Erkennung."
        }

        let observations = request.results ?? []
        return observations
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }

    private func cgOrientation(_ orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}

#Preview {
    ContentView()
}
