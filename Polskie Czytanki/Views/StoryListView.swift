//
//  StoryListView.swift
//  Polskie Czytanki
//

import SwiftUI

struct StoryListView: View {
    @Environment(StoryRepository.self) private var repository
    @Environment(ProgressStore.self) private var progress
    @Binding var path: NavigationPath
    @State private var searchText: String = ""

    private var filteredStories: [Story] {
        guard !searchText.isEmpty else { return repository.stories }
        return repository.stories.filter { story in
            story.title.localizedCaseInsensitiveContains(searchText) ||
            String(story.number).contains(searchText)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.95, blue: 0.84),
                    Color(red: 1.00, green: 0.88, blue: 0.92),
                    Color(red: 0.88, green: 0.92, blue: 1.00)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 14) {
                    progressHeader
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    ForEach(filteredStories) { story in
                        Button {
                            HapticManager.tap()
                            path.append(AppRoute.story(story))
                        } label: {
                            StoryRowView(story: story, isCompleted: progress.isCompleted(story.id))
                        }
                        .buttonStyle(BouncyButtonStyle())
                        .padding(.horizontal, 16)
                    }

                    Color.clear.frame(height: 24)
                }
            }
        }
        .navigationTitle(Text("Czytanki"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 1.00, green: 0.95, blue: 0.84), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .searchable(text: $searchText, prompt: Text("Szukaj czytanek"))
    }

    private var progressHeader: some View {
        let total = repository.stories.count
        let done = progress.completedCount
        let ratio: Double = total == 0 ? 0 : Double(done) / Double(total)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.primaryGradient)
                    Text("Twój postęp")
                        .font(.appHeadline)
                        .foregroundStyle(.primary)
                }
                Spacer()
                Text("\(done) / \(total)")
                    .font(.appCaption.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(AppTheme.primaryGradient, in: Capsule())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.18))
                    Capsule()
                        .fill(AppTheme.successGradient)
                        .frame(width: max(12, geo.size.width * ratio))
                }
            }
            .frame(height: 12)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 6)
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    return NavigationStack(path: $path) {
        StoryListView(path: $path)
            .environment(StoryRepository())
            .environment(ProgressStore())
            .environment(SettingsStore())
            .environment(AudioPlayer())
    }
}
