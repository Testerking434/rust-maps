import SwiftUI
import PhotosUI
import Vision

struct ContentView: View {

    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var recognizedText = ""
    @State private var statusMessage = "Noch kein Text erkannt."
    @State private var isWorking = false
    @State private var didCopy = false
    @State private var joinLines = false

    // Verbindet die erkannten Einzelzeilen zu Fließtext, wenn der Schalter
    // aktiv ist. Der ursprünglich erkannte Text bleibt unverändert erhalten,
    // der Schalter ist also jederzeit umkehrbar.
    private var displayText: String {
        guard joinLines, !recognizedText.isEmpty else { return recognizedText }
        return recognizedText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: " ")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Bild auswählen", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isWorking)

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

                Toggle("Fließtext (Zeilenumbrüche entfernen)", isOn: $joinLines)
                    .disabled(recognizedText.isEmpty)

                ScrollView {
                    Text(recognizedText.isEmpty ? statusMessage : displayText)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity)

                Button {
                    UIPasteboard.general.string = displayText
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
        guard let item else { return }

        image = nil
        recognizedText = ""
        didCopy = false
        isWorking = true
        defer { isWorking = false }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            statusMessage = "Das Bild konnte nicht geladen werden. Bitte wähle ein anderes Bild."
            return
        }

        let preparedImage = downscaled(uiImage, maxDimension: 3000)
        image = preparedImage

        guard let text = recognize(preparedImage) else {
            statusMessage = "Bei der Texterkennung ist ein Fehler aufgetreten."
            return
        }

        if text.isEmpty {
            statusMessage = "Kein Text auf dem Bild gefunden."
        }
        recognizedText = text
    }

    // Sehr große Fotos (z. B. 48-MP-Aufnahmen) vor der Erkennung verkleinern,
    // damit der Speicherverbrauch begrenzt bleibt. Das gezeichnete Ergebnis
    // hat immer Ausrichtung .up, die Orientierungs-Umrechnung bleibt korrekt.
    private func downscaled(_ uiImage: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = uiImage.size
        let largestSide = max(size.width, size.height)
        guard largestSide > maxDimension else { return uiImage }

        let scale = maxDimension / largestSide
        let newSize = CGSize(width: size.width * scale,
                             height: size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            uiImage.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private func recognize(_ uiImage: UIImage) -> String? {
        guard let cgImage = uiImage.cgImage else { return nil }

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
            return nil
        }

        let observations = request.results ?? []
        return observations
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
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
