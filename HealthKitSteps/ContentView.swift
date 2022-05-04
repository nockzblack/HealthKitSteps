//
//  ContentView.swift
//  HealthKitSteps
//
//  Created by Fernando's Mac on 04/05/22.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    private var healStore: HealStore?
    @State private var steps: [Step] = [Step]()
    
    init() {
        healStore = HealStore()
    }
    
    private func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection) {
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        let endDate = Date()
        
        statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
            let count = statistics.sumQuantity()?.doubleValue(for: .count())
            
            let step = Step(count: Int(count ?? 0), date: statistics.startDate)
            
            steps.append(step)
        }
    }
    
    var body: some View {
        List(steps, id: \.id) { step in
            VStack {
                Text("\(step.count)")
                Text(step.date, style: .date)
                    .opacity(0.5)
            }
        }
        .padding()
        .onAppear {
            if let healStore = healStore {
                healStore.requestAuthorization { success in
                    if success {
                        healStore.calculateSteps { statisticsCollection in
                            if let statisticsCollection = statisticsCollection {
                                updateUIFromStatistics(statisticsCollection)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
