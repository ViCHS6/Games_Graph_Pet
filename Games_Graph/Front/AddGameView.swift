import SwiftUI
import UniformTypeIdentifiers


// Форма ввода. Одна и та же вьюха работает в двух режимах:
// gameToEdit == nil  -> добавляем новую игру
// gameToEdit != nil  -> редактируем существующую
struct AddGameView: View {

    // GameStore — class, поэтому сюда попадает ссылка на тот же объект, что и в ContentView,
    // а не его копия. Изменения увидят обе вьюхи.
    var store: GameStore
    var gameToEdit: Game?

    // Действие "закрыть это модальное окно", которое даёт сама система.
    @Environment(\.dismiss) private var dismiss

    // Поля формы. Все текстовые, потому что TextField умеет работать только со String —
    // year и hoursPlayed превращаются в Int уже при сохранении.
    // Эти три без "= ..." — их начальные значения задаёт init ниже.
    @State private var title: String
    @State private var yearText: String
    @State private var genresText: String
    @State private var tagsText: String = ""
    @State private var developer: String = ""
    @State private var publisher: String = ""
    @State private var franchise: String = ""
    @State private var hoursPlayedText: String = ""
    @State private var status: Game.GameStatus = .completed

    // Состояние выбора обложки: показывать ли диалог и что в нём выбрали.
    @State private var isPickingCover: Bool = false
    @State private var coverURL: URL?

    var body: some View{
        Form {

            // $ перед именем — биндинг: поле не только показывает текст, но и пишет в переменную.
            // Звёздочкой помечены поля, обязательные в модели Game.
            TextField("Title *", text: $title)
            TextField("Year *", text: $yearText)
            TextField("Genres * ( , sep )", text: $genresText)

            TextField("Developer", text: $developer)
            TextField("Publisher", text: $publisher)
            TextField("Franchise", text: $franchise)
            TextField("Tags (, sep)", text: $tagsText)
            TextField("Hours played", text: $hoursPlayedText)

            // allCases даёт список всех вариантов enum — их и перебираем строками списка.
            Picker("Status", selection: $status) {
                ForEach(Game.GameStatus.allCases, id: \.self) { status in
                    Text(String(describing: status))
                }
            }

            Button("Choose game cover") {
                isPickingCover = true
            }
        }

        // Системный диалог выбора файла, только картинки.
        .fileImporter(isPresented: $isPickingCover, allowedContentTypes: [.image]) { result in
            // Result — либо успех с URL, либо ошибка. switch разбирает оба случая.
            switch result {
            case .success(let url):
                coverURL = url
            case .failure(let error):
                print("Failed: \(error)")
            }
        }
        // Показывает имя выбранного файла, пока обложка ещё не сохранена.
        Text(coverURL?.lastPathComponent ?? "no cover")

        Button("Save") {
            saveGame()
        }
    }

    // Свой init нужен, чтобы заполнить поля данными редактируемой игры.
    // gameToEdit со значением по умолчанию nil — поэтому AddGameView(store:) без второго
    // аргумента тоже работает (это режим добавления).
    init(store: GameStore, gameToEdit: Game? = nil) {
        self.store = store
        self.gameToEdit = gameToEdit
        // _title — настоящее хранилище под обёрткой @State. Только через него можно
        // задать стартовое значение из init.
        _title = State(initialValue: gameToEdit?.title ?? "")
        // .map у Optional: есть игра — берём год и делаем строку; нет — остаётся nil и сработает ?? ""
        _yearText = State(initialValue: gameToEdit.map { String($0.year ) } ?? "" )
        // joined — обратная split: массив жанров склеиваем в строку через запятую.
        _genresText = State(initialValue: gameToEdit?.genres.joined(separator: ", ") ?? "" )

        _developer = State(initialValue: gameToEdit?.developer ?? "")
        _publisher = State(initialValue: gameToEdit?.publisher ?? "")
        _franchise = State(initialValue: gameToEdit?.franchise ?? "")
        _tagsText = State(initialValue: gameToEdit?.tags?.joined(separator: ", ") ?? "")
        _hoursPlayedText = State(initialValue: gameToEdit?.hoursPlayed.map { String($0) } ?? "")

    }

    // Собирает Game из полей формы и отдаёт его в store.
    func saveGame() {
        // "Action, Open-World" -> ["Action", "Open-World"] (с обрезкой пробелов по краям).
        let genres = genresText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces)}
        // При редактировании оставляем прежний id, при добавлении генерируем новый.
        // id нужен заранее — по нему называется файл обложки.
        let gameID = gameToEdit?.id ?? UUID()

        // По умолчанию оставляем старую обложку; если выбрали новую — копируем её и берём новое имя.
        var coverFileName = gameToEdit?.coverFile
        if let coverURL{
            coverFileName = store.saveCover(from: coverURL, for: gameID)
        }

        // Порядок аргументов должен совпадать с порядком полей в struct Game.
        let newGame = Game(
            id: gameID,
            title: title,
            year: Int(yearText) ?? 0,
            genres: genres,
            status: status,
            coverFile: coverFileName,

            // "пусто ? nil : значение" — не записываем пустые строки в Optional-поля.
            developer: developer.isEmpty ? nil : developer,
            publisher: publisher.isEmpty ? nil : publisher,
            franchise: franchise.isEmpty ? nil : franchise,
            tags: tagsText.isEmpty ? nil : tagsText.split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces) },
            // Int("") сам даёт nil — отдельная проверка на пустоту не нужна.
            hoursPlayed: Int(hoursPlayedText)

            )
        // Игра с таким id уже есть — заменяем её на месте; нет — добавляем в конец.
        if let gameToEdit, let index = store.games.firstIndex(where: { $0.id == gameToEdit.id }) {
            store.games[index] = newGame
        } else {
            store.games.append(newGame)
        }
        store.save()    // записываем на диск
        dismiss()       // закрываем окно формы
    }
}
