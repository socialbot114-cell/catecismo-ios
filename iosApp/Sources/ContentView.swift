import SwiftUI
import UIKit

private enum AppSection: String, CaseIterable, Identifiable {
    case home = "Início"
    case library = "Biblioteca"
    case topics = "Temas"
    case saved = "Minha biblioteca"

    var id: Self { self }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .library: return "books.vertical.fill"
        case .topics: return "square.grid.2x2.fill"
        case .saved: return "bookmark.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedSection = AppSection.home

    var body: some View {
        Group {
            switch library.loadState {
            case .loading:
                VStack(spacing: 14) {
                    ProgressView().controlSize(.large)
                    Text("Preparando sua biblioteca…").font(.headline)
                    Text("Os guias estão sendo carregados para leitura offline.")
                        .font(.subheadline).foregroundStyle(CatecismoTheme.muted)
                }
                .multilineTextAlignment(.center)
                .padding()
            case .failed(let message):
                ContentUnavailableView {
                    Label("Não foi possível abrir a biblioteca", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Tentar novamente", action: library.load).buttonStyle(.borderedProminent)
                }
            case .loaded:
                if horizontalSizeClass == .regular {
                    splitView
                } else {
                    tabView
                }
            }
        }
        .tint(CatecismoTheme.accent)
        .task {
            if library.loadState == .loading { library.load() }
        }
    }

    private var tabView: some View {
        VStack(spacing: 0) {
            destination(for: selectedSection)
            bottomNavigation
        }
        .background(CatecismoTheme.paper.ignoresSafeArea(edges: .bottom))
    }

    private var bottomNavigation: some View {
        HStack(spacing: 6) {
            ForEach(AppSection.allCases) { section in
                let isSelected = selectedSection == section
                Button { selectedSection = section } label: {
                    VStack(spacing: 5) {
                        Image(systemName: section.icon)
                            .font(.system(size: 20, weight: .semibold))
                        Text(section.rawValue)
                            .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(isSelected ? CatecismoTheme.navy : CatecismoTheme.muted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(isSelected ? CatecismoTheme.canvas : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(section.rawValue)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 7)
        .padding(.bottom, 7)
        .background(CatecismoTheme.paper.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle().fill(CatecismoTheme.navy.opacity(0.06)).frame(height: 1)
        }
    }

    private var splitView: some View {
        NavigationSplitView {
            List(selection: Binding<AppSection?>(
                get: { selectedSection },
                set: { if let section = $0 { selectedSection = section } }
            )) {
                ForEach(AppSection.allCases) { section in
                    Label(section.rawValue, systemImage: section.icon).tag(section)
                }
            }
            .scrollContentBackground(.hidden)
            .background(CatecismoTheme.canvas)
            .navigationTitle("Catecismo")
        } detail: {
            destination(for: selectedSection)
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder private func destination(for section: AppSection) -> some View {
        switch section {
        case .home: HomeView()
        case .library: LibraryView()
        case .topics: TopicsView()
        case .saved: MyLibraryView()
        }
    }
}

private struct HomeView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var featuredGuide: Guide? { library.guides.first }
    private var inProgressGuide: Guide? {
        library.guides.first { (library.progress[$0.id] ?? 0) > 0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    hero

                    if let guide = inProgressGuide {
                        SectionHeading(title: "Continue sua leitura", subtitle: "Retome de onde você parou")
                        NavigationLink { GuideDetailView(guide: guide) } label: {
                            GuideCard(guide: guide, detail: true, actionTitle: "Retomar")
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeading(title: "Comece a ler", subtitle: "Guias breves para refletir no seu ritmo")
                        if library.guides.isEmpty {
                            ContentUnavailableView("Nenhum guia disponível", systemImage: "books.vertical")
                        } else {
                            guideGrid(Array(library.guides.prefix(3)))
                        }
                    }

                    DisclosureGroup("Sobre este aplicativo") {
                        Text("Aplicativo independente e não oficial. Reúne guias autorais de introdução; não é o Catecismo completo nem substitui as fontes oficiais.")
                            .font(.footnote)
                            .foregroundStyle(CatecismoTheme.muted)
                            .padding(.top, 8)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CatecismoTheme.navy)
                    .padding(18)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    HStack(spacing: 14) {
                        Image(systemName: "wifi.slash")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(CatecismoTheme.gold)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Sua biblioteca, sempre com você")
                                .font(.subheadline.weight(.semibold))
                            Text("Todo o conteúdo funciona offline.")
                                .font(.footnote).foregroundStyle(CatecismoTheme.muted)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(18)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .frame(maxWidth: 960, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
            }
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .safeAreaPadding(.bottom, 14)
            .navigationTitle("Início")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var hero: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 14) {
                Label("LEITURA E REFLEXÃO", systemImage: "sparkle")
                    .font(.caption.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(CatecismoTheme.gold)

                Text("Catecismo")
                    .font(CatecismoTheme.display(horizontalSizeClass == .regular ? 38 : 32))
                    .foregroundStyle(.white)

                Text("Conheça a fé, um guia por vez.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)

                if let guide = featuredGuide {
                    NavigationLink { GuideDetailView(guide: guide) } label: {
                        Label("Começar leitura", systemImage: "arrow.right")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .background(CatecismoTheme.gold, in: Capsule())
                            .foregroundStyle(CatecismoTheme.navyDeep)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ComponentArtwork(name: "component-book")
                .frame(width: horizontalSizeClass == .regular ? 230 : 142, height: horizontalSizeClass == .regular ? 220 : 180)
                .accessibilityHidden(true)
        }
        .padding(horizontalSizeClass == .regular ? 28 : 18)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: [CatecismoTheme.navy, CatecismoTheme.navyDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(CatecismoTheme.gold.opacity(0.12))
                .frame(width: 170, height: 170)
                .blur(radius: 1)
                .offset(x: 48, y: -62)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: CatecismoTheme.navy.opacity(0.14), radius: 18, x: 0, y: 10)
    }

    @ViewBuilder private func guideGrid(_ guides: [Guide]) -> some View {
        if horizontalSizeClass == .regular {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide) }
                        .buttonStyle(.plain)
                }
            }
        } else {
            VStack(spacing: 12) {
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide) }
                        .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct LibraryView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var query = ""

    private var filtered: [Guide] {
        query.isEmpty ? library.guides : library.guides.filter {
            "\($0.title) \($0.category) \($0.description)".localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Encontre seu próximo guia")
                                .font(CatecismoTheme.display(30))
                                .foregroundStyle(CatecismoTheme.ink)
                            Text("Busque por assunto ou escolha um guia para ler.")
                                .font(.subheadline).foregroundStyle(CatecismoTheme.muted)
                        }
                        Spacer(minLength: 0)
                        ComponentArtwork(name: "component-library")
                            .frame(width: 112, height: 100)
                            .accessibilityHidden(true)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(CatecismoTheme.navy)
                        TextField("Buscar guia ou tema", text: $query)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        if !query.isEmpty {
                            Button { query = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(CatecismoTheme.muted)
                            }
                            .accessibilityLabel("Limpar busca")
                        }
                    }
                    .font(.body)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(CatecismoTheme.paper, in: Capsule())
                    .overlay(Capsule().stroke(CatecismoTheme.navy.opacity(0.08), lineWidth: 1))

                    if filtered.isEmpty {
                        ContentUnavailableView {
                            Label(query.isEmpty ? "Nenhum guia disponível" : "Nenhum resultado", systemImage: query.isEmpty ? "books.vertical" : "magnifyingglass")
                        } description: {
                            Text(query.isEmpty ? "Não há conteúdo para mostrar." : "Tente buscar por outro título ou tema.")
                        }
                        .frame(maxWidth: .infinity, minHeight: 260)
                        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    } else {
                        guideGrid(filtered)
                    }
                }
                .frame(maxWidth: 960, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 12)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .safeAreaPadding(.bottom, 16)
            .navigationTitle("Biblioteca")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder private func guideGrid(_ guides: [Guide]) -> some View {
        if horizontalSizeClass == .regular {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide, detail: true) }
                        .buttonStyle(.plain)
                }
            }
        } else {
            LazyVStack(spacing: 12) {
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide, detail: true) }
                        .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct TopicsView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var categories: [String] { Array(Set(library.guides.map(\.category))).sorted() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeading(title: "Explore por tema", subtitle: "Escolha um caminho para aprofundar")

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: horizontalSizeClass == .regular ? 3 : 2), spacing: 14) {
                        ForEach(categories, id: \.self) { category in
                            let guides = library.guides.filter { $0.category == category }
                            NavigationLink {
                                TopicGuidesView(category: category, guides: guides)
                            } label: {
                                TopicCategoryCard(category: category, guideCount: guides.count)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: 960, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 18)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .safeAreaPadding(.bottom, 16)
            .navigationTitle("Temas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct MyLibraryView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var favoriteGuides: [Guide] { library.guides.filter { library.isFavorite($0.id) } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeading(title: "Minha biblioteca", subtitle: "Seu caminho de leitura, salvo neste aparelho")

                    HStack(spacing: 12) {
                        StatCard(value: "\(library.startedGuideCount)", label: "Guias iniciados", symbol: "book.pages.fill")
                        StatCard(value: "\(library.readingMinutes) min", label: "Tempo de leitura", symbol: "clock.fill")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeading(title: "Favoritos", subtitle: "Guias que você marcou")
                        if favoriteGuides.isEmpty {
                            EmptyStateCard(symbol: "heart", title: "Seus favoritos aparecerão aqui", message: "Toque no coração de um guia para guardá-lo nesta biblioteca.")
                        } else {
                            ForEach(favoriteGuides) { guide in
                                NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeading(title: "Citações", subtitle: "Trechos guardados durante a leitura")
                        if library.quotes.isEmpty {
                            EmptyStateCard(symbol: "quote.opening", title: "Ainda não há citações", message: "Salve um trecho no leitor para encontrá-lo aqui.")
                        } else {
                            ForEach(library.quotes) { quote in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "quote.opening")
                                        .foregroundStyle(CatecismoTheme.gold)
                                    Text("“\(quote.text)”")
                                        .font(.system(.body, design: .serif))
                                        .foregroundStyle(CatecismoTheme.ink)
                                    Spacer(minLength: 0)
                                    Button(role: .destructive) { library.removeQuote(quote) } label: {
                                        Image(systemName: "trash")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .accessibilityLabel("Remover citação")
                                }
                                .padding(18)
                                .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                        }
                    }
                }
                .frame(maxWidth: 960, alignment: .leading)
                .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
                .padding(.top, 18)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .background(CatecismoTheme.canvas.ignoresSafeArea())
            .safeAreaPadding(.bottom, 16)
            .navigationTitle("Minha biblioteca")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct GuideDetailView: View {
    @EnvironmentObject private var library: LibraryViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var speech = SpeechReader()
    @State private var selectedChapter = 0
    let guide: Guide

    private var chapter: Chapter? {
        guard guide.chapters.indices.contains(selectedChapter) else { return nil }
        return guide.chapters[selectedChapter]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                guideHeader

                DisclosureGroup {
                    Text(guide.context)
                        .font(.body)
                        .foregroundStyle(CatecismoTheme.muted)
                        .lineSpacing(4)
                        .padding(.top, 8)
                } label: {
                    Label("Contexto do guia", systemImage: "info.circle")
                        .font(.headline)
                        .foregroundStyle(CatecismoTheme.navy)
                }
                .padding(18)
                .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                if let chapter {
                    reader(chapter)
                } else {
                    ContentUnavailableView {
                        Label("Guia sem capítulos", systemImage: "doc.text.magnifyingglass")
                    } description: {
                        Text("Este guia ainda não tem conteúdo disponível para leitura.")
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                    .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
            }
            .frame(maxWidth: 820, alignment: .leading)
            .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
            .padding(.top, 16)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity)
        }
        .background(CatecismoTheme.canvas.ignoresSafeArea())
        .safeAreaPadding(.bottom, 16)
        .navigationTitle("Leitura")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var guideHeader: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(guide.category.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(CatecismoTheme.gold)
                Text(guide.title)
                    .font(CatecismoTheme.display(30))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(guide.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.84))
                    .fixedSize(horizontal: false, vertical: true)
                Text("GUIA AUTORAL  ·  \(guide.chapterCount) CAPÍTULOS")
                    .font(.caption2.weight(.semibold))
                    .tracking(0.6)
                    .foregroundStyle(.white.opacity(0.64))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let imageName = GuideArtwork.imageName(for: guide.id) {
                ComponentArtwork(name: imageName)
                    .frame(width: horizontalSizeClass == .regular ? 170 : 112, height: horizontalSizeClass == .regular ? 180 : 132)
                    .accessibilityHidden(true)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [CatecismoTheme.navy, CatecismoTheme.navyDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }

    @ViewBuilder private func reader(_ chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CAPÍTULO \(selectedChapter + 1) DE \(guide.chapterCount)")
                        .font(.caption.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(CatecismoTheme.muted)
                    Text(chapter.title)
                        .font(CatecismoTheme.display(25))
                        .foregroundStyle(CatecismoTheme.ink)
                }
                Spacer(minLength: 8)
                Menu {
                    Picker("Capítulo", selection: $selectedChapter) {
                        ForEach(guide.chapters.indices, id: \.self) { index in
                            Text(guide.chapters[index].title).tag(index)
                        }
                    }
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.headline)
                        .frame(width: 42, height: 42)
                        .background(CatecismoTheme.canvas, in: Circle())
                        .foregroundStyle(CatecismoTheme.navy)
                }
                .accessibilityLabel("Escolher capítulo")
            }

            HStack(spacing: 10) {
                Button {
                    speech.isSpeaking ? speech.pause() : speech.isPaused ? speech.resume() : speech.speak(chapter.paragraphs)
                } label: {
                    Label(speech.isSpeaking ? "Pausar" : "Ouvir", systemImage: speech.isSpeaking ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button { library.toggleFavorite(guide.id) } label: {
                    Label(library.isFavorite(guide.id) ? "Salvo" : "Salvar", systemImage: library.isFavorite(guide.id) ? "heart.fill" : "heart")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel(library.isFavorite(guide.id) ? "Remover dos favoritos" : "Adicionar aos favoritos")
            }

            Rectangle().fill(CatecismoTheme.canvas).frame(height: 1)

            if chapter.paragraphs.isEmpty {
                ContentUnavailableView("Capítulo vazio", systemImage: "doc")
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(chapter.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                        HStack(alignment: .top, spacing: 12) {
                            Text(paragraph)
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(CatecismoTheme.ink)
                                .lineSpacing(7)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button { library.addQuote(guideID: guide.id, text: paragraph) } label: {
                                Image(systemName: "quote.opening")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(CatecismoTheme.gold)
                                    .padding(8)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Salvar como citação")
                            .accessibilityHint(String(paragraph.prefix(80)))
                        }
                    }
                }
            }

            Button {
                library.completeChapter(at: selectedChapter, in: guide)
                if selectedChapter + 1 < guide.chapterCount { selectedChapter += 1 }
            } label: {
                Label(selectedChapter + 1 < guide.chapterCount ? "Concluir e avançar" : "Concluir guia", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 4)
        }
        .padding(20)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct SectionHeading: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(CatecismoTheme.display(24))
                .foregroundStyle(CatecismoTheme.ink)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(CatecismoTheme.muted)
            }
        }
    }
}

private struct GuideCard: View {
    @EnvironmentObject private var library: LibraryViewModel
    let guide: Guide
    var detail = false
    var actionTitle: String? = nil

    private var progress: Double { library.progress[guide.id] ?? 0 }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(CatecismoTheme.canvas)
                if let imageName = GuideArtwork.imageName(for: guide.id) {
                    ComponentArtwork(name: imageName).padding(5)
                } else {
                    Image(systemName: "book.closed.fill")
                        .font(.title2)
                        .foregroundStyle(CatecismoTheme.gold)
                }
            }
            .frame(width: 78, height: 84)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(guide.category.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(CatecismoTheme.gold)
                Text(guide.title)
                    .font(.headline)
                    .foregroundStyle(CatecismoTheme.ink)
                    .multilineTextAlignment(.leading)
                Text(detail ? guide.description : guide.category)
                    .font(.subheadline)
                    .foregroundStyle(CatecismoTheme.muted)
                    .lineLimit(detail ? 2 : 1)

                if progress > 0 {
                    ProgressView(value: progress)
                        .tint(CatecismoTheme.navy)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let actionTitle {
                Text(actionTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CatecismoTheme.navy)
            } else {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CatecismoTheme.navy.opacity(0.58))
            }
        }
        .padding(14)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CatecismoTheme.navy.opacity(0.06), lineWidth: 1)
        }
    }
}

private struct TopicCategoryCard: View {
    let category: String
    let guideCount: Int

    private var artwork: String {
        switch category {
        case "Oração": return "component-rosary"
        case "Sacramentos": return "component-dove"
        case "Igreja": return "component-church"
        case "Credo": return "component-cross"
        default: return "component-book"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ComponentArtwork(name: artwork)
                .frame(maxWidth: .infinity)
                .frame(height: 92)
                .padding(.vertical, 6)
                .accessibilityHidden(true)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(category)
                    .font(.headline)
                    .foregroundStyle(CatecismoTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CatecismoTheme.navy.opacity(0.58))
            }
            Text("\(guideCount) \(guideCount == 1 ? "guia" : "guias")")
                .font(.caption)
                .foregroundStyle(CatecismoTheme.muted)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CatecismoTheme.navy.opacity(0.06), lineWidth: 1)
        }
    }
}

private struct TopicGuidesView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let category: String
    let guides: [Guide]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeading(title: category, subtitle: "\(guides.count) \(guides.count == 1 ? "guia" : "guias") para explorar")
                ForEach(guides) { guide in
                    NavigationLink { GuideDetailView(guide: guide) } label: { GuideCard(guide: guide, detail: true) }
                        .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: 820, alignment: .leading)
            .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 18)
            .padding(.top, 18)
            .padding(.bottom, 30)
            .frame(maxWidth: .infinity)
        }
        .background(CatecismoTheme.canvas.ignoresSafeArea())
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StatCard: View {
    let value: String
    let label: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(CatecismoTheme.gold)
            Text(value)
                .font(CatecismoTheme.display(26))
                .foregroundStyle(CatecismoTheme.ink)
            Text(label)
                .font(.caption)
                .foregroundStyle(CatecismoTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct EmptyStateCard: View {
    let symbol: String
    let title: String
    let message: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(CatecismoTheme.gold)
                .frame(width: 44, height: 44)
                .background(CatecismoTheme.canvas, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(CatecismoTheme.ink)
                Text(message).font(.footnote).foregroundStyle(CatecismoTheme.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CatecismoTheme.paper, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct ComponentArtwork: View {
    let name: String

    private var image: UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "Images") else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "book.closed.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(CatecismoTheme.gold)
                    .padding(20)
            }
        }
    }
}

private enum GuideArtwork {
    static func imageName(for guideID: String) -> String? {
        switch guideID {
        case "o-dom-da-fe": return "component-book"
        case "credo-em-caminho": return "component-cross"
        case "sinais-da-graca": return "component-dove"
        case "escola-da-oracao": return "component-rosary"
        case "a-igreja-viva": return "component-church"
        default: return nil
        }
    }
}
