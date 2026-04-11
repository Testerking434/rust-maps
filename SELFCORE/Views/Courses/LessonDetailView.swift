// Views/Courses/LessonDetailView.swift
// Zeigt den Inhalt einer Lektion + Workbook-PDF + Übung
import SwiftUI
import WebKit

struct LessonDetailView: View {
    let lesson: Lesson
    let course: Course
    let onComplete: (Lesson) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var showWorkbook = false
    @State private var workbookURL: URL? = nil
    @State private var isLoadingWorkbook = false
    @State private var workbookError: String? = nil
    @State private var showExercise = false
    @State private var exerciseNotes = ""
    @State private var isCompleted = false
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color.scBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: SCSpacing.lg) {
                        // Header
                        lessonHeader

                        // Key Insights
                        if !lesson.keyInsights.isEmpty {
                            keyInsightsCard
                        }

                        // Content (Markdown rendered)
                        MarkdownView(text: lesson.contentMarkdown ?? "")
                            .padding(.horizontal, SCSpacing.md)

                        // Workbook PDF Button
                        if lesson.workbookURL != nil {
                            workbookButton
                        }

                        // Exercise
                        if let exercise = lesson.exercise {
                            ExerciseCard(exercise: exercise, notes: $exerciseNotes)
                        }

                        // Complete button
                        if !isCompleted {
                            Button(action: completeLesson) {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Lektion abschließen")
                                }
                            }
                            .buttonStyle(SCGoldButtonStyle())
                            .padding(.horizontal, SCSpacing.lg)
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.scSuccess)
                                Text("Abgeschlossen")
                                    .font(SCFont.headline(16))
                                    .foregroundColor(.scSuccess)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }

                        Color.clear.frame(height: 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Schließen") { dismiss() }
                        .foregroundColor(.scGold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if lesson.workbookURL != nil {
                        Button {
                            loadWorkbook()
                        } label: {
                            HStack(spacing: 4) {
                                if isLoadingWorkbook {
                                    ProgressView().scaleEffect(0.7).tint(.scGold)
                                } else {
                                    Image(systemName: "doc.fill")
                                        .foregroundColor(.scGold)
                                }
                                Text("Workbook")
                                    .font(SCFont.caption(13))
                                    .foregroundColor(.scGold)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showWorkbook) {
            if let url = workbookURL {
                WorkbookPDFView(url: url, title: "\(lesson.title) – Workbook")
            }
        }
        .onAppear { isCompleted = lesson.isCompleted }
    }

    // MARK: - Header
    var lessonHeader: some View {
        VStack(alignment: .leading, spacing: SCSpacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: course.icon)
                    .font(.system(size: 12))
                    .foregroundColor(course.swiftColor)
                Text(course.title)
                    .font(SCFont.caption(12))
                    .foregroundColor(.scTextSecondary)
                Text("·")
                    .foregroundColor(.scTextSecondary)
                Text("Lektion \(lesson.order)")
                    .font(SCFont.caption(12))
                    .foregroundColor(.scTextSecondary)
            }
            .padding(.horizontal, SCSpacing.md)
            .padding(.top, SCSpacing.sm)

            Text(lesson.title)
                .font(SCFont.display(26))
                .foregroundColor(.white)
                .padding(.horizontal, SCSpacing.md)

            if let sub = lesson.subtitle {
                Text(sub)
                    .font(SCFont.body(16))
                    .foregroundColor(.scTextSecondary)
                    .padding(.horizontal, SCSpacing.md)
            }

            HStack(spacing: SCSpacing.md) {
                Label(lesson.readingTime, systemImage: "clock")
                    .font(SCFont.caption(12))
                    .foregroundColor(.scTextSecondary)
                if lesson.workbookURL != nil {
                    Label("Workbook inklusive", systemImage: "doc.richtext")
                        .font(SCFont.caption(12))
                        .foregroundColor(.scGold)
                }
                if lesson.exercise != nil {
                    Label("Übung", systemImage: "pencil")
                        .font(SCFont.caption(12))
                        .foregroundColor(.scSignal)
                }
            }
            .padding(.horizontal, SCSpacing.md)
        }
    }

    // MARK: - Key Insights
    var keyInsightsCard: some View {
        VStack(alignment: .leading, spacing: SCSpacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.scGold)
                Text("KERNAUSSAGEN")
                    .font(SCFont.caption(11))
                    .foregroundColor(.scTextSecondary)
                    .tracking(1.5)
            }
            ForEach(lesson.keyInsights, id: \.self) { insight in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(course.swiftColor)
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    Text(insight)
                        .font(SCFont.body(14))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                }
            }
        }
        .padding(SCSpacing.md)
        .background(
            ZStack {
                Color.scCard
                LinearGradient(
                    colors: [course.swiftColor.opacity(0.06), .clear],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(SCRadius.lg)
        .padding(.horizontal, SCSpacing.md)
    }

    // MARK: - Workbook Button
    var workbookButton: some View {
        Button(action: loadWorkbook) {
            HStack(spacing: SCSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.scGold.opacity(0.2))
                        .frame(width: 48, height: 48)
                    if isLoadingWorkbook {
                        ProgressView().tint(.scGold)
                    } else {
                        Image(systemName: "doc.richtext.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.scGold)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Workbook öffnen")
                        .font(SCFont.headline(16))
                        .foregroundColor(.white)
                    Text("PDF mit Übungen & Reflexionsfragen")
                        .font(SCFont.caption(13))
                        .foregroundColor(.scTextSecondary)
                }
                Spacer()
                if let err = workbookError {
                    Text(err)
                        .font(SCFont.caption(11))
                        .foregroundColor(.scError)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.scTextSecondary)
                }
            }
            .padding(SCSpacing.md)
            .scCard()
            .padding(.horizontal, SCSpacing.md)
        }
    }

    // MARK: - Actions
    func loadWorkbook() {
        guard let urlString = lesson.workbookURL else { return }
        isLoadingWorkbook = true
        workbookError = nil

        Task {
            // 1. Get signed URL from server (for protection)
            if let signed = try? await ContentService.shared.fetchWorkbookURL(lessonId: lesson.id) {
                await MainActor.run {
                    workbookURL = URL(string: signed)
                    isLoadingWorkbook = false
                    showWorkbook = true
                }
                return
            }
            // 2. Fall back to direct URL (only works if not protected)
            await MainActor.run {
                workbookURL = URL(string: urlString)
                isLoadingWorkbook = false
                if workbookURL != nil {
                    showWorkbook = true
                } else {
                    workbookError = "Nicht verfügbar"
                }
            }
        }
    }

    func completeLesson() {
        withAnimation {
            isCompleted = true
        }
        onComplete(lesson)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

// MARK: - Markdown View (simple renderer)
struct MarkdownView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            ForEach(parseBlocks(text), id: \.id) { block in
                blockView(block)
            }
        }
    }

    @ViewBuilder
    func blockView(_ block: MarkdownBlock) -> some View {
        switch block.type {
        case .h1:
            Text(block.text)
                .font(SCFont.display(24))
                .foregroundColor(.white)
                .padding(.top, 4)
        case .h2:
            Text(block.text)
                .font(SCFont.headline(18))
                .foregroundColor(.white)
                .padding(.top, 4)
        case .h3:
            Text(block.text)
                .font(SCFont.subheadline(16))
                .foregroundColor(.scGold)
        case .quote:
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.scGold)
                    .frame(width: 3)
                    .cornerRadius(2)
                Text(block.text)
                    .font(SCFont.body(15))
                    .foregroundColor(.scTextSecondary)
                    .italic()
                    .lineSpacing(5)
            }
            .padding(.vertical, 4)
        case .bullet:
            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(Color.scGold.opacity(0.7))
                    .frame(width: 5, height: 5)
                    .padding(.top, 8)
                Text(block.text)
                    .font(SCFont.body(14))
                    .foregroundColor(.scTextSecondary)
                    .lineSpacing(4)
            }
        case .tableRow:
            HStack {
                ForEach(block.text.components(separatedBy: "|").filter { !$0.isEmpty }, id: \.self) { cell in
                    Text(cell.trimmingCharacters(in: .whitespaces))
                        .font(SCFont.caption(12))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, SCSpacing.sm)
            .background(Color.scCard)
            .cornerRadius(4)
        case .divider:
            Divider().background(Color.scBorder)
        case .paragraph:
            if block.text.isEmpty { Color.clear.frame(height: 4) }
            else {
                Text(styledText(block.text))
                    .font(SCFont.body(15))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(6)
            }
        }
    }

    func styledText(_ raw: String) -> AttributedString {
        var text = raw
        // Bold: **text** → bold
        var result = AttributedString()
        // Simple bold handling
        if let attr = try? AttributedString(markdown: text, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            return attr
        }
        result = AttributedString(text)
        return result
    }

    enum BlockType { case h1, h2, h3, paragraph, bullet, quote, divider, tableRow }
    struct MarkdownBlock: Identifiable {
        let id = UUID()
        let type: BlockType
        let text: String
    }

    func parseBlocks(_ raw: String) -> [MarkdownBlock] {
        raw.components(separatedBy: "\n").compactMap { line in
            if line.hasPrefix("# ")        { return MarkdownBlock(type: .h1, text: String(line.dropFirst(2))) }
            if line.hasPrefix("## ")       { return MarkdownBlock(type: .h2, text: String(line.dropFirst(3))) }
            if line.hasPrefix("### ")      { return MarkdownBlock(type: .h3, text: String(line.dropFirst(4))) }
            if line.hasPrefix("> ")        { return MarkdownBlock(type: .quote, text: String(line.dropFirst(2))) }
            if line.hasPrefix("- ")        { return MarkdownBlock(type: .bullet, text: String(line.dropFirst(2))) }
            if line.hasPrefix("---")       { return MarkdownBlock(type: .divider, text: "") }
            if line.hasPrefix("|")         { return MarkdownBlock(type: .tableRow, text: line) }
            return MarkdownBlock(type: .paragraph, text: line)
        }
    }
}

// MARK: - Exercise Card
struct ExerciseCard: View {
    let exercise: LessonExercise
    @Binding var notes: String
    @State private var expanded = false

    var typeColor: Color {
        switch exercise.type {
        case .journaling:   return .scGold
        case .reflection:   return .scSignal
        case .action:       return .scMut
        case .meditation:   return .scKlarheit
        case .breathing:    return .scVerbindung
        }
    }

    var typeIcon: String {
        switch exercise.type {
        case .journaling:   return "pencil.and.outline"
        case .reflection:   return "brain.head.profile"
        case .action:       return "bolt.fill"
        case .meditation:   return "moon.fill"
        case .breathing:    return "wind"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SCSpacing.md) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { expanded.toggle() }
            } label: {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: typeIcon)
                            .font(.system(size: 16))
                            .foregroundColor(typeColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ÜBUNG")
                                .font(SCFont.caption(10))
                                .foregroundColor(.scTextSecondary)
                                .tracking(1.5)
                            Text(exercise.title)
                                .font(SCFont.headline(15))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13))
                        .foregroundColor(.scTextSecondary)
                }
            }

            if expanded {
                VStack(alignment: .leading, spacing: SCSpacing.md) {
                    Text(exercise.description)
                        .font(SCFont.body(14))
                        .foregroundColor(.scTextSecondary)
                        .lineSpacing(4)

                    if let prompt = exercise.prompt {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reflexionsfragen:")
                                .font(SCFont.caption(12))
                                .foregroundColor(.scTextSecondary)
                            Text(prompt)
                                .font(SCFont.body(14))
                                .foregroundColor(.white)
                                .italic()
                                .lineSpacing(4)
                        }
                        .padding(SCSpacing.sm)
                        .background(typeColor.opacity(0.1))
                        .cornerRadius(SCRadius.sm)
                    }

                    // Notes input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Deine Notizen (optional)")
                            .font(SCFont.caption(12))
                            .foregroundColor(.scTextSecondary)
                        TextEditor(text: $notes)
                            .foregroundColor(.white)
                            .font(SCFont.body(14))
                            .frame(minHeight: 100)
                            .padding(SCSpacing.sm)
                            .background(Color.scCardElevated)
                            .cornerRadius(SCRadius.sm)
                            .scrollContentBackground(.hidden)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(SCSpacing.md)
        .background(
            ZStack {
                Color.scCard
                LinearGradient(
                    colors: [typeColor.opacity(0.06), .clear],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(SCRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: SCRadius.lg)
                .stroke(typeColor.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, SCSpacing.md)
    }
}

// MARK: - Workbook PDF Viewer
struct WorkbookPDFView: View {
    let url: URL
    let title: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            PDFWebView(url: url)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Schließen") { dismiss() }
                            .foregroundColor(.scGold)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.scGold)
                        }
                    }
                }
        }
    }
}

// MARK: - PDF Web View (WKWebView wrapper)
struct PDFWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = UIColor(Color.scBackground)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if url.isFileURL {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        } else {
            webView.load(URLRequest(url: url))
        }
    }
}
