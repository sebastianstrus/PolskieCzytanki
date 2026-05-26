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
            ZStack(alignment: .bottomLeading) {
                Image(story.smallImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 78, height: 78)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )

                Text("\(story.number)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.primaryGradient, in: Capsule())
                    .padding(6)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(story.title)
                    .font(.appHeadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if isCompleted {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.footnote.weight(.bold))
                        Text("Completed")
                            .font(.appCaption)
                    }
                    .foregroundStyle(Color(red: 0.10, green: 0.62, blue: 0.45))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color(red: 0.31, green: 0.81, blue: 0.55).opacity(0.18))
                    )
                } else {
                    Text("Tap to read")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: AppTheme.softShadow, radius: 10, x: 0, y: 5)
    }
}
