import SwiftUI

private enum PokerDicePalette {
    static let primary = Color(red: 0.404, green: 0.314, blue: 0.643)
}

struct ContentView: View {
    @StateObject private var game = PokerDiceViewModel()
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var colorSchemeOverride: ColorScheme?

    private var isDarkMode: Bool {
        (colorSchemeOverride ?? systemColorScheme) == .dark
    }

    var body: some View {
        ZStack {
            PokerDicePalette.primary
                .opacity(isDarkMode ? 0.06 : 0.025)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    navigationHeader
                    messageCard
                    diceSection
                    gameControls
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .preferredColorScheme(colorSchemeOverride)
    }

    private var navigationHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "die.face.5")
                .font(.title2.weight(.bold))
                .foregroundStyle(PokerDicePalette.primary)
                .accessibilityHidden(true)

            Text("Poker Dice")
                .font(.title2.weight(.bold))
                .foregroundStyle(PokerDicePalette.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 4)

            headerButton("speaker.wave.2", label: "Sound settings") {
                print("Sound settings tapped")
            }

            headerButton(isDarkMode ? "sun.max" : "moon", label: "Toggle light or dark mode") {
                colorSchemeOverride = isDarkMode ? .light : .dark
                print("Theme toggled: \(isDarkMode ? "dark" : "light") mode")
            }

            headerButton("line.3.horizontal", label: "Menu") {
                print("Menu tapped")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }

    private var messageCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("YOUR HAND")
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PokerDicePalette.primary.opacity(0.18), in: Capsule())

                Spacer()

                Text("\(game.playerHand.rollsUsed) / 3 rolls")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .accessibilityLabel("\(game.playerHand.rollsUsed) of 3 rolls used")
            }

            HStack(spacing: 10) {
                if game.isRolling {
                    ProgressView()
                        .tint(PokerDicePalette.primary)
                        .accessibilityLabel("Dice are rolling")
                }

                Text(game.message)
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.updatesFrequently)
            }
            .frame(minHeight: 34)

            HStack(spacing: 10) {
                ForEach(1...3, id: \.self) { roll in
                    Circle()
                        .fill(
                            roll <= game.playerHand.rollsUsed
                                ? PokerDicePalette.primary
                                : Color.primary.opacity(0.14)
                        )
                        .frame(width: 10, height: 10)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(game.playerHand.rollsUsed) of 3 rolls used")

            if let lastRollMessage = game.lastRollMessage {
                Text(lastRollMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            PokerDicePalette.primary.opacity(isDarkMode ? 0.18 : 0.13),
            in: RoundedRectangle(cornerRadius: 26)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .strokeBorder(PokerDicePalette.primary.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: .black.opacity(isDarkMode ? 0.12 : 0.08), radius: 8, y: 4)
    }

    private var diceSection: some View {
        VStack(spacing: 12) {
            Text(diceInstruction)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    PokerDieButton(
                        face: game.playerHand.dice.indices.contains(index)
                            ? game.playerHand.dice[index]
                            : nil,
                        isHeld: game.playerHand.heldDice.contains(index),
                        isEnabled: game.isDieEnabled(index)
                    ) {
                        game.toggleHold(at: index)
                    }
                }
            }
        }
    }

    private var diceInstruction: String {
        if game.isFinished {
            return "Your final hand"
        }
        if !game.hasStarted {
            return "Roll to reveal your dice"
        }
        if game.isRolling {
            return "Rolling…"
        }
        return "Tap dice to hold or release them"
    }

    private var gameControls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    Task {
                        await game.rollDice()
                    }
                } label: {
                    Label(
                        game.playerHand.rollsUsed == 0 ? "Roll Dice" : "Roll Again",
                        systemImage: "die.face.5"
                    )
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                }
                .buttonStyle(MaterialPrimaryButtonStyle())
                .disabled(!game.canRoll)
                .accessibilityHint(rollButtonHint)

                Button {
                    game.resetGame()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3.weight(.semibold))
                        .frame(width: 56, height: 56)
                        .contentShape(RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(MaterialSecondaryButtonStyle())
                .disabled(!game.canReset)
                .accessibilityLabel("Reset game")
                .accessibilityHint(
                    game.canReset
                        ? "Starts a fresh hand."
                        : "Reset is available after the first roll and when dice are not rolling."
                )
            }

            if game.canFinish {
                Button {
                    game.finishHand()
                } label: {
                    Label("Finish Hand", systemImage: "checkmark")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(MaterialSecondaryButtonStyle())
            }
        }
    }

    private var rollButtonHint: String {
        if game.isRolling {
            return "Wait for the dice to stop rolling."
        }
        if game.playerHand.heldDice.count == 5 {
            return "Unlock at least one die before rolling again."
        }
        if game.isFinished {
            return "This hand is complete. Reset to start a new hand."
        }
        return "Roll up to three times. Held dice stay in place."
    }

    private func headerButton(
        _ symbol: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .medium))
                .frame(width: 38, height: 38)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .accessibilityLabel(label)
    }
}


private struct MaterialPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .background(
                PokerDicePalette.primary.opacity(isEnabled ? 1 : 0.42),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .shadow(
                color: PokerDicePalette.primary.opacity(isEnabled ? 0.2 : 0),
                radius: 6,
                y: 3
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct MaterialSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.primary.opacity(isEnabled ? 1 : 0.38))
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .frame(width: 360, height: 760)
}
