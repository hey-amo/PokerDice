//
//  DiceFaceView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//


import SwiftUI

enum DiceFace: Int, CaseIterable {
    case nine = 9, ten, jack, queen, king, ace
}

extension DiceFace {
    var symbol: String {
       switch self {
       case .nine: return "9.circle"
       case .ten: return "10.circle"
       case .jack: return "j.circle.fill"
       case .queen: return "q.circle.fill"
       case .king: return "k.circle.fill"
       case .ace: return "a.circle.fill"
       }
    }
    var label: String {
        switch self {
            case .nine: return "9"
            case .ten: return "10"
            case .jack: return "J"
            case .queen: return "Q"
            case .king: return "K"
            case .ace: return "A"
        }
    }
}


// CROPPED IMAGE
/*
struct DiceFaceView: View {
    let index: Int // 0 through 6

    var body: some View {
        GeometryReader { geometry in
            if let image = UIImage(named: "Dice"),
               let cgImage = image.cgImage {

                let totalWidth = CGFloat(cgImage.width)
                let frameWidth = totalWidth / 7.0
                let frameHeight = CGFloat(cgImage.height)

                if let cropped = cgImage.cropping(to: CGRect(x: CGFloat(index) * frameWidth,
                                                             y: 0,
                                                             width: frameWidth,
                                                             height: frameHeight)) {
                    Image(uiImage: UIImage(cgImage: cropped))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                Color.clear
            }
        }
    }
}
*/

// MARK: DiceFaceView

struct DiceFaceView: View {
    let face: DiceFace
    let isHeld: Bool
    let isRolling: Bool

    var body: some View {
        VStack(spacing: 4.0) {
            // Symbol
            Image(systemName: face.symbol)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.top, 4)
            // Label
            Text(face.label)
                           .font(.system(size: 18, weight: .bold))
                           .minimumScaleFactor(0.5) // Shrinks text if needed
                           .lineLimit(1)
                           .allowsTightening(true)
                           .frame(maxWidth: .infinity)
        }
        .padding(8.0)
        .frame(width: 60, height: 80)
        .background(isHeld ? Color.blue.opacity(0.2) : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isHeld ? Color.blue : Color.black, lineWidth: isHeld ? 4 : 1)
        )
        //.background(RoundedRectangle(cornerRadius: 10).stroke())
        .rotation3DEffect(
            .degrees(isRolling ? 360 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.5), value: isRolling)
    }
}
