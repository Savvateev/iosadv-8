import SwiftUI

struct InfoView: View {
    
    private let kb = WorkKnowledgeBase()
    
    @State private var query = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(WorkGenre.allCases) { genre in
                    let items = filtered(kb.works(in: genre))
                    if !items.isEmpty {
                        Section(genre.rawValue) {
                            ForEach(items) { work in
                                NavigationLink {
                                    InfoDetails(work: work,
                                                adaptations: kb.adaptations(for: work.id))
                                } label: {
                                    InfoRow(work: work)
                                }
                            }
                        }
                    }
                }

                // Экранизации — в самом низу списка
                let films = filteredAdaptations(kb.adaptations)
                if !films.isEmpty {
                    Section("Экранизации") {
                        ForEach(films, id: \.self) { film in
                            AdaptationRow(film: film)
                        }
                    }
                }
            }
            .navigationTitle("В. П. Астафьев")
            .searchable(text: $query, prompt: "Поиск по названию")
        }
    }

    private func filtered(_ works: [Work]) -> [Work] {
        guard !query.isEmpty else { return works }
        return works.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private func filteredAdaptations(_ films: [Adaptation]) -> [Adaptation] {
        guard !query.isEmpty else { return films }
        return films.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
}

struct AdaptationRow: View {
    let film: Adaptation

    var body: some View {
        HStack(spacing: 12) {
            Image(film.resolvedImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 4) {
                Text(film.title)
                    .font(.headline)
                Text("\(film.year), реж. \(film.director)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
