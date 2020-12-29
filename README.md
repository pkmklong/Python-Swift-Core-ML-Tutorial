<b>Deploy a Python Machine Learning Model on iOS in 5 Steps</b>
<br><i>A minimalist guide</i>


Our goal here is the shortest path from training a python model to a proof of concept iOS app you can deploy on an iPhone. We’ll create the basic scaffolding and leave plenty of room for further customization such as model selection and validation, code testing and a more polished UI.

<b>STEP 1.</b> Set up your environment
<br>From the terminal run:

 ```
$ python3 -m venv ~/.core_ml_demo
$ source  ~/.core_ml_demo/bin/activate
$ python3 -m pip install \
pandas==1.1.1 \
scikit-learn==0.19.2 \
coremltools==4.0
```

And install Xcode. <i>-This guide uses Xcode Version 12.3 (12C33) on macOS Catalina 10.15.5.</i>

[Xcode Install](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

<b>STEP 2.</b> Train a model
<br>We’ll use sklearn’s Boston Housing Price toy dataset to train a linear regression model. For simplicity, we’ll limit the feature space to 3 predictors.
```python
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.datasets import load_boston

# Load data
boston = load_boston()
boston_df = pd.DataFrame(boston["data"] )
boston_df.columns = boston["feature_names"]
boston_df["PRICE"]= boston["target"]

y = boston_df["PRICE"]
X = boston_df.loc[:,["RM", "AGE", "PTRATIO"]]

# Train a model
lm = LinearRegression()
lm.fit(X, y)
```
<b>STEP 3.</b> Convert the model to Core ML
<br>Next, we’ll use the coremltools package to convert our python model to the Core ML format (.mlmodel) for use in Xcode.
```python
# Convert sklearn model to CoreML
import coremltools as cml

model = cml.converters.sklearn. \
convert(lm,
        ["RM", "AGE", "PTRATIO"],
        "PRICE")

# Assign model metadata
model.author = "Medium Author"
model.license = "MIT"
model.short_description = \
"Predicts house price in Boston"

# Assign feature descriptions
model.input_description["RM"] = \
"Number of bedrooms"
model.input_description["AGE"] = \
"Proportion of units built pre 1940"
model.input_description["PTRATIO"] = \
"Pupil-teacher ratio by town"
# Assign the output description
model.output_description["PRICE"] = \
"Median Value in 1k (USD)"

# Save model
model.save('bhousing.mlmodel')
```
<b>STEP 4.</b> Start a new Xcode project
<br>And that’s it for python. From hereon, we can complete a basic app using Xcode and Swift. This can be done with the setup below.
<br><i>Create a new Xcode project and choose “App.”</i>
![](https://github.com/pkmklong/IOS_CoreML/blob/main/start_xcode_1.png)
<i>Name your project and select the “SwiftUI” Interface.</i>
![](https://github.com/pkmklong/IOS_CoreML/blob/main/start_xcode_2.png)
<i>Drag and drop the <b>.mlmodel</b> file saved above into your Xcode directory. This automatically generates a Swift class for your model as shown in the editor below.</i>
![](https://github.com/pkmklong/IOS_CoreML/blob/main/start_xcode_3.png)

<b>STEP 5.</b> Build a model UI
<br>Next we’ll build a basic UI by modifying the <b>ContentView.swift</b> file. The code below sets up a UI to input house attributes and generate a price prediction. The key elements here include [stepper structs](https://developer.apple.com/documentation/swiftui/stepper) that enable user input (lines 19–30) and a call to our trained model to predict house price. Steppers are basically widgets that modify the [state](https://developer.apple.com/documentation/swiftui/state) of our house attribute variables (lines 6–8). A [button](https://www.simpleswiftguide.com/how-to-add-button-to-navigation-bar-in-swiftui/) on the navigation bar (line 31–40) calls our model from within the predictPrice function (line 46). This produces an [alert message](https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-an-alert) with the predicted price.
```swift
import SwiftUI
import CoreML
import Foundation

struct ContentView: View {
  @State private var rm = 6.5
  @State private var age = 84.0
  @State private var ptratio = 16.5
    
  @State private var alertTitle = ""
  @State private var alertMessage = ""
  @State private var showingAlert = false
    
  var body: some View {
      NavigationView {
        VStack {
        Text("House Attributes")
            .font(.title)
        Stepper(value: $rm, in: 1...10,
                step: 0.5) {
            Text("Rooms: \(rm)")
          }
          Stepper(value: $age, in: 1...100,
              step: 0.5) {
          Text("Age: \(age)")
          }
          Stepper(value: $ptratio, in: 12...22,
              step: 0.5) {
          Text("Pupil-teacher ratio: \(ptratio)")
          }
          .navigationBarTitle("Price Predictor")
          .navigationBarItems(trailing:
              Button(action: predictPrice) {
                  Text("Predict Price")
              }
          )
          .alert(isPresented: $showingAlert) {
              Alert(title: Text(alertTitle),
                    message: Text(alertMessage),
              dismissButton: .default(Text("OK")))
          }
        }
      }
  }
            
func predictPrice() {
    let model = bhousing()
    do { let p = try
      model.prediction(
          RM: Double(rm),
          AGE: Double(age),
          PTRATIO: Double(ptratio))

        alertMessage = "$\(String((p.PRICE * 1000)))"
      alertTitle = "The predicted price is:"
  } catch {
    alertTitle = "Error"
    alertMessage = "Please retry."
  }
    showingAlert = true
}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```
<br>Build and run a simulation in Xcode to see your app in action.

![](https://github.com/pkmklong/IOS_CoreML/blob/main/app_demo.gif)

<br>Thanks for reading!
<br>



TODO:<br>
* Refactor model training
* change model use case
* add unit tests
* update UI
* on device test
