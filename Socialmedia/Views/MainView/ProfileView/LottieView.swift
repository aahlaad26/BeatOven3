//
//  LottieView.swift
//  Socialmedia
//
//  Created by mathangy on 15/03/24.
//

//import SwiftUI
//import Lottie
//
//struct LottieView : UIViewRepresentable{
//    let url : URL
//    func makeUIView(context: Context) -> some UIView {
//        UIView()
//    }
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        let animationView = LottieAnimationView()
//        animationView.translatesAutoresizingMaskIntoConstraints = false
//        uiView.addSubview(animationView)
//        NSLayoutConstraint.activate([
//            animationView.widthAnchor.constraint(equalTo:uiView.widthAnchor),
//            animationView.heightAnchor.constraint(equalTo: uiView.heightAnchor)
//        ])
//        
//        DotLottieFile.loadedFrom(url: url){ result in
//            switch result {
//            case .success(let success):
//                animationView.loadAnimation(from: success)
//                animationView.loopMode = .loop
//                animationView.play()
//                
//            case .failure(let failure):
//                print(failure)
//            }
//        }
//    }
//    
//}


import SwiftUI
import Lottie


struct LottieView: UIViewRepresentable {
    
    var name = "success"
    var loopMode: LottieLoopMode = .loop
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name, bundle: Bundle.main)
        view.loopMode = loopMode
        view.play()
        view.animationSpeed = 1.0
        return view
        
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView()
    }
}
