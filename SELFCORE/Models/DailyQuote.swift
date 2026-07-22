// Models/DailyQuote.swift — Feature 6: Tagesquote nach SELFCORE-Typ
import Foundation

struct DailyQuote: Identifiable {
    var id = UUID()
    var text: String
    var author: String
    var forType: SelfcoreType?  // nil = universal

    // Returns today's quote for the given type (deterministic by day-of-year)
    static func todayFor(_ type: SelfcoreType) -> DailyQuote {
        let allQuotes = quotes(for: type) + universalQuotes
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % allQuotes.count
        return allQuotes[index]
    }

    static func quotes(for type: SelfcoreType) -> [DailyQuote] {
        switch type {
        case .pioneer:   return pioneerQuotes
        case .guardian:  return guardianQuotes
        case .creator:   return creatorQuotes
        case .connector: return connectorQuotes
        case .achiever:  return achieverQuotes
        }
    }

    static let universalQuotes: [DailyQuote] = [
        DailyQuote(text: "Der einzige Weg, große Arbeit zu leisten, ist, das zu lieben, was du tust.", author: "Steve Jobs"),
        DailyQuote(text: "Du wirst nicht, was du sein willst. Du wirst, was du täglich tust.", author: "GEN:SELFCORE"),
        DailyQuote(text: "Komfort ist der Feind von Wachstum.", author: "Benjamin Franklin"),
        DailyQuote(text: "Deine Identität entsteht durch deine Gewohnheiten.", author: "James Clear"),
        DailyQuote(text: "Es ist nie zu spät, das zu werden, was du hättest sein können.", author: "George Eliot"),
        DailyQuote(text: "Der härteste Kampf ist der, der gegen dein altes Ich.", author: "GEN:SELFCORE"),
        DailyQuote(text: "Wachstum ist schmerzhaft. Stillstand ist schmerzhafter.", author: "Unknown"),
        DailyQuote(text: "Deine Überzeugungen werden zu Gedanken, Gedanken zu Worten, Worte zu Taten.", author: "Mahatma Gandhi"),
    ]

    static let pioneerQuotes: [DailyQuote] = [
        DailyQuote(text: "Der mutige Mensch ist nicht der, der keine Angst kennt, sondern der, der trotz Angst handelt.", author: "Nelson Mandela", forType: .pioneer),
        DailyQuote(text: "Das Risiko nichts zu riskieren ist das größte Risiko überhaupt.", author: "Leo Buscaglia", forType: .pioneer),
        DailyQuote(text: "Sicherheit existiert nicht in der Natur. Das Leben ist entweder ein kühnes Abenteuer oder gar nichts.", author: "Helen Keller", forType: .pioneer),
        DailyQuote(text: "Gehe dahin, wo du Angst hast — dort wartet dein Leben.", author: "GEN:SELFCORE", forType: .pioneer),
        DailyQuote(text: "Entdecke neue Kontinente, ohne die Küste aus den Augen zu verlieren.", author: "André Gide", forType: .pioneer),
        DailyQuote(text: "Pioniere sterben nicht. Sie öffnen nur Türen für andere.", author: "GEN:SELFCORE", forType: .pioneer),
    ]

    static let guardianQuotes: [DailyQuote] = [
        DailyQuote(text: "Grenzen sind kein Zeichen von Schwäche, sondern von Weisheit.", author: "GEN:SELFCORE", forType: .guardian),
        DailyQuote(text: "Der stärkste Mensch ist der, der seine eigenen Grenzen kennt.", author: "Konfuzius", forType: .guardian),
        DailyQuote(text: "Schutz beginnt beim Schutz deiner eigenen Energie.", author: "GEN:SELFCORE", forType: .guardian),
        DailyQuote(text: "Was du schützt, wird größer. Was du vernachlässigst, stirbt.", author: "Unknown", forType: .guardian),
        DailyQuote(text: "Die ruhige See macht keinen erfahrenen Seemann.", author: "Afrikanisches Sprichwort", forType: .guardian),
        DailyQuote(text: "Deine Ruhe ist deine Superkraft.", author: "GEN:SELFCORE", forType: .guardian),
    ]

    static let creatorQuotes: [DailyQuote] = [
        DailyQuote(text: "Kreativität ist Intelligenz beim Spielen.", author: "Albert Einstein", forType: .creator),
        DailyQuote(text: "Der leere Raum ist kein Problem — er ist Möglichkeit.", author: "GEN:SELFCORE", forType: .creator),
        DailyQuote(text: "Kunst ist Freiheit. Und Freiheit ist Verantwortung.", author: "GEN:SELFCORE", forType: .creator),
        DailyQuote(text: "Das Einzige Schlimmere als blind zu sein, ist Augen zu haben und trotzdem keine Vision.", author: "Helen Keller", forType: .creator),
        DailyQuote(text: "Erschaffe, was du vermisst. Die Welt braucht es.", author: "GEN:SELFCORE", forType: .creator),
        DailyQuote(text: "Du bist der Künstler deines Lebens. Male kein schlechtes Bild.", author: "Paulo Coelho", forType: .creator),
    ]

    static let connectorQuotes: [DailyQuote] = [
        DailyQuote(text: "Der einzige Weg Freundschaft zu haben ist, selbst einer zu sein.", author: "Ralph Waldo Emerson", forType: .connector),
        DailyQuote(text: "Verbindung ist der Grund für unser Dasein.", author: "Brené Brown", forType: .connector),
        DailyQuote(text: "Einzeln sind wir ein Tropfen. Gemeinsam ein Ozean.", author: "Ryunosuke Satoro", forType: .connector),
        DailyQuote(text: "Deine Energie überträgt sich. Wähle weise, was du trägst.", author: "GEN:SELFCORE", forType: .connector),
        DailyQuote(text: "Tiefe Gespräche sind das echte Luxusgut.", author: "GEN:SELFCORE", forType: .connector),
        DailyQuote(text: "Empathie ist nicht Schwäche. Es ist deine größte Stärke.", author: "GEN:SELFCORE", forType: .connector),
    ]

    static let achieverQuotes: [DailyQuote] = [
        DailyQuote(text: "Erfolg ist kein Zufall. Er ist harte Arbeit, Ausdauer, Lernen, Opfer und Liebe zu dem, was du tust.", author: "Pelé", forType: .achiever),
        DailyQuote(text: "Es sind nicht die Berge, die uns erschöpfen, sondern der kleine Stein im Schuh.", author: "Muhammad Ali", forType: .achiever),
        DailyQuote(text: "Der Unterschied zwischen ordinary und extraordinary ist das kleine extra.", author: "Jimmy Johnson", forType: .achiever),
        DailyQuote(text: "Gewinnen ist ein Gewohnheit. Leider ist Verlieren es auch.", author: "Vince Lombardi", forType: .achiever),
        DailyQuote(text: "Disziplin ist der Preis der Freiheit.", author: "Jocko Willink", forType: .achiever),
        DailyQuote(text: "Der einzige Ort wo Erfolg vor Arbeit kommt, ist im Wörterbuch.", author: "Vidal Sassoon", forType: .achiever),
    ]
}
