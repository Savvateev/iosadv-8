import Foundation

// MARK: - Жанры

enum WorkGenre: String, Codable, CaseIterable, Identifiable {
    case novel     = "Роман"
    case novella   = "Повесть"
    case story     = "Рассказ"
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
    let id: String
    let title: String
    let genre: WorkGenre
    let yearFirst: Int?
    let yearsNote: String?
    var cycle: String? = nil
    var awards: [Award] = []
    var note: String? = nil
    var imageName: String? = nil

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
        Adaptation(year: 1981, title: "Звездопад", director: "Игорь Таланкин",
                   workId: "zvezdopad", imageName: "film_zvezdopad"),
        Adaptation(year: 1983, title: "Дважды рождённый", director: "Аркадий Сиренко",
                   note: "Автор сценария — сам Астафьев",
                   imageName: "dvajdyi"),
        Adaptation(year: 1983, title: "Ненаглядный мой", director: "Артур Войтецкий",
                   note: "Автор сценария — сам Астафьев",
                   imageName: "my"),
        Adaptation(year: 1986, title: "Где-то гремит война", director: "Артур Войтецкий",
                   note: "Автор сценария — сам Астафьев. Исходная повесть в базу не входит",
                   imageName: "war"),
    ]
}


// База знаний (только чтение)

struct WorkKnowledgeBase {
    let works: [Work] = Work.seed
    let adaptations: [Adaptation] = Adaptation.seed
    let writer = WriterProfile()

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
}
