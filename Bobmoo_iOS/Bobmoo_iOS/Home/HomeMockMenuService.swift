//
//  HomeMockMenuService.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/18/26.
//

import Foundation

struct HomeMockMenuService: HomeMenuService {
    func fetchDailyMenu(date: Date, school: String) async throws -> DailyMenuResponse {
        let json = """
        {
          "date": "2026-01-08",
          "school": "인하대학교",
          "cafeterias": [
            {
              "name": "학생식당",
              "hours": {
                "breakfast": "08:00-09:30",
                "lunch": "11:30-14:00",
                "dinner": "17:30-19:30"
              },
              "meals": {
                "breakfast": [
                  { "course": "A", "mainMenu": "북어해장국", "price": 5200 },
                  { "course": "B", "mainMenu": "에그스크램블 토스트", "price": 3000 }
                ],
                "lunch": [
                  { "course": "A", "mainMenu": "치즈돈카츠 정식", "price": 7200 },
                  { "course": "B", "mainMenu": "닭갈비 덮밥", "price": 6800 },
                  { "course": "C", "mainMenu": "얼큰 어묵우동", "price": 5500 }
                ],
                "dinner": [
                  { "course": "A", "mainMenu": "순두부찌개와 제육", "price": 6900 },
                  { "course": "B", "mainMenu": "크림파스타", "price": 6500 }
                ]
              }
            },
            {
              "name": "교직원식당",
              "hours": {
                "breakfast": "미운영",
                "lunch": "11:30-13:30",
                "dinner": "17:30-19:00"
              },
              "meals": {
                "lunch": [
                  { "course": "A", "mainMenu": "한우미역국 정식", "price": 7800 },
                  { "course": "B", "mainMenu": "훈제오리 샐러드", "price": 8500 }
                ],
                "dinner": [
                  { "course": "A", "mainMenu": "고등어구이 정식", "price": 7200 },
                  { "course": "B", "mainMenu": "버섯들깨수제비", "price": 6000 }
                ]
              }
            },
            {
              "name": "기숙사 식당",
              "hours": {
                "breakfast": "07:30-09:00",
                "lunch": "11:30-13:30",
                "dinner": "17:30-19:30"
              },
              "meals": {
                "breakfast": [
                  { "course": "A", "mainMenu": "소시지 오므라이스", "price": 4800 },
                  { "course": "B", "mainMenu": "그릭요거트 볼", "price": 3500 }
                ],
                "lunch": [
                  { "course": "A", "mainMenu": "치킨마요 덮밥", "price": 5200 },
                  { "course": "B", "mainMenu": "토마토 리조또", "price": 5800 }
                ],
                "dinner": [
                  { "course": "A", "mainMenu": "김치찌개와 계란말이", "price": 6100 },
                  { "course": "B", "mainMenu": "불고기 비빔면", "price": 5700 }
                ]
              }
            }
          ]
        }
        """
        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode(DailyMenuResponse.self, from: data)
        return decoded
    }
}
