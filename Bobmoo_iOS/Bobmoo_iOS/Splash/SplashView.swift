//
//  SplashView.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/20/26.
//

import SwiftUI

struct SplashView: View {
    let homeViewModel: HomeViewModel
    let didTapStart: () -> Void

    init(homeViewModel: HomeViewModel, didTapStart: @escaping () -> Void) {
        self.homeViewModel = homeViewModel
        self.didTapStart = didTapStart
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(.bobmooLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                
                BobmooText("밥묵자", style: .head_b_48)
            }
            .padding(.top, 236)
            
            BobmooText("오늘 학식 뭐지?\n홈 화면에서 바로 확인하세요", style: .body_r_15, multiline: true)
                .foregroundStyle(.bobmooGray3)
                .multilineTextAlignment(.center)
                .padding(.top, 28)
            
            Spacer()
            
            BobmooButton(label: "시작하기") {
                didTapStart()
            }
                .padding(.bottom, 12)
                .padding(.horizontal, 40)
            
            BobmooText("로그인 없이도 바로 확인할 수 있어요", style: .body_sb_11)
                .foregroundStyle(.bobmooGray3)
                .padding(.bottom, 21)
        }
        .task {
            if homeViewModel.menu == nil {
                await homeViewModel.load()
            }
        }
    }
}

#Preview {
    SplashView(homeViewModel: HomeViewModel(service: HomeMockMenuService())) {}
}
