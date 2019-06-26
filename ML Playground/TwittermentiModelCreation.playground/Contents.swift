import Cocoa
import CreateML

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/cassiomgoulart/Workspace/Learning/Twittermenti/ML Dataset/twitter-sanders-apple3.csv"))

let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 155) // 155

let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "class")

let evaluationMetrics = sentimentClassifier.evaluation(on: testingData)

let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100

let metadata = MLModelMetadata(author: "Cássio Goulart", shortDescription: "A model trained to classify sentiment on @Apple Tweets", version: "1.0")

try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/cassiomgoulart/Workspace/Learning/Twittermenti/ML Dataset/TwittermentiClassifier.mlmodel"))

try sentimentClassifier.prediction(from: "Ow my God this game is terrific!")

try sentimentClassifier.prediction(from: "Oh my God this game is fantastic!")

try sentimentClassifier.prediction(from: "This is soooo good!")

try sentimentClassifier.prediction(from: "I guess this is ok")

try sentimentClassifier.prediction(from: "@Apple is doing a great job with those ML Tools! I'm thrilled!")

try sentimentClassifier.prediction(from: "Oh my God this game is fantastic! :)")

try sentimentClassifier.prediction(from: "Oh my God this game is fantastic! :D")

try sentimentClassifier.prediction(from: "Oh my God this game is fantastic! :(")
