//
//  StoryListView.swift
//  Polskie Czytanki
//

import SwiftUI

struct StoryListView: View {
    @Environment(StoryRepository.self) private var repository
    @Environment(ProgressStore.self) private var progress
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
                    Color(red: 1.0, green: 0.96, blue: 0.91),
                    Color(red: 0.95, green: 0.92, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 12) {
                    progressHeader
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    ForEach(filteredStories) { story in
                        NavigationLink(value: story) {
                            StoryRowView(story: story, isCompleted: progress.isCompleted(story.id))
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded {
                            HapticManager.tap()
                        })
                        .padding(.horizontal, 16)
                    }

                    Color.clear.frame(height: 24)
                }
            }
        }
        .navigationTitle(Text("Tales"))
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: Text("Search tales"))
        .navigationDestination(for: Story.self) { story in
            StoryDetailView(story: story)
        }
    }

    private var progressHeader: some View {
        let total = repository.stories.count
        let done = progress.completedCount
        let ratio: Double = total == 0 ? 0 : Double(done) / Double(total)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Your progress")
                    .font(.appHeadline)
                Spacer()
                Text("\(done) / \(total)")
                    .font(.appCaption.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.18))
                    Capsule()
                        .fill(AppTheme.successGradient)
                        .frame(width: max(8, geo.size.width * ratio))
                }
            }
            .frame(height: 10)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: AppTheme.softShadow, radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationStack {
        StoryListView()
            .environment(StoryRepository())
            .environment(ProgressStore())
            .environment(SettingsStore())
            .environment(AudioPlayer())
    }
}
