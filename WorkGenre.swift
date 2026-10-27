import Foundation
import Combine
import SwiftUI

// MARK: - Жанры

enum WorkGenre: String, Codable, CaseIterable, Identifiable {
    case novel     = "Роман"
    case novella   = "Повесть"
    case story     = "Рассказ"
    case pastoral  = "Современная пастораль"
    case play      = "Пьеса"

    var id: String { rawValue }
}

// MARK: - Модели

struct Award: Codable, Hashable {
    let name: String
    let year: Int
    var posthumous: Bool = false
}

struct Work: Codable, Identifiable, Hashable {
    let id: String                 // латиница, slug: "tsar-ryba"
    let title: String
    let genre: WorkGenre
    let yearFirst: Int?            // первый год из источника
    let yearsNote: String?         // как в источнике: "1968—1993"
    var cycle: String? = nil       // цикл, если есть
    var awards: [Award] = []
    var note: String? = nil        // пометки о происхождении данных
    var imageName: String? = nil   // одна обложка, имя в Assets.xcassets

    /// Имя ассета: из imageName, иначе по соглашению "work_<id>"
    var resolvedImageName: String { imageName ?? "work_\(id)" }
}

struct Adaptation: Codable, Hashable {
    let year: Int
    let title: String
    let director: String
    var workId: String? = nil      // ссылка на Work.id, если произведение есть в базе
    var note: String? = nil
    var imageName: String? = nil   // один постер или кадр

    /// Имя ассета: из imageName, иначе "film_<год>"
    var resolvedImageName: String { imageName ?? "film_\(year)" }
}

struct WriterProfile: Codable, Hashable {
    var fullName: String = "Виктор Петрович Астафьев"
    var birth: String = "1 мая 1924, Овсянка"
    var death: String = "29 ноября 2001, Красноярск"
    var portraitName: String? = "writer_portrait"
}

// MARK: - Данные (источник: ru.wikipedia.org, Астафьев, Виктор Петрович)

extension Work {
    static let seed: [Work] = [
        // Романы
        Work(id: "tayut-snega", title: "Тают снега", genre: .novel,
             yearFirst: 1958, yearsNote: "1958",
             imageName: "taut_snega"),

        Work(id: "pechalnyy-detektiv", title: "Печальный детектив", genre: .novel,
             yearFirst: 1986, yearsNote: "1986",
             imageName: "pechalniy_detectiv"),

        Work(id: "prokliaty-i-ubity", title: "Прокляты и убиты", genre: .novel,
             yearFirst: 1995, yearsNote: "1995",
             awards: [Award(name: "Государственная премия РФ", year: 1995)],
             note: "Кн. 1 «Чёртова яма», кн. 2 «Плацдарм»",
             imageName: "prokl_ubit"),

        // Повести
        Work(id: "pereval", title: "Перевал", genre: .novella,
             yearFirst: 1958, yearsNote: "1958",
             awards: [Award(name: "Государственная премия РСФСР им. М. Горького", year: 1975)],
             imageName: "pereval"),

        Work(id: "starodub", title: "Стародуб", genre: .novella,
             yearFirst: 1960, yearsNote: "1960",
             imageName: "starodub"),

        Work(id: "zvezdopad", title: "Звездопад", genre: .novella,
             yearFirst: 1960, yearsNote: "1960—1973",
             imageName: "zvezdopad"),

        Work(id: "krazha", title: "Кража", genre: .novella,
             yearFirst: 1966, yearsNote: "1966",
             awards: [Award(name: "Государственная премия РСФСР им. М. Горького", year: 1975)],
             imageName: "kraja"),

        // Пьесы
        Work(id: "prosti-menya", title: "Прости меня", genre: .play,
             yearFirst: 1980, yearsNote: "1980",
             imageName: "prosti_menya"),

        // Рассказы
        Work(id: "angel-hranitel", title: "Ангел-хранитель", genre: .story,
             yearFirst: nil, yearsNote: nil,
             imageName: "arhangel"),
    ]
}


extension Adaptation {
    static let seed: [Adaptation] = [
        Adaptation(year: 1977, title: "Сюда не залетали чайки", director: "Булат Мансуров",
                   imageName: "chaiki"),
        Adaptation(year: 1979, title: "Таёжная повесть", director: "Владимир Фетин",
                   imageName: "tayga"),
        Adaptation(year: 1983, title: "Дважды рождённый", director: "Аркадий Сиренко",
                   note: "Автор сценария — сам Астафьев",
                   imageName: "dvajdyi"),
        Adaptation(year: 1983, title: "Ненаглядный мой", director: "Артур Войтецкий",
                   note: "Автор сценария — сам Астафьев",
                   imageName: "my"),
        Adaptation(year: 1986, title: "Где-то гремит война", director: "Артур Войтецкий",
                   note: "Автор сценария — сам Астафьев. Повесть «Где-то гремит война» в эту базу не входит",
                   imageName: "war"),
    ]
}

// MARK: - Хранилище

final class WorkKnowledgeBase: ObservableObject {
    @Published private(set) var works: [Work]
    @Published private(set) var adaptations: [Adaptation]
    @Published private(set) var writer: WriterProfile

    private let fileURL: URL

    init(fileName: String = "astafyev_kb.json") {
        self.fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        self.works = Work.seed
        self.adaptations = Adaptation.seed
        self.writer = WriterProfile()
        load()
    }

    // MARK: Выборки

    func works(in genre: WorkGenre) -> [Work] {
        works.filter { $0.genre == genre }
             .sorted { ($0.yearFirst ?? .max) < ($1.yearFirst ?? .max) }
    }

    func search(_ query: String) -> [Work] {
        guard !query.isEmpty else { return works }
        return works.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    func work(id: String) -> Work? {
        works.first { $0.id == id }
    }

    func adaptations(for workId: String) -> [Adaptation] {
        adaptations.filter { $0.workId == workId }
    }

    // MARK: Изменения

    func add(_ work: Work) {
        works.append(work)
        save()
    }

    func update(_ work: Work) {
        guard let i = works.firstIndex(where: { $0.id == work.id }) else { return }
        works[i] = work
        save()
    }

    func remove(id: String) {
        works.removeAll { $0.id == id }
        save()
    }

    func setImage(_ name: String?, forWork id: String) {
        guard let i = works.firstIndex(where: { $0.id == id }) else { return }
        works[i].imageName = name
        save()
    }

    func setImage(_ name: String?, forAdaptation index: Int) {
        guard adaptations.indices.contains(index) else { return }
        adaptations[index].imageName = name
        save()
    }

    // MARK: Сохранение в JSON

    private struct Payload: Codable {
        let works: [Work]
        let adaptations: [Adaptation]
        var writer: WriterProfile?
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(
                Payload(works: works, adaptations: adaptations, writer: writer)
            )
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Save error: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else { return }
        works = payload.works
        adaptations = payload.adaptations
        writer = payload.writer ?? WriterProfile()
    }
}
