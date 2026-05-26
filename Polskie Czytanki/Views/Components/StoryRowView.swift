//
//  StoryRowView.swift
//  Polskie Czytanki
//

import SwiftUI

struct StoryRowView: View {
    let story: Story
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .topTrailing) {
                Image(story.smallImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 92, height: 92)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: AppTheme.softShadow, radius: 6, y: 3)

                Text("\(story.number)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.primaryGradient, in: Capsule())
                    .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                    .offset(x: 6, y: -6)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(story.title)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if isCompleted {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.footnote.weight(.bold))
                        Text("Ukończone")
                            .font(.appCaption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.successGradient, in: Capsule())
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption.weight(.bold))
                        Text("Stuknij, aby przeczytać")
                            .font(.appCaption)
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient.opacity(0.18))
                    .frame(width: 32, height: 32)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.heavy))
                    .foregroundStyle(Color(red: 0.96, green: 0.31, blue: 0.51))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: AppTheme.softShadow, radius: 10, x: 0, y: 5)
    }
}
