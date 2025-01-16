//
//  ContentView.swift
//  Slots
//
//  Created by Dawson Delap on 1/14/25.
//

import SwiftUI

extension AnyTransition {
    static func moveAndOffset(offsetY: CGFloat) -> AnyTransition {
        AnyTransition.modifier(
            active: OffsetModifier(offsetY: offsetY),
            identity: OffsetModifier(offsetY: 0)
        )
    }

    struct OffsetModifier: ViewModifier {
        let offsetY: CGFloat

        func body(content: Content) -> some View {
            content
                .offset(y: offsetY) // Apply vertical offset only
                .opacity(offsetY == 0 ? 1 : 0)
        }
    }
}

struct ContentView: View {
    @State var isBlinking = false
    @State var slot1img: Int = 0
    @State var slot2img: Int = 0
    @State var slot3img: Int = 0
    @State var isDisabled: Bool = false
    @State var autoSpin: Bool = false
    @State var moncolor: Color = .white
    @State private var currentTimestamp: String = ""
    @AppStorage("allgains") private var allgainsSaved = ""
    @State public var allgains: String = "" {
        didSet {
            allgainsSaved = allgains
        }
    }
    @AppStorage("money") private var moneySaved = 0
    @State public var money = 0 {
        didSet {
            moneySaved = money
        }
    }
    @AppStorage("spinCount") private var spinCountSaved = 0
    @State public var spinCount = 0 {
        didSet {
            spinCountSaved = spinCount
        }
    }
    @State var bet: Double = 5.0
    var images = ["x.circle.fill","globe.americas.fill", "sun.horizon.fill", "7.circle.fill", "car.fill", "heart.circle.fill", "cloud.bolt.rain.fill"]
    var colors = [Color.red, Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.pink]
    func checkWin() {
        if slot1img == 3 && slot2img == 3 && slot3img == 3 {
            money += 1000000
            updateTimestamp(earned: "1,000,000")
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isBlinking = true
            }
        }else if slot1img == slot2img && slot2img == slot3img {
            money += 100000
            updateTimestamp(earned: "100,000")
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isBlinking = true
            }
        }
    }
    
    func updateTimestamp(earned: String) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        currentTimestamp = formatter.string(from: now)
        allgains = "\(currentTimestamp) Spin \(spinCount): +\(earned)\n" + allgains
    }
    
    @State var done1 = false
    @State var done2 = false
    func redmoney(){
        if money < 0{
            moncolor = .red
        }else{
            moncolor = .green
        }
    }
    func spin() {
        spinCount += 1
        done1 = false
        done2 = false
        money -= 100
        redmoney()
        if money < 0{
            moncolor = .red
        }else{
            moncolor = .white
        }
        let count = 0
        let randomInt1 = Int.random(in: 10...15)
        spinStep1(count: count, randomInt: randomInt1)
        
    }
    func spin2() {
        let count = 0
        let randomInt2 = Int.random(in: 7...12)
        let randomInt3 = Int.random(in: 7...12)
        if done1{
            spinStep2(count: count, randomInt: randomInt2)
            done1 = false
        }
        if done2{
            spinStep3(count: count, randomInt: randomInt3)
            done2 = false
        }
    }

    func spinStep1(count: Int, randomInt: Int) {
        if count <= randomInt {
            withAnimation {
                slot1img = Int.random(in: 1...5)
            }
            let newCount = count + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                spinStep1(count: newCount, randomInt: randomInt)
            }
        }else{
            done1 = true
            spin2()
        }
    }
    func spinStep2(count: Int, randomInt: Int) {
        if count <= randomInt {
            withAnimation {
                slot2img = Int.random(in: 1...5)
            }
            let newCount = count + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                spinStep2(count: newCount, randomInt: randomInt)
            }
        }else{
            done2 = true
            spin2()
        }
    }
    func spinStep3(count: Int, randomInt: Int) {
        if count <= randomInt {
            withAnimation {
                slot3img = Int.random(in: 1...5)
            }
            let newCount = count + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                spinStep3(count: newCount, randomInt: randomInt)
            }
        }else {
            checkWin()
            redmoney()
            if autoSpin{
                spin()
            }else{
                isDisabled = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack {
                    HStack{
                        VStack{
                            Text("Money:")
                                .foregroundColor(Color.white)
                            Text("$\(money)")
                                .foregroundColor(moncolor)
                        }.font(Font.system(size: 20))
                            .frame(width: 120, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                        VStack{
                            Text("Spins:")
                                .foregroundStyle(Color.white)
                            Text("\(spinCount)")
                                .foregroundColor(Color.white)
                        }.font(Font.system(size: 20))
                            .frame(width: 120, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                        
                    }
                    Spacer()
                    HStack{
                        ZStack {
                            Image(systemName: images[slot1img])
                                .font(Font.system(size: 50))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 200)
                                .id(slot1img) // Ensures unique identity
                                .transition(.moveAndOffset(offsetY: -50)) // Apply transition
                        }.background(colors[slot1img])
                        .cornerRadius(10)
                        ZStack{
                            Image(systemName: images[slot2img])
                                .font(Font.system(size: 50))
                                .foregroundColor(Color.white)
                                .frame(width: 120, height: 200)
                                .id(slot2img) // Ensures unique identity
                                .transition(.moveAndOffset(offsetY: -50))
                        }.background(colors[slot2img])
                            .cornerRadius(10)
                        ZStack{
                            Image(systemName: images[slot3img])
                                .font(Font.system(size: 50))
                                .foregroundColor(Color.white)
                                .frame(width: 120, height: 200)
                                .id(slot3img) // Ensures unique identity
                                .transition(.moveAndOffset(offsetY: -50))
                        }.background(colors[slot3img])
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    VStack{
                        HStack{
                            HStack{ // Adjust spacing here
                                Toggle("", isOn: $autoSpin)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                Text("Auto")
                                    .foregroundColor(.white)
                            }
                            .frame(width: 120, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                            Button(action: {
                                withAnimation{
                                    spin()
                                    isDisabled = true
                                }
                            }) {
                                Label("Spin", systemImage: "arrow.triangle.2.circlepath")
                                    .font(Font.system(size: 20))
                                    .foregroundColor(Color.white)
                                    .frame(width: 120, height: 60)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }.disabled(isDisabled)
                            NavigationLink(destination: gainsView(
                                allgains: $allgains,
                                isBlinking: $isBlinking
                            )) {
                                Text("Gains")
                                    .font(Font.system(size: 20))
                                    .foregroundColor(Color.white)
                                    .frame(width: 120, height: 60)
                                    .background(isBlinking ? Color(white: 0.5) : Color(white: 0.3))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    //MARK: On Appear
                }.onAppear() {
                    money = 0
                    allgains = ""
                    spinCount = 0
                    money = moneySaved
                    allgains = allgainsSaved
                    spinCount = spinCountSaved
                    redmoney()
                }
                .padding()
            }
        }
    }
}
struct gainsView: View {
    @Binding var allgains: String
    @Binding var isBlinking: Bool
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack {
                Text("Gains")
                    .foregroundStyle(Color.white)
                    .font(Font.system(size: 50))
                if allgains == "" {
                    Spacer()
                    Text("No gains yet")
                        .foregroundStyle(Color.white)
                        .font(Font.system(size: 50))
                    Spacer()
                }else{
                    ScrollView{
                        Text("\(allgains)")
                            .foregroundStyle(Color.white)
                            .font(Font.system(size: 25))
                    }
                }
            }.onAppear(){
                withAnimation(){
                    isBlinking = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
