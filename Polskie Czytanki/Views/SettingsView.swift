//
//  SettingsView.swift
//  Polskie Czytanki
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(ProgressStore.self) private var progress
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirmation = false

    var body: some View {
        @Bindable var bindableSettings = settings

        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.95, blue: 0.99),
                    Color(red: 0.91, green: 0.94, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    sectionHeader("Playback")
                    SettingsCard {
                        Toggle(isOn: $bindableSettings.showPlayButton) {
                            HStack(spacing: 14) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(AppTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Show play button")
                                        .font(.appHeadline)
                                        .foregroundStyle(.primary)
                                    Text("Hide it to let kids read without audio.")
                                        .font(.appCaption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .tint(Color(red: 0.31, green: 0.81, blue: 0.55))
                        .onChange(of: bindableSettings.showPlayButton) { _, _ in
                            HapticManager.selection()
                        }
                    }

                    sectionHeader("Progress")
                    SettingsCard {
                        Button {
                            HapticManager.warning()
                            showResetConfirmation = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.96, green: 0.42, blue: 0.42),
                                                Color(red: 0.86, green: 0.20, blue: 0.30)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reset progress")
                                        .font(.appHeadline)
                                        .foregroundStyle(.primary)
                                    Text("Completed: \(progress.completedCount)")
                                        .font(.appCaption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 24)
                }
                .padding(20)
            }
        }
        .navigationTitle(Text("Settings"))
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog(
            Text("Reset all progress?"),
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                HapticManager.success()
                progress.resetAll()
            } label: {
                Text("Reset")
            }
            Button(role: .cancel) {} label: {
                Text("Cancel")
            }
        } message: {
            Text("This will clear completion for all 320 tales.")
        }
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        HStack {
            Text(key)
                .font(.appCaption.weight(.heavy))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 6)
    }
}

private struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(SettingsStore())
            .environment(ProgressStore())
    }
}
