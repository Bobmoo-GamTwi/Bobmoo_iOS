//
//  SettingView.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/23/26.
//

import SwiftUI

struct SettingView: View {
    var onBack: () -> Void
    var onSearchSchool: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            SettingHeaderView(onBack: onBack)
            
            VStack(spacing: 0) {
                UnivSettingView(onTap: onSearchSchool)
                
                WidgetSettingView()
                
                AppVerView()
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bobmooGray4)
            
        }
    }
}

struct SettingHeaderView: View {
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                BobmooText("설정", style: .head_b_21)
                
                HStack {
                    Button(action: onBack) {
                        Image(.iconBack1)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                }
            }
            .padding(.top, 28)
            
            Rectangle()
                .fill(.bobmooGray5)
                .frame(height: 1)
                .padding(.top, 14)
        }
    }
}

struct UnivSettingView: View {
    var onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 0) {
                    BobmooText("학교 설정", style: .body_sb_11)
                        .foregroundStyle(.bobmooGray3)
                        .padding(.leading, 18)
                        .padding(.top, 13)
                    
                    HStack(spacing: 0) {
                        BobmooText(AppConfig.selectedSchool ?? "학교를 선택해주세요", style: .body_m_15)
                            .padding(.leading, 18)
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        Image(.iconBack2)
                            .padding(.trailing, 12)
                    }
                }
                .padding(.bottom, 11)
                .background(
                    Rectangle()
                        .cornerRadius(15)
                        .foregroundStyle(.bobmooWhite)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 25)
        }
    }
}

struct WidgetSettingView: View {
    @State private var selectedCafeteria: String = AppConfig.selectedCafeteria

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BobmooText("위젯 설정", style: .body_sb_11)
                .foregroundStyle(.bobmooGray3)
                .padding(.leading, 18)
                .padding(.top, 13)
            
            BobmooText("기본 위젯에 표시될 식당을 설정하세요", style: .body_m_15)
                .padding(.leading, 18)
                .padding(.top, 8)
            
            HStack(spacing: 0) {
                BobmooChip(label: "학생식당", isSelected: selectedCafeteria == "학생식당") {
                    selectedCafeteria = "학생식당"
                    AppConfig.selectedCafeteria = "학생식당"
                }
                .padding(.leading, 18)
                .padding(.top, 8)

                BobmooChip(label: "교직원식당", isSelected: selectedCafeteria == "교직원식당") {
                    selectedCafeteria = "교직원식당"
                    AppConfig.selectedCafeteria = "교직원식당"
                }
                .padding(.leading, 8)
                .padding(.top, 8)
                
                BobmooChip(label: "생활관식당", isSelected: selectedCafeteria == "생활관식당") {
                    selectedCafeteria = "생활관식당"
                    AppConfig.selectedCafeteria = "생활관식당"
                }
                .padding(.leading, 8)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .padding(.bottom, 11)
        .background(
            Rectangle()
                .cornerRadius(15)
                .foregroundStyle(.bobmooWhite)
        )
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
}

struct AppVerView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Image(.bobmooLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44)
                    .padding(.leading, 10)
                
                BobmooText("밥묵자", style: .body_m_15)
                    .padding(.leading, 7)
                
                Spacer()
                
                BobmooText("v3.0", style: .body_sb_11)
                    .padding(.trailing, 18)
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 11)
        .background(
            Rectangle()
                .cornerRadius(15)
                .foregroundStyle(.bobmooWhite)
        )
        .padding(.horizontal, 20)
        .padding(.top, 15)
    }
}

#Preview {
    SettingView(onBack: {}, onSearchSchool: {})
}
