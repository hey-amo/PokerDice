import SwiftUI

// button for a single die, showing the face value and whether it is held or not
private struct PokerDieButton: View {
    let face: DieFace?
    let isHeld: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if let face {
                    Text(face.displayName)
                        .font(.title2.weight(.bold))
                        .contentTransition(.numericText())
                } else {
                    Image(systemName: "questionmark")
                        .font(.title2.weight(.medium))
                }

                if face != nil {
                    Image(systemName: isHeld ? "lock.fill" : "lock.open")
                        .font(.caption2.weight(.semibold))
                    Text(isHeld ? "HELD" : "HOLD")
                        .font(.system(.caption2, design: .rounded).weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 76)
            .padding(.vertical, 5)
            .background(
                isHeld
                    ? PokerDicePalette.primary.opacity(0.24)
                    : Color.primary.opacity(face == nil ? 0.035 : 0.07),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        isHeld ? PokerDicePalette.primary : Color.primary.opacity(0.12),
                        lineWidth: isHeld ? 2 : 1
                    )
            }
            .scaleEffect(isEnabled ? 1 : 0.98)
            .animation(.easeInOut(duration: 0.18), value: isHeld)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isHeld ? PokerDicePalette.primary : Color.primary)
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(isHeld ? "Held" : "Available to hold")
        .accessibilityAddTraits(isHeld ? .isSelected : [])
    }

    private var accessibilityLabel: String {
        guard let face else {
            return "Die, not rolled"
        }
        return "Die \(face.displayName)"
    }
}