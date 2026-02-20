//
//  ContentView.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/13/26.
//

import SwiftUI
import Observation

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
       
    var body: some View {
        Group {
            if viewModel.isEmptyMenu {
                VStack(spacing: 0) {
                    HeaderView(viewModel: viewModel)

                    ScrollView(showsIndicators: false) {
                        EmptyView()
                    }
                    .scrollBounceBehavior(.always)
                    .refreshable {
                        await viewModel.load()
                    }
                }
                .transition(.opacity)
            } else {
                let now = Date()

                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        HeaderView(viewModel: viewModel)

                        ForEach(viewModel.mealSectionOrder(now: now), id: \.self) { section in
                            MealSectionCardView(section: section, viewModel: viewModel)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isEmptyMenu)
        .ignoresSafeArea(edges: .top)
        .background(Color.bobmooGray4.ignoresSafeArea())
        .task {
            if viewModel.menu == nil {
                await viewModel.load()
            }
        }
    }
}

struct HeaderView: View {
    let viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                BobmooText(viewModel.univName, style: .head_b_30)
                    .foregroundStyle(Color.bobmooWhite)

                Spacer()

                Button(action: {}) {
                    Image(.menu)
                }
            }
            
            BobmooCalendarButton(vm: viewModel)
        }
        .padding(.horizontal, 25)
        .padding(.top, 70)
        .padding(.bottom, 18)
        .background(Color(hexRGB: viewModel.univColor) ?? Color.bobmooBlack)
        .BobmooShadow()
    }
}

struct MealSectionCardView: View {
    let section: HomeViewModel.MealSection
    let viewModel: HomeViewModel

    private func priceText(_ value: Int) -> String {
        "\(value)원"
    }

    var body: some View {
        let now = Date()
        let cafeterias = viewModel.menu?.cafeterias ?? []

        VStack(alignment: .leading, spacing: 0) {
            BobmooText(section.title, style: .head_b_21)
                .padding(.top, 21)
                .padding(.leading, 16)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(cafeterias.enumerated()), id: \.offset) { index, cafeteria in
                    let hours = cafeteria.hours[keyPath: section.hoursKeyPath]
                    let period = hours.bobmooOperationPeriod(on: now)
                    let items = cafeteria.meals[keyPath: section.mealsKeyPath] ?? []

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            BobmooText(cafeteria.name, style: .body_sb_18)

                            BobmooText(hours, style: .body_sb_9)
                                .foregroundStyle(.bobmooGray3)
                                .padding(.leading, 5)

                            Spacer()

                            if let period {
                                BobmooLabel(period: period, now: now)
                                    .padding(.trailing, 18)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.leading, 21)

                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                                HStack(spacing: 0) {
                                    BobmooText(item.course, style: .body_m_15)

                                    BobmooText(item.mainMenu, style: .body_r_15, multiline: true)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                        .padding(.leading, 4)

                                    Spacer()

                                    BobmooText(priceText(item.price), style: .body_sb_11)
                                        .foregroundStyle(.bobmooGray3)
                                }
                            }
                        }
                        .padding(.top, 7)
                        .padding(.horizontal, 23)

                        if index < cafeterias.count - 1 {
                            Divider()
                                .padding(.horizontal, 21)
                                .padding(.top, 16)
                        } else {
                            Spacer(minLength: 0)
                                .frame(height: 9)
                        }
                    }
                }
            }
        }
        .background(
            Rectangle()
                .cornerRadius(15)
                .foregroundStyle(.bobmooWhite)
        )
        .padding(.horizontal, 28)
        .padding(.top, 30)
    }
}

struct EmptyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(.bobmooLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 59)
                .padding(.top, 127)
            
            BobmooText("등록된 식단이 없어요", style: .body_sb_18)
                .padding(.top, 24)
            
            BobmooText("식단 정보가 등록되지 않았어요.", style: .body_sb_15)
                .padding(.top, 21)
                .foregroundStyle(.bobmooGray3)
            
            BobmooText("잠시 후 다시 확인해 주세요.", style: .body_sb_15)
                .padding(.top, 4)
                .foregroundStyle(.bobmooGray3)
            
            Image(.iconArrow)
                .padding(.top, 118)
            
            BobmooText("아래로 당겨 새로고침", style: .body_sb_11)
                .foregroundStyle(.bobmooGray3)
                .padding(.top, 7)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .cornerRadius(15)
                .foregroundStyle(.bobmooWhite)
            )
        .padding(.horizontal, 28)
        .padding(.top, 30)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(service: HomeMockMenuService()))
}
