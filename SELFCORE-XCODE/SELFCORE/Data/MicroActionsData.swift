// Data/MicroActionsData.swift
import Foundation

struct MicroAction: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var duration: String     // e.g. "5 Min"
    var dimension: DimensionType
    var difficulty: Int      // 1-3
    var isPremium: Bool = false
}

struct MicroActionsData {

    static func dailyAction(for profile: UserProfile) -> MicroAction {
        let dimension = profile.dimensions.weakest
        let all = actions(for: dimension)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[dayOfYear % all.count]
    }

    static func random(for dimension: DimensionType) -> MicroAction {
        let all = actions(for: dimension)
        return all.randomElement() ?? all[0]
    }

    static func actions(for dimension: DimensionType) -> [MicroAction] {
        switch dimension {
        case .selbstkenntnis: return selbstkenntnisMicroActions
        case .authentizitaet: return authentizitaetMicroActions
        case .klarheit:       return klarheitMicroActions
        case .mut:            return mutMicroActions
        case .verbindung:     return verbindungMicroActions
        }
    }

    // MARK: - Selbstkenntnis (30 Actions)
    static let selbstkenntnisMicroActions: [MicroAction] = [
        MicroAction(title: "Journaling: 3 Wahrheiten", description: "Schreibe 3 Dinge auf, die du dir selbst heute eingestehen musst.", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 1),
        MicroAction(title: "Werte-Check", description: "Nenne 5 deiner Kernwerte. Handelst du heute nach ihnen?", duration: "3 Min", dimension: .selbstkenntnis, difficulty: 1),
        MicroAction(title: "Emotionslog", description: "Tracke stündlich deine Emotion mit einem Wort.", duration: "Ganztag", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Stärken benennen", description: "Frage 3 Menschen: Was ist meine größte Stärke?", duration: "10 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Saboteur erkennen", description: "Wer in dir sabotiert heute dein Wachstum?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Körper-Scan", description: "5 Minuten: Wo sitzt gerade Spannung in deinem Körper?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 1),
        MicroAction(title: "Peak-Moment", description: "Welcher Moment deines Lebens zeigt dein wahres Ich?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 1),
        MicroAction(title: "Gegenwarts-Reflexion", description: "Was verschweigst du dir selbst gerade?", duration: "3 Min", dimension: .selbstkenntnis, difficulty: 3),
        MicroAction(title: "Energie-Audit", description: "Welche 3 Dinge geben dir Energie? Welche 3 rauben sie?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 1),
        MicroAction(title: "Kindheits-Muster", description: "Welches Muster aus deiner Kindheit wiederholt sich heute?", duration: "10 Min", dimension: .selbstkenntnis, difficulty: 3),
        MicroAction(title: "Täuschungs-Check", description: "In welchem Bereich täuschst du dich selbst?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 3),
        MicroAction(title: "Triggers dokumentieren", description: "Was hat dich heute getriggert? Warum wirklich?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Glaubenssatz-Mining", description: "Beende: 'Ich verdiene nicht...' — was kommt?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 3),
        MicroAction(title: "Dankbarkeits-Tiefe", description: "3 tiefe Dankbarkeiten — keine oberflächlichen.", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 1),
        MicroAction(title: "Schatten-Aspekt", description: "Was an anderen nervt dich? Das ist oft ein Spiegel.", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 3),
        MicroAction(title: "Rollen-Analyse", description: "Welche Rollen spielst du: Sohn/Tochter, Freund, Kollege?", duration: "8 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Brief ans Ich", description: "Schreibe einen Brief an dein 15-jähriges Ich.", duration: "10 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Vision-Alignment", description: "Handelt dein heutiges Ich nach deiner 5-Jahres-Vision?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Schwächen annehmen", description: "Nenne 3 Schwächen ohne sie zu rechtfertigen.", duration: "3 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Wahrheits-Minute", description: "Sage laut: Was ich mir selbst schon lange sagen wollte.", duration: "1 Min", dimension: .selbstkenntnis, difficulty: 3),
        MicroAction(title: "Identitäts-Statement", description: "Beende: 'Ich bin jemand der...' mit 5 echten Aussagen.", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Erfolgs-Definition", description: "Was bedeutet Erfolg WIRKLICH für dich — nicht für andere?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Keine-Maske-Stunde", description: "Eine Stunde ohne Rolle. Nur du.", duration: "60 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Intuitions-Check", description: "Was sagt dein Bauchgefühl zu deiner aktuellen Situation?", duration: "3 Min", dimension: .selbstkenntnis, difficulty: 1),
        MicroAction(title: "Angst-Inventur", description: "Welche Angst hält dich gerade am meisten zurück?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 3),
        MicroAction(title: "Vergangenheits-Dank", description: "Wofür bist du deiner Vergangenheit dankbar?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Motivation-Wurzel", description: "Warum willst du wachsen? Die echte Antwort.", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 3),
        MicroAction(title: "Konsistenz-Reflexion", description: "Wie konsistent bist du mit deinen Worten zu deinen Taten?", duration: "5 Min", dimension: .selbstkenntnis, difficulty: 2),
        MicroAction(title: "Komfort-Zone Mapping", description: "Zeichne auf: Was liegt in, was außerhalb deiner Komfortzone?", duration: "10 Min", dimension: .selbstkenntnis, difficulty: 1),
        MicroAction(title: "Selbst-Mitgefühl", description: "Sag dir selbst, was du einem besten Freund in deiner Lage sagen würdest.", duration: "3 Min", dimension: .selbstkenntnis, difficulty: 1),
    ]

    // MARK: - Authentizität (30 Actions)
    static let authentizitaetMicroActions: [MicroAction] = [
        MicroAction(title: "Nein sagen", description: "Sage heute einmal bewusst Nein zu etwas, dem du sonst zustimmst.", duration: "Moment", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Ehrliches Gespräch", description: "Führe ein Gespräch ohne Höflichkeitslügen.", duration: "15 Min", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Maske ablegen", description: "Zeige einer Person heute eine echte Schwäche.", duration: "5 Min", dimension: .authentizitaet, difficulty: 3),
        MicroAction(title: "Wert-Statement", description: "Formuliere klar: Ich stehe für... Ich stehe nicht für...", duration: "5 Min", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Fremd-Erwartungen", description: "Liste 3 Erwartungen die andere an dich haben, die nicht deine sind.", duration: "5 Min", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Outfit der Seele", description: "Ziehe heute etwas an, das wirklich du bist — nicht was passt.", duration: "1 Min", dimension: .authentizitaet, difficulty: 1),
        MicroAction(title: "Unpopuläre Meinung", description: "Teile eine Meinung, die du normalerweise zurückhältst.", duration: "Moment", dimension: .authentizitaet, difficulty: 3),
        MicroAction(title: "Verrat an sich selbst", description: "Wann hast du zuletzt gegen deine Werte gehandelt? Warum?", duration: "5 Min", dimension: .authentizitaet, difficulty: 3),
        MicroAction(title: "Gefühle ausdrücken", description: "Sage jemand heute: Ich fühle mich gerade... (ohne Rechtfertigung)", duration: "Moment", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Social-Media-Pause", description: "2 Stunden offline. Was fühlst du ohne digitale Persona?", duration: "2 Stunden", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Vergleichs-Stopp", description: "Jedes Mal wenn du dich vergleichst: Atme und frage: Was brauche ICH?", duration: "Ganztag", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Entschuldigung", description: "Entschuldige dich bei jemandem, bei dem du es schon lange solltest.", duration: "5 Min", dimension: .authentizitaet, difficulty: 3),
        MicroAction(title: "Leidenschaft leben", description: "Tu 15 Minuten das, was dir wirklich Freude macht — ohne Zweck.", duration: "15 Min", dimension: .authentizitaet, difficulty: 1),
        MicroAction(title: "Grenzziehung", description: "Setze eine klare Grenze in einer Beziehung die sie braucht.", duration: "5 Min", dimension: .authentizitaet, difficulty: 3),
        MicroAction(title: "Eigenartigkeit feiern", description: "Was macht dich seltsam? Feiere genau das heute.", duration: "5 Min", dimension: .authentizitaet, difficulty: 1),
        MicroAction(title: "Konformitäts-Audit", description: "Wo conformierst du dich gegen deinen Willen?", duration: "5 Min", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Applaus-Unabhängigkeit", description: "Tu heute etwas Gutes ohne es jemandem zu erzählen.", duration: "Ganztag", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Wut zulassen", description: "Was ärgert dich wirklich? Schreibe es ohne Filter.", duration: "5 Min", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Verletzlichkeit zeigen", description: "Erzähle jemandem von einer echten Unsicherheit.", duration: "5 Min", dimension: .authentizitaet, difficulty: 3),
        MicroAction(title: "Nein-Übung", description: "Sende eine Absage die du schon lange vor dir herschiebst.", duration: "5 Min", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Authentisches Foto", description: "Mache ein Foto von dir, das du NICHT veröffentlichen würdest.", duration: "1 Min", dimension: .authentizitaet, difficulty: 1),
        MicroAction(title: "Warum-Kette", description: "Warum machst du das? 5x 'Warum?' hintereinander fragen.", duration: "5 Min", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Perfektionismus loslassen", description: "Schicke etwas ab, bevor es perfekt ist.", duration: "Moment", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Selbst-Akzeptanz", description: "Sage dir im Spiegel: Ich akzeptiere mich vollständig.", duration: "1 Min", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Wahrheit im Schweigen", description: "In welchen Situationen schweigst du, obwohl du sprechen solltest?", duration: "5 Min", dimension: .authentizitaet, difficulty: 3),
        MicroAction(title: "Trauma-Anerkennung", description: "Benenne eine Erfahrung die dich geformt hat, ohne sie wegzureden.", duration: "5 Min", dimension: .authentizitaet, difficulty: 3),
        MicroAction(title: "Echtes Lachen", description: "Tue heute etwas, das dich wirklich zum Lachen bringt.", duration: "15 Min", dimension: .authentizitaet, difficulty: 1),
        MicroAction(title: "Unfiltered Write", description: "Schreibe 5 Minuten ohne aufzuhören und ohne zu löschen.", duration: "5 Min", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Zustimmungs-Pause", description: "Bevor du zustimmst: Frage innerlich: Will ICH das wirklich?", duration: "Ganztag", dimension: .authentizitaet, difficulty: 2),
        MicroAction(title: "Unbekannte Seite zeigen", description: "Teile mit jemandem eine Seite von dir, die kaum jemand kennt.", duration: "10 Min", dimension: .authentizitaet, difficulty: 3),
    ]

    // MARK: - Klarheit (30 Actions)
    static let klarheitMicroActions: [MicroAction] = [
        MicroAction(title: "MIT-Technik", description: "Bestimme deine 1-3 Most Important Tasks für heute.", duration: "5 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Vision schreiben", description: "Beschreibe in 200 Wörtern wie dein Leben in 3 Jahren aussieht.", duration: "10 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Ablenkungen eliminieren", description: "Identifiziere deine größte Ablenkung und eliminiere sie für 2h.", duration: "2 Stunden", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Gehirn-Dump", description: "Schreibe alles aus deinem Kopf auf eine Seite Papier.", duration: "10 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Decision Journal", description: "Dokumentiere eine wichtige Entscheidung mit allen Pros/Cons.", duration: "10 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "10-10-10-Regel", description: "Wie fühlt sich diese Entscheidung in 10 Min, 10 Mon, 10 Jahren an?", duration: "5 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Nein-Liste", description: "Was sagst du ab sofort nicht mehr Ja zu?", duration: "5 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Fokus-Block", description: "90 Minuten ohne Unterbrechung an einer Sache arbeiten.", duration: "90 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Ziel-Hierarchie", description: "Ordne deine Ziele nach echter Wichtigkeit — nicht Dringlichkeit.", duration: "10 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Digital Detox", description: "Keine sozialen Medien vor 12 Uhr.", duration: "Morgen", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Schlaf-Optimierung", description: "Gleiche Schlaf- und Aufwachzeit wie morgen. Messe die Klarheit.", duration: "Ganztag", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Stille-Minute", description: "60 Sekunden absolute Stille. Kein Handy, keine Musik.", duration: "1 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Komplexität reduzieren", description: "Vereinfache etwas in deinem Leben, das unnötig komplex ist.", duration: "15 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Menü-Elimination", description: "Plane alle Mahlzeiten heute vorab — null Entscheidungen.", duration: "5 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Morgen-Intention", description: "Setze beim Aufwachen eine klare Intention für den Tag.", duration: "1 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Abend-Review", description: "Was hat heute funktioniert? Was nicht? Was wird anders?", duration: "5 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Wert-Entscheidung", description: "Treffe heute eine Entscheidung basierend auf Werten, nicht Gefühlen.", duration: "Moment", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Kalender-Audit", description: "Lösche 3 Termine die nicht zu deinen Prioritäten passen.", duration: "10 Min", dimension: .klarheit, difficulty: 3),
        MicroAction(title: "Chaos-Elimination", description: "Räume einen physischen Bereich auf, der dich kognitiv belastet.", duration: "15 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Fokus-Wort", description: "Wähle ein Wort das deinen heutigen Fokus definiert.", duration: "1 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Zweifels-Analyse", description: "Was ist die eigentliche Ursache deines größten Zweifels?", duration: "5 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Noise vs Signal", description: "Welche Informationen konsumierst du täglich, die dir nichts nützen?", duration: "5 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Prioritäten-Matrix", description: "Erstelle eine 2x2 Matrix: Wichtig/Dringend für deine Tasks.", duration: "10 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Ziel-Sichtbarkeit", description: "Schreibe dein Hauptziel auf und befestige es sichtbar.", duration: "3 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Reaktions-Pause", description: "Warte 60 Sekunden bevor du auf jede Nachricht antwortest.", duration: "Ganztag", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Langzeit-Denken", description: "Wie sieht diese Situation in 5 Jahren aus? Ist sie noch wichtig?", duration: "3 Min", dimension: .klarheit, difficulty: 1),
        MicroAction(title: "Warum-Vision", description: "Warum willst du deine Vision erreichen? Auf 3 Sätze reduzieren.", duration: "5 Min", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Kontext-Switch vermeiden", description: "Arbeite in Blöcken, wechsle nicht zwischen Tasks.", duration: "Ganztag", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Abschluss-Ritual", description: "Beende jeden Task komplett bevor du den nächsten startest.", duration: "Ganztag", dimension: .klarheit, difficulty: 2),
        MicroAction(title: "Wichtig vs Urgent", description: "Erkenne: Was ist heute wirklich WICHTIG, nicht nur dringend?", duration: "5 Min", dimension: .klarheit, difficulty: 1),
    ]

    // MARK: - Mut (30 Actions)
    static let mutMicroActions: [MicroAction] = [
        MicroAction(title: "Kaltdusche", description: "3 Minuten kaltes Wasser. Schmerz trainiert Mut.", duration: "3 Min", dimension: .mut, difficulty: 2),
        MicroAction(title: "Einen Fremden ansprechen", description: "Spreche heute eine fremde Person an — ohne Grund.", duration: "5 Min", dimension: .mut, difficulty: 2),
        MicroAction(title: "Angst-Aktion", description: "Tu etwas, das dir leicht Angst macht.", duration: "10 Min", dimension: .mut, difficulty: 3),
        MicroAction(title: "Unbequemes Gespräch", description: "Führe ein Gespräch, das du schon lange vor dir herschiebst.", duration: "15 Min", dimension: .mut, difficulty: 3),
        MicroAction(title: "Veröffentlichen", description: "Teile etwas das du erstellt hast — auch wenn es nicht perfekt ist.", duration: "Moment", dimension: .mut, difficulty: 2),
        MicroAction(title: "Neue Route", description: "Nimm heute eine andere Route als gewohnt.", duration: "Varies", dimension: .mut, difficulty: 1),
        MicroAction(title: "Öffentliches Sprechen", description: "Melde dich in einer Gruppe zu Wort die dich einschüchtert.", duration: "Moment", dimension: .mut, difficulty: 3),
        MicroAction(title: "Ablehnung suchen", description: "Frage nach etwas, bei dem die Antwort wahrscheinlich Nein ist.", duration: "5 Min", dimension: .mut, difficulty: 3),
        MicroAction(title: "Physische Grenze", description: "Sport bis an deine Leistungsgrenze — dann einen weiteren Satz.", duration: "30 Min", dimension: .mut, difficulty: 2),
        MicroAction(title: "Vergeben", description: "Vergib jemandem der dich verletzt hat — auch wenn er nicht fragt.", duration: "5 Min", dimension: .mut, difficulty: 3),
        MicroAction(title: "Startup-Schritt", description: "Mache einen konkreten Schritt zu einem Projekt das du aufgeschoben hast.", duration: "15 Min", dimension: .mut, difficulty: 2),
        MicroAction(title: "Rausgehen aus Komfortzone", description: "Besuche heute einen Ort, den du normalerweise meidest.", duration: "30 Min", dimension: .mut, difficulty: 2),
        MicroAction(title: "Spiegel-Übung", description: "Schau dir 2 Minuten direkt in die Augen im Spiegel.", duration: "2 Min", dimension: .mut, difficulty: 2),
        MicroAction(title: "Meinung vertreten", description: "Stehe für eine Meinung ein, selbst wenn andere widersprechen.", duration: "Moment", dimension: .mut, difficulty: 2),
        MicroAction(title: "Frühmorgens aufstehen", description: "1 Stunde früher aufstehen als nötig. Beginne bewusst.", duration: "Morgen", dimension: .mut, difficulty: 2),
        MicroAction(title: "Body Language Reset", description: "Gehe heute mit breiten Schultern und direktem Blick.", duration: "Ganztag", dimension: .mut, difficulty: 1),
        MicroAction(title: "Kreativität zeigen", description: "Zeige jemandem ein kreatives Werk, das du gemacht hast.", duration: "Moment", dimension: .mut, difficulty: 2),
        MicroAction(title: "Hilfe anbieten", description: "Biete jemandem ungebeten deine Hilfe an.", duration: "10 Min", dimension: .mut, difficulty: 1),
        MicroAction(title: "Fehler zugeben", description: "Gestehe heute einen Fehler ohne Entschuldigungen.", duration: "Moment", dimension: .mut, difficulty: 3),
        MicroAction(title: "Unbekannte Aktivität", description: "Probiere heute etwas aus, das du noch nie getan hast.", duration: "Varies", dimension: .mut, difficulty: 2),
        MicroAction(title: "Stilles Nein", description: "Verlasse eine Situation die dir nicht gut tut — ohne Erklärung.", duration: "Moment", dimension: .mut, difficulty: 3),
        MicroAction(title: "Erste Kontaktaufnahme", description: "Schreibe jemandem dem du schon lange schreiben wolltest.", duration: "5 Min", dimension: .mut, difficulty: 2),
        MicroAction(title: "Fastenperiode", description: "16 Stunden kein Essen. Beweise deinem Geist die Kontrolle.", duration: "16 Stunden", dimension: .mut, difficulty: 2),
        MicroAction(title: "Widerspruch üben", description: "Widersprich respektvoll einer Person, die mehr Macht hat als du.", duration: "Moment", dimension: .mut, difficulty: 3),
        MicroAction(title: "Bitte um Feedback", description: "Frage jemanden: Was ist mein größtes blinder Fleck?", duration: "5 Min", dimension: .mut, difficulty: 2),
        MicroAction(title: "Schritt in die Stille", description: "30 Minuten komplett allein, keine Ablenkung.", duration: "30 Min", dimension: .mut, difficulty: 2),
        MicroAction(title: "Priorität setzen", description: "Sage zu etwas Dringlichem Nein, um etwas Wichtigem Ja zu sagen.", duration: "Moment", dimension: .mut, difficulty: 2),
        MicroAction(title: "Danke sagen", description: "Sage jemandem aufrichtig danke — ins Gesicht.", duration: "Moment", dimension: .mut, difficulty: 1),
        MicroAction(title: "Komfort eliminieren", description: "Identifiziere dein bequemste Gewohnheit und lass sie heute weg.", duration: "Ganztag", dimension: .mut, difficulty: 3),
        MicroAction(title: "Angst benennen", description: "Sprich deine aktuell größte Angst laut aus.", duration: "1 Min", dimension: .mut, difficulty: 2),
    ]

    // MARK: - Verbindung (30 Actions)
    static let verbindungMicroActions: [MicroAction] = [
        MicroAction(title: "Aktives Zuhören", description: "Führe ein Gespräch ohne dein Handy zu berühren. 100% Präsenz.", duration: "15 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Unerwartete Nachricht", description: "Schreibe jemandem eine aufrichtige Nachricht ohne Anlass.", duration: "5 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Tiefen-Frage", description: "Frage jemanden: Was beschäftigt dich gerade wirklich?", duration: "20 Min", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Offline-Zeit", description: "2 Stunden ohne Handy mit einer Person die dir wichtig ist.", duration: "2 Stunden", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Brief schreiben", description: "Schreibe einem Menschen einen handgeschriebenen Brief.", duration: "15 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Gemeinsames Essen", description: "Esse mit jemandem ohne Bildschirm.", duration: "30 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Verbindung reparieren", description: "Melde dich bei jemandem mit dem du seit langem keinen Kontakt hattest.", duration: "10 Min", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Andere priorisieren", description: "Frage heute jemanden: Wie kann ich dir helfen?", duration: "Moment", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Ehrliches Kompliment", description: "Gib heute 3 echte, spezifische Komplimente.", duration: "Ganztag", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Empathie-Übung", description: "Stell dir 5 Min vor, wie sich jemand fühlt, mit dem du Konflikt hast.", duration: "5 Min", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Zuhören ohne Lösen", description: "Höre jemandem zu ohne sofort Rat zu geben.", duration: "15 Min", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Community beitragen", description: "Gebe in einer Community etwas zurück ohne Gegenleistung.", duration: "15 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Qualitätszeit", description: "Plane bewusst Zeit mit einer dir wichtigen Person.", duration: "60 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Öffne dich", description: "Teile mit jemandem etwas, das du normalerweise für dich behältst.", duration: "10 Min", dimension: .verbindung, difficulty: 3),
        MicroAction(title: "Interesse zeigen", description: "Frag jemanden nach seinem Traum und höre wirklich zu.", duration: "15 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Danke-Runde", description: "Sage heute 5 Personen warum du froh bist, sie zu kennen.", duration: "Ganztag", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Verbindungs-Ritual", description: "Erstelle ein tägliches Verbindungsritual: Morgen-Nachricht etc.", duration: "5 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Konflikte ansprechen", description: "Löse einen bestehenden Konflikt der unausgesprochen ist.", duration: "20 Min", dimension: .verbindung, difficulty: 3),
        MicroAction(title: "Gastfreundschaft", description: "Lade jemanden spontan ein.", duration: "60 Min", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Tierisch präsent", description: "Beobachte heute ein Tier. Lerne von seiner Präsenz.", duration: "5 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Natur-Verbindung", description: "30 Min in der Natur ohne Handy.", duration: "30 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Berühren", description: "Umarm heute jemanden länger als 20 Sekunden.", duration: "Moment", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Generosität", description: "Gib heute etwas weg: Zeit, Geld, Wissen.", duration: "Varies", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Tiefes Gespräch", description: "Führe ein Gespräch über mehr als Alltägliches.", duration: "30 Min", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Anerkennung zeigen", description: "Erkenne die Mühe einer Person explizit an.", duration: "Moment", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Stille teilen", description: "Sei still mit jemandem — ohne Erklärung, ohne Füller.", duration: "10 Min", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Kochen für andere", description: "Bereite eine Mahlzeit für jemanden zu.", duration: "30 Min", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Menschlichkeit erkennen", description: "Sieh heute jeden Fremden als jemand mit seiner eigenen Geschichte.", duration: "Ganztag", dimension: .verbindung, difficulty: 1),
        MicroAction(title: "Accountability Partner", description: "Finde jemanden dem du täglich Rechenschaft gibst.", duration: "15 Min", dimension: .verbindung, difficulty: 2),
        MicroAction(title: "Netzwerk wärmen", description: "Melde dich bei 3 Menschen, ohne etwas zu wollen.", duration: "10 Min", dimension: .verbindung, difficulty: 1),
    ]
}
