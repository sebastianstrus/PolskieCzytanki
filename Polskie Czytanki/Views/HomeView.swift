//
//  HomeView.swift
//  Polskie Czytanki
//

import SwiftUI

struct HomeView: View {
    @Environment(StoryRepository.self) private var repository
    @Environment(ProgressStore.self) private var progress
    @Environment(SettingsStore.self) private var settings
    @Environment(AudioPlayer.self) private var audio

    @State private var navigateToStories = false
    @State private var navigateToSettings = false
    @State private var titleAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundVideoView(resourceName: "background_video", fileExtension: "mp4")
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.55),
                        Color.black.opacity(0.15),
                        Color.black.opacity(0.65)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                    Spacer()

                    titleBlock
                        .padding(.bottom, 40)

                    actionButtons
                        .padding(.horizontal, 32)
                        .padding(.bottom, 60)
                }
            }
            .navigationDestination(isPresented: $navigateToStories) {
                StoryListView()
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.9, dampingFraction: 0.75).delay(0.1)) {
                    titleAppeared = true
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                HapticManager.tap()
                navigateToSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                    .shadow(color: AppTheme.softShadow, radius: 8, y: 4)
            }
            .accessibilityLabel(Text("Settings"))
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 14) {
            Image(systemName: "book.pages.fill")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
                .scaleEffect(titleAppeared ? 1.0 : 0.6)
                .opacity(titleAppeared ? 1.0 : 0)

            Text("Polskie Czytanki")
                .font(.appTitle)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.45), radius: 10, y: 4)
                .multilineTextAlignment(.center)
                .scaleEffect(titleAppeared ? 1.0 : 0.85)
                .opacity(titleAppeared ? 1.0 : 0)

            Text("Discover the joy of reading.")
                .font(.appSubtitle)
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.45), radius: 6, y: 2)
                .multilineTextAlignment(.center)
                .opacity(titleAppeared ? 1.0 : 0)
        }
        .padding(.horizontal, 24)
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                "Discover Tales",
                systemImage: "books.vertical.fill"
            ) {
                navigateToStories = true
            }

            if progress.completedCount > 0 {
                Text("Completed: \(progress.completedCount) / \(repository.stories.count)")
                    .font(.appCaption)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(StoryRepository())
        .environment(ProgressStore())
        .environment(SettingsStore())
        .environment(AudioPlayer())
}
