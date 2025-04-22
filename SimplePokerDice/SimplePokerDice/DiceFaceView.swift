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
