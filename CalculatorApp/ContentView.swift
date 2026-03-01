import SwiftUI

// 演算子を表す列挙型
enum Operand: String {
    case add = "+"
    case subtract = "-"
    case multiply = "×"
    case divide = "÷"
}

//enum SubButton: String {
//    case tojapanese = "ja"
//    case tocomma = " , "
//}


enum CalculatorButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4",
         five = "5", six = "6", seven = "7", eight = "8", nine = "9",
         add = "+", subtract = "-", multiply = "×", divide = "÷",
         equal = "=", clear = "C", plusMinus = "±", percent = "%",
         decimal = ".", wzero = "00", backspace = "BS", hex = "HEX", dec = "DEC"
}

class CalculatorViewModel: ObservableObject {
    @Published var display: String = "0"
    @Published var displayResult: Bool = false
    @Published var operationMode: Bool = false
    @Published var ope: String = ""
    
    @Published var lightUp1 : String = ""
    @Published var lightUp2 : String = ""

    @Published var inputValue: Double = 0
    @Published var operationValue: Double = 0
    private var isTypingNumber = false
    private var hasDecimal = false

    @Published var canHex : Bool = false
    @Published var canDec : Bool = false

    
    func pressButton(_ button: CalculatorButton) {
        
        clearKeta()
        
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            inputNumber(button.rawValue)
            
            lightUp1 = button.rawValue
            
        case .decimal:
            if !hasDecimal {
                if !isTypingNumber {
                    display = "0."
                } else {
                    display += "."
                }
                hasDecimal = true
                isTypingNumber = true
            }
            lightUp1 = button.rawValue
            
        case .add, .subtract, .multiply, .divide:
            if let operation = Operand(rawValue: button.rawValue) {
                setOperation(operation)
            }
            lightUp2 = button.rawValue
            
        case .equal:
            setOperationEqual()
            
            lightUp1 = button.rawValue
            lightUp2 = ""
            
        case .clear:
            clearAll()
            lightUp1 = button.rawValue
            lightUp2 = ""
            
        case .plusMinus:
            toggleSign()
            lightUp1 = button.rawValue
            
        case .percent:
            calculatePercentage()
            lightUp1 = button.rawValue
            
        case .wzero:
            if isTypingNumber {
                display += "00"
            } else {
                display = "0"
                isTypingNumber = true
            }
            
            lightUp1 = button.rawValue

        case .backspace:
            backspace()
            lightUp1 = button.rawValue
            lightUp2 = ""

        case .hex:
            convertToHex()
            lightUp1 = button.rawValue

        case .dec:
            convertToDec()
            lightUp1 = button.rawValue

        }//End of case
    
        canHex = canConvertToHex()
        canDec = canConvertToDec()

    }
    
    

    private func clearKeta() {
        display = display.replacingOccurrences(of: "万",with: "")
            .replacingOccurrences(of: "億",with: "")
            .replacingOccurrences(of: "兆",with: "")
            .replacingOccurrences(of: "京",with: "")
            .replacingOccurrences(of: "垓",with: "")
            .replacingOccurrences(of: ",",with: "")

    }
    
    public func displayMan() {
        clearKeta()
        let v = display.split(separator: ".")
        
        
        display = formatNumberToJapaneseStyle(String(v[0]))
        if v.count > 1 {
            display += "." + String(v[1])
        }
        
        
        isTypingNumber = false
        hasDecimal = false
        operationMode = false

    }
    
    
    public func displayComma() {
        clearKeta()

        let v = Double(display)
 
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // 10進数スタイル
        formatter.groupingSeparator = "," // カンマを区切り文字として設定
        formatter.groupingSize = 3 // 3桁ごとに区切る
        formatter.usesGroupingSeparator = true // 区切り文字を使用

        if let formattedString = formatter.string(from: NSNumber(value: v! )) {
            display = formattedString
        } else {
            display =  "Error"
        }

        isTypingNumber = false
        hasDecimal = false
        operationMode = false


    }
    
    private func inputNumber(_ number: String) {
        
        if isTypingNumber {
            display += number
        } else {
            display = number
            isTypingNumber = true
        }
        
        if let value = Double(display) {
            if !operationMode {
                inputValue = value
            } else {
                operationValue = value
            }
        }
    }
    
    //イコールを押した処理
    private func setOperationEqual() {
        
        if let value = Double(display) {
            //イコール連打
            if !operationMode && !isTypingNumber {
                inputValue = value
            }else if !operationMode {
                inputValue = value
            } else {
                operationValue = value
            }
        }
        
        calculateResult()
        
        operationMode = false
        isTypingNumber = false
    }
    
    
    //四則演算を押した処理
    private func setOperation(_ operation: Operand) {
        
        if let value = Double(display) {
            if !operationMode {
                inputValue = value
            } else {
                operationValue = value
            }
        }
        
        ope = operation.rawValue
        if operationMode {
            calculateResult()
        }
        
        isTypingNumber = false
        hasDecimal = false
        operationMode = true
        
        
    }
    
    private func calculateResult() {
        let result: Double
        
        print("input \(inputValue) ope \(operationValue) ")
        
        switch ope {
        case Operand.add.rawValue:
            result = inputValue + operationValue
        case Operand.subtract.rawValue:
            result = inputValue - operationValue
        case Operand.multiply.rawValue:
            if operationValue == 0 {
                operationValue = operationValue
            }
            result = inputValue * operationValue

        case Operand.divide.rawValue:
            
            if operationValue == 0 {
                display = "Error: Division by zero"
                clearAll()
                return
            }
            result = inputValue / operationValue
        default:
            result = inputValue + operationValue
        }
        
        print (String(format: "%f", result))
        //        display = String(format: "%f", result).trimmingCharacters(in: CharacterSet(charactersIn: "0").union(.punctuationCharacters))
        
        // NumberFormatterのインスタンスを作成
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0 // 最小限の小数部桁数
        formatter.maximumFractionDigits = 8 // 最大の小数部桁数
        formatter.numberStyle = .decimal    // 10進数スタイル
        formatter.alwaysShowsDecimalSeparator = false // 必要のない場合は小数点を表示しない
        formatter.decimalSeparator = "." // 小数点の区切り文字
        formatter.usesGroupingSeparator = false // 数値のグループ区切りを使用しない
        
        // 結果をフォーマットする
        if let formattedString = formatter.string(from: NSNumber(value: result)) {
            display = formattedString
        } else {
            display = "Error"
        }
        
        inputValue = result
        //        operationValue = 0
        operationMode = false
        isTypingNumber = false
        hasDecimal = false
        
    }
    
    private func clearAll() {
        inputValue = 0
        operationValue = 0
        operationMode = false
        displayResult = false
        display = "0"
        isTypingNumber = false
        hasDecimal = false
    }
    
    private func toggleSign() {
//        if isTypingNumber {
            if display.first == "-" {
                display.removeFirst()
            } else {
                display = "-" + display
            }
            if operationMode {
                operationValue = -operationValue
            } else {
                inputValue = -inputValue
            }
//        }
    }
    
    
    func copyToClipboard() {
        UIPasteboard.general.string = display
    }
    
    private func calculatePercentage() {
        if isTypingNumber {
            if operationMode {
                operationValue /= 100
                display = String(operationValue)
            } else {
                inputValue /= 100
                display = String(inputValue)
            }
        }
    }
    
    func formatNumberToJapaneseStyle(_ prnumber: String) -> String {
        let units = ["", "万", "億", "兆", "京", "垓"]
        let str  = Array( prnumber.reversed() )
        var res : String = ""
        
        
        for i in 0 ..< str.count {
            if i % 4 == 0 {
                res += units[i / 4]
            }
                res += String(str[i])
        }
        
        print(res)
        
        return String(res.reversed() )
        
    }

    
    public func backspace() {
        guard !display.isEmpty else { return }

        if display == "0" {
            return
        }

        display.removeLast()
        
        if display == "" {
            display = "0"
            isTypingNumber = false
        }
        if let value = Double(display) {
            if !operationMode {
                inputValue = value
            } else {
                operationValue = value
            }
        }
    }
    
    public func convertToHex() {
        guard let number = Int(display) else { return }
        display = String(number, radix: 16).uppercased()
    }
    
    func canConvertToHex() -> Bool {
        // Int型に変換できるかどうかチェック
        return Int(display) != nil
    }
    
    func convertToDec()  {
        // 16進数から10進数への変換
        if let decimalValue = Int(display, radix: 16) {
            display = String(decimalValue)
        }
    }
    
    func canConvertToDec() -> Bool {
        // 正規表現を使用して16進数のフォーマットに合致するかチェック
        let regex = try! NSRegularExpression(pattern: "^[0-9A-Fa-f]+$", options: [])
        return regex.numberOfMatches(in: display, options: [], range: NSRange(location: 0, length: display.count)) > 0
    }

    
}



//MARK: VIEW
struct CalculatorView: View {
    @ObservedObject var viewModel = CalculatorViewModel()
    
    
    let TEXTCOLOR = Color.blue  //.opacity(0.75)
    let DARKTEXTCOLOR = Color(red: 0, green: 0, blue: 20)
    let DARKTEXTCOLORHALF = Color(red: 0, green: 0, blue: 10)
    let DARKBACKCOLOR = Color(red: 0, green: 0, blue: 0.3)
    let BACKGROUNDCOLOR = Color.black
    
    let buttons: [[CalculatorButton]] = [
        [.clear, .plusMinus, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .wzero, .decimal, .equal]
    ]
    
//    let subbuttons: [SubButton] = [.tojapanese]
    
    var body: some View {
        ZStack {
            // Blue gradient background
            LinearGradient(gradient: Gradient(colors: [BACKGROUNDCOLOR, Color(red: 0.0, green: 0.0, blue: 0.5)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                // Display
                Text(viewModel.display)
                    .padding()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: UIScreen.main.bounds.width * 0.9 )
                    .foregroundColor(TEXTCOLOR)
                    .font(.custom("Futura", size: buttonFont()))
                    .modifier(NeonWeak(isNeoned: viewModel.displayResult ))
                    .modifier(BlueShadow())
                    .contentShape(Rectangle())
                    .onTapGesture {
                    }

                Spacer()

                //Sub Buttons
                VStack (alignment: .leading){
                    HStack(alignment: .top) {
                        
                        Button(action: {
                            viewModel.copyToClipboard()
                        }) {
                            Text("COPY")
                                .font(.custom("Futura", size: subbuttonFont() * 0.75))
                                .frame(width: 200, height: 30)
                                .background(Color.clear)
                                .foregroundColor(Color.blue)
                        }

                        Spacer()

                        Spacer()

                        Button(action: {
                            viewModel.displayMan()
                        }) {
                            Text("Ja")
                                .font(.custom("Futura", size: subbuttonFont()))
                                .frame(width: 70, height: 30)
                                .background(Color.clear)
                                .foregroundColor(Color.blue)
                        }
                        Spacer()

                        Button(action: {
                            viewModel.displayComma()
                        }) {
                            Text(" , ")
                                .font(.custom("Futura", size: subbuttonFont()))
                                .frame(width: 50, height: 30)
                                .background(Color.clear)
                                .foregroundColor(Color.blue)
                        }
                        Spacer()

                        Button(action: {
                            viewModel.pressButton(.backspace)
                        }) {
                            Text("BS")
                                .font(.custom("Futura", size: subbuttonFont()))
                                .frame(width: 80, height: 30)
                                .background(Color.clear)
                                .foregroundColor(Color.blue)
                        }

                        Spacer()

                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 40)
//                    .border(.white, width: 1)

                }
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 40)
//                .border(.red, width: 1)

                Spacer()

                //Sub buttons 2
                VStack (alignment: .leading){
                    HStack(alignment: .top) {
                        
                        Button(action: {
                            viewModel.pressButton(.hex)
                        }) {
                            Text("HEX")
                                .font(.custom("Futura", size: subbuttonFont() * 0.75))
                                .frame(width: 200, height: 30)
                                .background(Color.clear)
                                .foregroundColor(viewModel.canHex ? Color.blue : DARKTEXTCOLOR )
                        }
                        .disabled(!viewModel.canHex)

                        Spacer()

                        Button(action: {
                            viewModel.pressButton(.dec)
                        }) {
                            Text("DEC")
                                .font(.custom("Futura", size: subbuttonFont() * 0.75))
                                .frame(width: 200, height: 30)
                                .background(Color.clear)
                                .foregroundColor(viewModel.canDec ? Color.blue : DARKTEXTCOLOR )
                        }
                        .disabled(!viewModel.canDec)
                        
                        
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 30)
//                    .border(.white, width: 1)

                }
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 40)
//                .border(.red, width: 1)

                Spacer()
                
                // Buttons
                ForEach(buttons, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { button in
                            Button(action: {
                                viewModel.pressButton(button)
                            }) {
                                Text(button.rawValue)
                                    .font(.custom("Futura", size: buttonFont()))
                                    .frame(width: self.buttonWidth(button: button), height: self.buttonHeight())
                                    .background(button.backgroundColor)
                                    .foregroundColor(button.foregroundColor)
//                                    .cornerRadius(10)
                                    .modifier(Neon(isNeoned: ((button.rawValue == viewModel.lightUp1 || button.rawValue == viewModel.lightUp2 ) ? true : false) ))

                            }
                        }
                    }
                }
                Spacer()
                
            } //VStack

        }
    }
    
    // Helper functions to determine button size
    func buttonWidth(button: CalculatorButton) -> CGFloat {
        // Determine width based on button type
        // For example, the zero button might be wider
        return UIScreen.main.bounds.width / 5
    }
    
    func buttonHeight() -> CGFloat {
        // Determine height of buttons
        return UIScreen.main.bounds.width / 5
    }
    
    func buttonFont() -> CGFloat {
        // Determine height of buttons
        return UIScreen.main.bounds.width / 10
    }

    func subbuttonFont() -> CGFloat {
        // Determine height of buttons
        return UIScreen.main.bounds.width / 16
    }
    

    
}

// Extension to define button colors and other properties
extension CalculatorButton {
    var backgroundColor: Color {
//        switch self {
//        case .add, .subtract, .multiply, .divide, .equal:
//            return Color(red: 0.0, green: 0.0, blue: 0.5)
//        case .clear, .plusMinus, .percent:
//            return Color.gray.opacity(0.5) // Slightly transparent
//        default:
//            return Color.blue // Normal buttons have a blue background

        return Color.clear
    }
    
    var foregroundColor: Color {
//        switch self {
//        case .add, .subtract, .multiply, .divide, .equal:
//            return Color.white
//        default:
//            return Color.black // Text color for normal buttons is black
//            
            return Color.blue
//        }
    }
}

struct NeonWeak: ViewModifier {
    var isNeoned: Bool
    
    func body(content: Content) -> some View {
        if isNeoned {
            content
                .shadow(color: Color.blue, radius: 20, x: 0, y: 0)
        } else {
            content
                .shadow(color: Color.blue, radius: 0, x: 0, y: 0)
        }
    }
}


struct Neon: ViewModifier {
    var isNeoned: Bool
    
    func body(content: Content) -> some View {
        if isNeoned {
            content
                .shadow(color: Color.blue, radius: 20, x: 0, y: 0)
                .shadow(color: Color.blue, radius: 20, x: 0, y: 0)
                .shadow(color: Color.blue.opacity(0.8), radius: 3, x: 0, y: 0)
        } else {
            content
                .shadow(color: Color.blue, radius: 0, x: 0, y: 0)
        }
    }
}



struct BlueShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.blue, radius: 20, x: 0, y: 0)
            .shadow(color: Color.blue, radius: 20, x: 0, y: 0)
            .shadow(color: Color.blue.opacity(0.8), radius: 3, x: 0, y: 0)
    }
}




struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView( )
            .previewInterfaceOrientation(.landscapeRight)
    }
}
