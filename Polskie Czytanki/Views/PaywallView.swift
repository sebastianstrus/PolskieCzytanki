//
//  PaywallView.swift
//  Polskie Czytanki
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(StoreManager.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var appeared = false
    @State private var showErrorAlert = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.36, blue: 0.95),
                    Color(red: 0.96, green: 0.31, blue: 0.51),
                    Color(red: 0.99, green: 0.61, blue: 0.27)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            floatingDecorations

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 28) {
                        heroIcon
                            .padding(.top, 20)

                        titleBlock

                        benefitsList

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 24)
                }

                bottomBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
            }
        }
        .task {
            if store.products.isEmpty {
                await store.loadProducts()
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
        }
        .onChange(of: store.isPremium) { _, newValue in
            if newValue { dismiss() }
        }
        .alert("Coś poszło nie tak", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.lastError ?? "Spróbuj ponownie później.")
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                HapticManager.tap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.callout.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
            }
            .accessibilityLabel(Text("Zamknij"))
            Spacer()
        }
        .frame(height: 44)
    }

    private var heroIcon: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.35), Color.white.opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 150, height: 150)
                .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 2))

            Image(systemName: "crown.fill")
                .font(.system(size: 70, weight: .bold))
                .foregroundStyle(Color.yellow)
                .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
        }
        .scaleEffect(appeared ? 1.0 : 0.6)
        .opacity(appeared ? 1.0 : 0)
    }

    private var titleBlock: some View {
        VStack(spacing: 10) {
            Text("Odblokuj wszystkie czytanki")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.35), radius: 8, y: 3)

            Text("Jednorazowy zakup. Dostęp na zawsze.")
                .font(.appSubtitle)
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
        }
        .opacity(appeared ? 1.0 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var benefitsList: some View {
        VStack(spacing: 12) {
            benefitRow(icon: "books.vertical.fill", title: "320 czytanek", subtitle: "Pełna kolekcja krótkich historii.")
            benefitRow(icon: "speaker.wave.2.fill", title: "Nagrania lektora", subtitle: "Wszystkie nagrania dźwiękowe.")
            benefitRow(icon: "questionmark.circle.fill", title: "Pytania i quizy", subtitle: "Sprawdź zrozumienie po każdej czytance.")
            benefitRow(icon: "infinity", title: "Dostęp na zawsze", subtitle: "Jeden zakup, bez subskrypcji.")
        }
        .opacity(appeared ? 1.0 : 0)
        .offset(y: appeared ? 0 : 30)
    }

    private func benefitRow(icon: String, title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.25), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.white.opacity(0.45), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appHeadline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            purchaseButton
            restoreButton
            legalText
        }
    }

    @ViewBuilder
    private var purchaseButton: some View {
        Button {
            Task { await handlePurchase() }
        } label: {
            HStack(spacing: 12) {
                if store.isPurchasing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(red: 0.55, green: 0.36, blue: 0.95))
                } else {
                    Image(systemName: "crown.fill")
                        .font(.title2.weight(.bold))
                }
                Text(purchaseButtonTitle)
                    .font(.appButton)
            }
            .foregroundStyle(Color(red: 0.55, green: 0.36, blue: 0.95))
            .padding(.vertical, 18)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(BouncyButtonStyle())
        .disabled(store.isPurchasing || store.isLoadingProducts || store.premiumProduct == nil)
        .opacity(store.premiumProduct == nil && !store.isLoadingProducts ? 0.6 : 1.0)
    }

    private var purchaseButtonTitle: String {
        if store.isLoadingProducts {
            return "Ładowanie..."
        }
        if let product = store.premiumProduct {
            return "Kup za \(product.displayPrice)"
        }
        return "Produkt niedostępny"
    }

    private var restoreButton: some View {
        Button {
            Task { await handleRestore() }
        } label: {
            Text("Przywróć zakup")
                .font(.appCaption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.45), lineWidth: 1))
        }
        .disabled(store.isPurchasing)
    }

    private var legalText: some View {
        Text("Jednorazowa płatność. Bez automatycznego odnawiania.")
            .font(.system(size: 11, weight: .regular, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.top, 4)
    }

    private var floatingDecorations: some View {
        ZStack {
            decorationBubble(size: 90, x: 60, y: 120)
            decorationBubble(size: 50, x: 320, y: 220)
            decorationBubble(size: 70, x: 350, y: 560)
            decorationBubble(size: 40, x: 50, y: 640)
        }
        .allowsHitTesting(false)
    }

    private func decorationBubble(size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(Color.white.opacity(0.18))
            .frame(width: size, height: size)
            .blur(radius: 6)
            .position(x: x, y: y)
    }

    private func handlePurchase() async {
        HapticManager.tap()
        let success = await store.purchasePremium()
        if success {
            HapticManager.celebrate()
        } else if store.lastError != nil {
            showErrorAlert = true
        }
    }

    private func handleRestore() async {
        HapticManager.tap()
        await store.restorePurchases()
        if store.lastError != nil {
            showErrorAlert = true
        } else if store.isPremium {
            HapticManager.success()
        }
    }
}

#Preview {
    PaywallView()
        .environment(StoreManager())
}
