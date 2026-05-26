//
//  StoryDetailView.swift
//  Polskie Czytanki
//

import SwiftUI

struct StoryDetailView: View {
    let story: Story

    @Environment(SettingsStore.self) private var settings
    @Environment(ProgressStore.self) private var progress
    @Environment(AudioPlayer.self) private var audio
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAnswers: [Int: String] = [:]
    @State private var revealed: Bool = false
    @State private var shakeOption: String?
    @State private var showCelebration: Bool = false
    @State private var titleAppeared: Bool = false

    private var allAnswered: Bool {
        story.questions.indices.allSatisfy { selectedAnswers[$0] != nil }
    }

    private var allCorrect: Bool {
        story.questions.enumerated().allSatisfy { index, question in
            selectedAnswers[index] == question.correctAnswer
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.93),
                    Color(red: 0.94, green: 0.96, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    largeImage
                    storyText
                    questions
                    actionFooter
                    Color.clear.frame(height: 24)
                }
                .padding(20)
            }

            if showCelebration {
                CelebrationOverlay {
                    HapticManager.tap()
                    withAnimation(.easeOut(duration: 0.3)) {
                        showCelebration = false
                    }
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale(scale: 1.04)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Story \(story.number)")
                    .font(.appHeadline)
                    .foregroundStyle(.primary)
            }

            if settings.showPlayButton {
                ToolbarItem(placement: .topBarTrailing) {
                    playButton
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                titleAppeared = true
            }
        }
        .onDisappear {
            audio.stop()
        }
    }

    private var playButton: some View {
        let isPlayingThis = audio.isPlaying && audio.currentResource == story.audioFileName
        return Button {
            HapticManager.tap()
            audio.toggle(resourceNamed: story.audioFileName)
        } label: {
            Image(systemName: isPlayingThis ? "stop.circle.fill" : "play.circle.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(AppTheme.primaryGradient)
                .symbolEffect(.bounce, value: isPlayingThis)
        }
        .accessibilityLabel(Text(isPlayingThis ? "Stop audio" : "Play audio"))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tale \(story.number)")
                .font(.appCaption.weight(.heavy))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(story.title)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .opacity(titleAppeared ? 1 : 0)
                .offset(y: titleAppeared ? 0 : 12)
        }
    }

    private var largeImage: some View {
        Image(story.largeImageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: AppTheme.softShadow, radius: 14, y: 8)
    }

    private var storyText: some View {
        Text(story.text)
            .font(.system(size: 17, weight: .regular, design: .rounded))
            .foregroundStyle(.primary)
            .lineSpacing(4)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: AppTheme.softShadow, radius: 10, y: 5)
    }

    private var questions: some View {
        VStack(spacing: 14) {
            ForEach(Array(story.questions.enumerated()), id: \.offset) { index, question in
                QuestionCard(
                    questionNumber: index + 1,
                    totalQuestions: story.questions.count,
                    question: question,
                    selectedOption: binding(for: index),
                    revealed: revealed,
                    shakingOption: shakeOption
                )
            }
        }
    }

    private var actionFooter: some View {
        VStack(spacing: 12) {
            if revealed && !allCorrect {
                Text("Some answers are not right. Try again!")
                    .font(.appCaption)
                    .foregroundStyle(Color(red: 0.66, green: 0.15, blue: 0.22))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(Color(red: 0.96, green: 0.42, blue: 0.42).opacity(0.18))
                    )
            }

            PrimaryButton(
                revealed && !allCorrect ? "Try again" : "Check answers",
                systemImage: revealed && !allCorrect ? "arrow.counterclockwise" : "checkmark.seal.fill",
                gradient: revealed && !allCorrect ? AppTheme.secondaryGradient : AppTheme.primaryGradient
            ) {
                handleCheck()
            }
            .disabled(!allAnswered && !revealed)
            .opacity(allAnswered || revealed ? 1.0 : 0.55)
        }
        .padding(.top, 8)
    }

    private func binding(for index: Int) -> Binding<String?> {
        Binding(
            get: { selectedAnswers[index] },
            set: { newValue in
                guard !revealed else { return }
                selectedAnswers[index] = newValue
            }
        )
    }

    private func handleCheck() {
        if revealed && !allCorrect {
            revealed = false
            for (index, question) in story.questions.enumerated() {
                if selectedAnswers[index] != question.correctAnswer {
                    selectedAnswers.removeValue(forKey: index)
                }
            }
            return
        }

        guard allAnswered else { return }
        revealed = true

        if allCorrect {
            progress.markCompleted(story.id)
            audio.stop()
            audio.play(resourceNamed: "goodresult")
            HapticManager.celebrate()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCelebration = true
            }
        } else {
            HapticManager.error()
            if let wrong = firstWrongOption() {
                shakeOption = wrong
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    shakeOption = nil
                }
            }
        }
    }

    private func firstWrongOption() -> String? {
        for (index, question) in story.questions.enumerated() {
            if let answer = selectedAnswers[index], answer != question.correctAnswer {
                return answer
            }
        }
        return nil
    }
}

#Preview {
    NavigationStack {
        StoryDetailView(story: Story(
            id: "pl1",
            title: "Zaczarowany Ogród Lili",
            text: "Lila uwielbiała spędzać czas w ogrodzie swojej babci...",
            questions: [
                Question(
                    question: "Gdzie Lila znalazła kluczyk?",
                    options: ["Pod jabłonią", "Pod różą", "W studni", "W szafce"],
                    correctAnswer: "Pod różą"
                )
            ]
        ))
        .environment(SettingsStore())
        .environment(ProgressStore())
        .environment(AudioPlayer())
    }
}
