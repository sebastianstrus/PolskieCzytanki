//
//  SettingsView.swift
//  Polskie Czytanki
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(ProgressStore.self) private var progress
    @Environment(StoreManager.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirmation = false
    @State private var showOnboarding = false
    @State private var showPaywall = false

    var body: some View {
        @Bindable var bindableSettings = settings

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
                VStack(spacing: 20) {
                    sectionHeader("Premium")
                    SettingsCard {
                        premiumRow
                    }

                    sectionHeader("Odtwarzanie")
                    SettingsCard {
                        Toggle(isOn: $bindableSettings.showPlayButton) {
                            HStack(spacing: 14) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(AppTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Pokaż przycisk odtwarzania")
                                        .font(.appHeadline)
                                        .foregroundStyle(.primary)
                                    Text("Ukryj go, aby dziecko mogło czytać bez dźwięku.")
                                        .font(.appCaption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .tint(Color(red: 0.31, green: 0.81, blue: 0.55))
                        .onChange(of: bindableSettings.showPlayButton) { _, _ in
                            HapticManager.selection()
                        }
                    }

                    sectionHeader("Wprowadzenie")
                    SettingsCard {
                        Button {
                            HapticManager.tap()
                            showOnboarding = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "sparkles")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(AppTheme.secondaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Pokaż wprowadzenie")
                                        .font(.appHeadline)
                                        .foregroundStyle(.primary)
                                    Text("Zobacz ponownie ekrany powitalne aplikacji.")
                                        .font(.appCaption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    sectionHeader("Postęp")
                    SettingsCard {
                        Button {
                            HapticManager.warning()
                            showResetConfirmation = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.96, green: 0.42, blue: 0.42),
                                                Color(red: 0.86, green: 0.20, blue: 0.30)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Zresetuj postęp")
                                        .font(.appHeadline)
                                        .foregroundStyle(.primary)
                                    Text("Ukończone: \(progress.completedCount)")
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

                    Spacer(minLength: 16)

                    versionLabel

                    Spacer(minLength: 8)
                }
                .padding(20)
            }
        }
        .navigationTitle(Text("Ustawienia"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 1.00, green: 0.95, blue: 0.84), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .confirmationDialog(
            Text("Zresetować cały postęp?"),
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                HapticManager.success()
                progress.resetAll()
            } label: {
                Text("Resetuj")
            }
            Button(role: .cancel) {} label: {
                Text("Anuluj")
            }
        } message: {
            Text("Spowoduje to wyczyszczenie ukończenia wszystkich 320 czytanek.")
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {}
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    @ViewBuilder
    private var premiumRow: some View {
        if store.isPremium {
            HStack(spacing: 14) {
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.successGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Premium aktywne")
                        .font(.appHeadline)
                        .foregroundStyle(.primary)
                    Text("Masz dostęp do wszystkich 320 czytanek.")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.31, green: 0.81, blue: 0.55))
            }
        } else {
            VStack(spacing: 12) {
                Button {
                    HapticManager.tap()
                    showPaywall = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.secondaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Aktywuj Premium")
                                .font(.appHeadline)
                                .foregroundStyle(.primary)
                            Text("Odblokuj wszystkie czytanki na zawsze.")
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)

                Divider()

                Button {
                    HapticManager.tap()
                    Task { await store.restorePurchases() }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Przywróć zakup")
                                .font(.appHeadline)
                                .foregroundStyle(.primary)
                            Text("Jeśli już kupiłeś Premium na tym koncie.")
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var versionLabel: some View {
        VStack(spacing: 4) {
            Text("Polskie Czytanki")
                .font(.appCaption.weight(.bold))
                .foregroundStyle(.secondary)
            Text(versionString)
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var versionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Wersja \(version) (\(build))"
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
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(SettingsStore())
            .environment(ProgressStore())
            .environment(StoreManager())
    }
}
