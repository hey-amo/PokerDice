//
//  DiceFaceView.swift
//  SimplePokerDice
//
//  Created by Amarjit on 22/04/2025.
//


import SwiftUI

enum DiceFace: Int, CaseIterable {
    case blank = 0, nineClubs, nineDiamonds, jack, queen, king, aceSpades
    
    var rankValue: Int {
       switch self {
       case .nineClubs, .nineDiamonds: return 9
       case .jack: return 11
       case .queen: return 12
       case .king: return 13
       case .aceSpades: return 14
       default: return 0
       }
   }
}

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

struct DiceFaceView: View {
    let face: DiceFace
    let isRolling: Bool

    var body: some View {
        VStack(spacing: 4.0) {
            Image(systemName: faceSymbol)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .padding(.top, 4)
            
            Text(faceLabel)
                           .font(.system(size: 18, weight: .bold))
                           .minimumScaleFactor(0.5) // Shrinks text if needed
                           .lineLimit(1)
                           .allowsTightening(true)
                           .frame(maxWidth: .infinity)
//            Text(faceSymbol)
//                .font(.largeTitle)
//            Text(faceLabel)
//                .font(.headline)
        }
        .padding(8.0)
        .frame(width: 60, height: 80)
        .background(RoundedRectangle(cornerRadius: 10).stroke())
        .rotation3DEffect(
            .degrees(isRolling ? 360 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.5), value: isRolling)
    }

    private var faceSymbol: String {
        switch face {
        case .nineClubs: return "suit.club.fill"
        case .nineDiamonds: return "suit.diamond.fill"
        case .jack: return "j.circle.fill"
        case .queen: return "q.circle.fill"
        case .king: return "k.circle.fill"
        case .aceSpades: return "suit.spade.fill"
        default: return "questionmark"
        }
    }

    private var faceLabel: String {
        switch face {
        case .nineClubs, .nineDiamonds: return "9"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .aceSpades: return "A"
        default: return "?"
        }
    }
}
