//
//  ContentView.swift
//  coreml_demo
//
//  Created by patrick long on 12/24/20.
//

import SwiftUI
import CoreML


struct ContentView: View {
    @State private var rm_in = 6
    @State private var age_in = 70
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("House Requirements")
                    .font(.title)
                
                Stepper(value: $rm_in, in: 1...9, step: 1) {
                    Text("Rooms: \(rm_in)")
                        .frame(alignment: .center)
                        .padding(.leading, 40)
                    
                }
                Stepper(value: $age_in, in: 1...100, step: 1) {
                    Text("Age: \(age_in)")
                        .frame(alignment: .center)
                        .padding(.leading, 40)
                }
                .navigationBarTitle("House Price Predictor")
                .navigationBarItems(trailing:
                    Button(action: calculatePrice) {
                        Text("Calculate Price")
                    }
                )
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
       
        }

    }
    func calculatePrice() {
        let model = bhousing()
        do { let prediction = try
            model.prediction(RM: Double(rm_in),
                             AGE: Double(age_in))
            
            
            alertMessage = String(prediction.PRICE)
            alertTitle = "The price is…"
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating the house price."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

















