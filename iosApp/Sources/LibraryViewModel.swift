import Foundation

struct WorkSummary: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let description: String
}

final class LibraryViewModel: ObservableObject {
    @Published var works: [WorkSummary] = [
        WorkSummary(id: "dom", title: "Dom Casmurro", category: "romance", description: "A memória de Bentinho, entre lembranças, dúvidas e silêncio."),
        WorkSummary(id: "brascubas", title: "Memórias Póstumas de Brás Cubas", category: "romance", description: "Um defunto autor revisita a própria vida com ironia e liberdade."),
        WorkSummary(id: "quincas", title: "Quincas Borba", category: "romance", description: "Fortuna, amizade e a filosofia do Humanitismo em uma história mordaz.")
    ]
    @Published var progress: [String: Double] = [:]

    var readingMinutes: Int { 0 }
}
