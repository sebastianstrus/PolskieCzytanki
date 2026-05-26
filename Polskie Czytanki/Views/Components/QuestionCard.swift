//
//  QuestionCard.swift
//  Polskie Czytanki
//

import SwiftUI

struct QuestionCard: View {
    let questionNumber: Int
    let totalQuestions: Int
    let question: Question

    @Binding var selectedOption: String?
    let revealed: Bool
    let shakingOption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                Text("\(questionNumber)")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.secondaryGradient, in: Circle())

                Text("Question \(questionNumber) of \(totalQuestions)")
                    .font(.appCaption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }

            Text(question.question)
                .font(.appHeadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(Array(question.options.enumerated()), id: \.element) { index, option in
                    OptionButton(
                        letter: letter(at: index),
                        text: option,
                        state: state(for: option),
                        shake: shakingOption == option
                    ) {
                        guard !revealed else { return }
                        selectedOption = option
                        HapticManager.selection()
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 6)
    }

    private func letter(at index: Int) -> String {
        let scalars: [String] = ["A", "B", "C", "D", "E", "F"]
        return scalars[safe: index] ?? "?"
    }

    private func state(for option: String) -> OptionButton.OptionState {
        if revealed {
            if option == question.correctAnswer { return .correct }
            if option == selectedOption { return .incorrect }
            return .neutral
        }
        if selectedOption == option { return .selected }
        return .neutral
    }
}

struct OptionButton: View {
    enum OptionState {
        case neutral, selected, correct, incorrect
    }

    let letter: String
    let text: String
    let state: OptionState
    let shake: Bool
    let action: () -> Void

    @State private var shakeProgress: CGFloat = 0

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(badgeForeground)
                    .frame(width: 32, height: 32)
                    .background(badgeBackground, in: Circle())

                Text(text)
                    .font(.appBody.weight(.semibold))
                    .foregroundStyle(textForeground)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(red: 0.10, green: 0.62, blue: 0.45))
                } else if state == .incorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(red: 0.86, green: 0.20, blue: 0.30))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(BouncyButtonStyle())
        .modifier(ShakeEffect(animatableData: shakeProgress))
        .onChange(of: shake) { _, newValue in
            guard newValue else { return }
            withAnimation(.linear(duration: 0.45)) {
                shakeProgress += 1
            }
        }
    }

    private var cardBackground: Color {
        switch state {
        case .neutral: return Color(.secondarySystemBackground)
        case .selected: return Color(red: 0.40, green: 0.69, blue: 0.97).opacity(0.18)
        case .correct: return Color(red: 0.31, green: 0.81, blue: 0.55).opacity(0.18)
        case .incorrect: return Color(red: 0.96, green: 0.42, blue: 0.42).opacity(0.18)
        }
    }

    private var borderColor: Color {
        switch state {
        case .neutral: return Color.clear
        case .selected: return Color(red: 0.40, green: 0.69, blue: 0.97)
        case .correct: return Color(red: 0.10, green: 0.62, blue: 0.45)
        case .incorrect: return Color(red: 0.86, green: 0.20, blue: 0.30)
        }
    }

    private var borderWidth: CGFloat {
        switch state {
        case .neutral: return 0
        default: return 2
        }
    }

    private var badgeBackground: AnyShapeStyle {
        switch state {
        case .neutral: return AnyShapeStyle(Color.secondary.opacity(0.15))
        case .selected: return AnyShapeStyle(AppTheme.secondaryGradient)
        case .correct: return AnyShapeStyle(AppTheme.successGradient)
        case .incorrect: return AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.42, blue: 0.42),
                    Color(red: 0.86, green: 0.20, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        }
    }

    private var badgeForeground: Color {
        switch state {
        case .neutral: return .secondary
        default: return .white
        }
    }

    private var textForeground: Color {
        switch state {
        case .neutral: return .primary
        case .selected: return .primary
        case .correct: return Color(red: 0.06, green: 0.45, blue: 0.32)
        case .incorrect: return Color(red: 0.66, green: 0.15, blue: 0.22)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
