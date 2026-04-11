// Models/Lesson.swift
import SwiftUI

// MARK: - Lesson
struct Lesson: Identifiable, Codable {
    var id: String
    var courseId: String
    var title: String
    var subtitle: String?
    var order: Int
    var contentMarkdown: String?     // Text-Inhalt (Markdown)
    var contentHTML: String?         // HTML für komplexere Layouts
    var workbookURL: String?         // PDF Workbook (signierte URL vom Server)
    var coverImageURL: String?       // Vorschaubild
    var durationMinutes: Int         // Geschätzte Lesezeit
    var isCompleted: Bool
    var isLocked: Bool               // false wenn Kurs freigeschaltet
    var keyInsights: [String]        // 3-5 Kernaussagen
    var exercise: LessonExercise?    // Übung am Ende der Lektion

    var readingTime: String {
        durationMinutes <= 5 ? "~\(durationMinutes) Min" : "\(durationMinutes) Min"
    }
}

// MARK: - Lesson Exercise
struct LessonExercise: Codable {
    var title: String
    var description: String
    var type: ExerciseType
    var prompt: String?          // Journaling-Prompt etc.

    enum ExerciseType: String, Codable {
        case journaling    = "journaling"
        case reflection    = "reflection"
        case action        = "action"
        case meditation    = "meditation"
        case breathing     = "breathing"
    }
}

// MARK: - Lesson Progress
struct LessonProgress: Codable {
    var lessonId: String
    var courseId: String
    var completedAt: Date
    var notes: String?
    var exerciseCompleted: Bool
}

// MARK: - Course with Lessons (extended)
struct CourseDetail: Codable {
    var course: Course
    var lessons: [Lesson]

    var completedCount: Int { lessons.filter { $0.isCompleted }.count }
    var nextLesson: Lesson? { lessons.first { !$0.isCompleted && !$0.isLocked } }
}

// MARK: - Static preview lessons (used until server is ready)
extension Lesson {
    static func previewLessons(for courseId: String) -> [Lesson] {
        switch courseId {
        case "awakening":
            return awakeningLessons
        case "origin":
            return originLessons
        default:
            return awakeningLessons
        }
    }

    static let awakeningLessons: [Lesson] = [
        Lesson(
            id: "awakening-l1",
            courseId: "awakening",
            title: "Wer du wirklich bist",
            subtitle: "Die Maske und das wahre Gesicht",
            order: 1,
            contentMarkdown: """
# Wer du wirklich bist

Bevor wir beginnen, eine Frage: **Wann hast du zuletzt dein wahres Ich gezeigt?**

Nicht die Version, die du auf Instagram zeigst. Nicht die, die du bei der Arbeit performst. Die echte.

## Die Maske

Jeder von uns trägt Masken. Sie schützen uns. Sie wurden in der Kindheit gebaut, um Ablehnung zu vermeiden, Liebe zu sichern, Schmerz zu verhindern.

Das Problem: Die Maske wächst fest. Irgendwann wissen wir nicht mehr, was Maske ist und was wir wirklich sind.

## Der erste Schritt

AWAKENING beginnt mit einer einfachen Übung: **Beobachten ohne Urteilen.**

Beobachte heute, wie du in verschiedenen Situationen anders wirst:
- Mit dem Chef?
- Mit der Familie?
- Allein?

Welche Version fühlt sich am echtesten an?

> "Du musst dich nicht finden. Du warst schon immer da." — GEN:SELFCORE
""",
            contentHTML: nil,
            workbookURL: "https://api.genselfcore.de/v1/workbooks/awakening-l1.pdf",
            coverImageURL: nil,
            durationMinutes: 8,
            isCompleted: false,
            isLocked: false,
            keyInsights: [
                "Jeder trägt Masken — das ist normal und menschlich",
                "Die Maske entsteht als Schutz in der Kindheit",
                "Das wahre Ich ist nie verschwunden — nur verdeckt",
                "Beobachten ist der erste Schritt zur Selbsterkenntnis"
            ],
            exercise: LessonExercise(
                title: "Die Masken-Übung",
                description: "Schreibe 3 Situationen auf, in denen du dich 'anders' verhältst als du dich innerlich fühlst.",
                type: .journaling,
                prompt: "In welchen Situationen trage ich eine Maske? Was schütze ich damit? Was wäre, wenn ich sie heute ablegen würde?"
            )
        ),
        Lesson(
            id: "awakening-l2",
            courseId: "awakening",
            title: "Das Trauma-Muster",
            subtitle: "Woher deine Reaktionen kommen",
            order: 2,
            contentMarkdown: """
# Das Trauma-Muster

Dein Nervensystem hat ein gutes Gedächtnis.

## Was ist ein Trigger?

Wenn dich jemand kritisiert und du sofort in Defensive gehst — das ist kein Charakter. Das ist Programmierung.

Jede extreme Reaktion hat eine Wurzel. Meistens liegt sie Jahre zurück.

## Die Neurowissenschaft

Unser Gehirn speichert emotionale Erfahrungen im **limbischen System**. Bei ähnlichen Reizen aktiviert es dieselbe Reaktion — auch Jahrzehnte später.

Das ist keine Schwäche. Das ist Biologie.

## Was das bedeutet

Du bist nicht "überreagierend". Dein System reagiert auf eine vergangene Bedrohung, die heute nicht mehr existiert.

Das Ziel: Das Muster erkennen, bevor du reagierst.

> "Zwischen Reiz und Reaktion liegt ein Raum. In diesem Raum liegt deine Freiheit." — Viktor Frankl
""",
            contentHTML: nil,
            workbookURL: "https://api.genselfcore.de/v1/workbooks/awakening-l2.pdf",
            coverImageURL: nil,
            durationMinutes: 10,
            isCompleted: false,
            isLocked: false,
            keyInsights: [
                "Trigger sind Reaktionen auf vergangene Erlebnisse",
                "Das Nervensystem reagiert automatisch — ohne Bewusstsein",
                "Zwischen Reiz und Reaktion gibt es einen Raum",
                "Muster erkennen ist der Beginn von Freiheit"
            ],
            exercise: LessonExercise(
                title: "Trigger-Karte",
                description: "Denke an deine letzte starke emotionale Reaktion. Wo könnte die Wurzel liegen?",
                type: .reflection,
                prompt: "Was hat mich zuletzt wirklich getriggert? Wie alt habe ich mich in diesem Moment gefühlt? Welche frühere Situation hat sich ähnlich angefühlt?"
            )
        ),
        Lesson(
            id: "awakening-l3",
            courseId: "awakening",
            title: "Die innere Stimme",
            subtitle: "Kritik vs. Kompass",
            order: 3,
            contentMarkdown: """
# Die innere Stimme

Es gibt zwei innere Stimmen. Lernst du sie zu unterscheiden, verändert sich alles.

## Der innere Kritiker

Er sagt: "Du bist nicht gut genug." "Wer glaubt du zu sein?" "Das klappt eh nicht."

Er klingt wie du — aber er ist es nicht. Er ist eine gesammelte Version aller negativen Rückmeldungen, die du je erhalten hast.

## Der innere Kompass

Er sagt: "Das fühlt sich falsch an." "Da liegt etwas." "Das ist wichtig."

Er ist leise. Er drängt sich nicht auf. Aber er lügt nie.

## Die Unterscheidung

| Innerer Kritiker | Innerer Kompass |
|-----------------|----------------|
| Laut und repetitiv | Ruhig und klar |
| Basiert auf Angst | Basiert auf Werten |
| Generalisiert | Spezifisch |
| Verletzt | Führt |

> "Der Kritiker schützt dich vor Scham. Der Kompass führt dich zur Wahrheit." — GEN:SELFCORE
""",
            contentHTML: nil,
            workbookURL: "https://api.genselfcore.de/v1/workbooks/awakening-l3.pdf",
            coverImageURL: nil,
            durationMinutes: 7,
            isCompleted: false,
            isLocked: false,
            keyInsights: [
                "Der innere Kritiker ist nicht du — er ist Programmierung",
                "Der innere Kompass ist die echte Führung",
                "Der Unterschied liegt in der Energie: Angst vs. Werte",
                "Beide Stimmen können unterschieden werden"
            ],
            exercise: LessonExercise(
                title: "Stimmen-Protokoll",
                description: "Beobachte heute deine innere Stimme. Notiere: Wann spricht der Kritiker? Wann der Kompass?",
                type: .journaling,
                prompt: "Was sagt mein innerer Kritiker heute? Was sagt mein Kompass? Was ist der Unterschied in der Qualität dieser Stimmen?"
            )
        )
    ]

    static let originLessons: [Lesson] = [
        Lesson(
            id: "origin-l1",
            courseId: "origin",
            title: "Deine Ursprungsgeschichte",
            subtitle: "Wie du geworden bist, wer du bist",
            order: 1,
            contentMarkdown: """
# Deine Ursprungsgeschichte

Jeder Held hat eine Origin Story. Auch du.

## Warum die Vergangenheit wichtig ist

Nicht um in ihr zu leben. Sondern um sie zu verstehen.

Was in der Kindheit nicht verarbeitet wurde, erscheint in der Gegenwart — als Muster, als Beziehungen, als Entscheidungen.

## Die vier Prägungen

**1. Bindungsmuster**
Wie hast du als Kind Liebe erfahren? War sie verfügbar? Bedingt? Unvorhersehbar?

**2. Elterliche Botschaften**
Was hast du implizit gelernt? "Zeig keine Schwäche." "Sei perfekt." "Störe nicht."

**3. Überlebensstrategien**
Was hast du getan um Schmerz zu vermeiden? Rückzug? Leistung? Humor?

**4. Kernüberzeugungen**
Welche Sätze über dich selbst entstanden damals? "Ich bin nicht genug." "Ich muss mich beweisen."

> "Deine Vergangenheit erklärt dich. Sie definiert dich nicht." — GEN:SELFCORE
""",
            contentHTML: nil,
            workbookURL: "https://api.genselfcore.de/v1/workbooks/origin-l1.pdf",
            coverImageURL: nil,
            durationMinutes: 12,
            isCompleted: false,
            isLocked: true,
            keyInsights: [
                "Die Vergangenheit erklärt — sie definiert nicht",
                "Vier Hauptprägungen formen unsere Muster",
                "Bindungsmuster entstehen in den ersten Lebensjahren",
                "Kernüberzeugungen können verändert werden"
            ],
            exercise: LessonExercise(
                title: "Origin Map",
                description: "Zeichne eine einfache Karte deiner prägendsten Kindheitserfahrungen.",
                type: .reflection,
                prompt: "Was waren die 3 prägendsten Erfahrungen meiner Kindheit? Welche Überzeugung hat jede davon in mir hinterlassen?"
            )
        )
    ]
}
