import UIKit
import Flutter
import HealthKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    var eventSinkGlobal: FlutterEventSink?
    var resultGlobal: FlutterResult?
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSinkGlobal = events
        self.readLatestData()
        if arguments as? String == "Stream" {
            
        }
        return nil
    }
    let healthStore = HKHealthStore()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let streamChannel = FlutterEventChannel(name: "com.tracker.bundisim/data_stream",
                                                        binaryMessenger: controller.binaryMessenger)
        streamChannel.setStreamHandler(self)
        let platformName = "com.tracker.bundisim/data"
        
        let platform = FlutterMethodChannel(
          name: platformName,
          binaryMessenger: controller.binaryMessenger)
        
          platform.setMethodCallHandler({ [self]
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
              resultGlobal = result
          switch call.method {
            case "getHealthInfo":
              self.healthPermission()
              
          case "readData":
              //Needs to return the dictionary with the data from the query
              self.readLatestData()
              
            default:
              result(FlutterMethodNotImplemented)
      }
    })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)

  }

//Function to gain permission from user to access health data
  func healthPermission() -> String {
      
      if #available(iOS 15.0, *) {
          if HKHealthStore.isHealthDataAvailable() {
              let healthStore = HKHealthStore()
              var authorized = true
              let walkingAsymmetryPercentage = HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!
              let appleWalkingSteadiness = HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)!
              let allTypes = Set([appleWalkingSteadiness,
                                  walkingAsymmetryPercentage
                                 ])
              healthStore.requestAuthorization(toShare: nil, read: allTypes) { (result, error) in
                  if let error = error {
                      authorized = false
                      return
                  }
                  if result {
                      self.resultGlobal!(true)
                              print("[HealthKit] request Authorization succeed!")
                          } else {
                              self.resultGlobal!(false)
                              print("[HealthKit] request Authorization failed!")
                          }
                  guard result else {
                      authorized = false
                      return
                  }
                  // do your stuff here
              }
              if(authorized){
                  
              return("Access to Health Data successfully granted")
              } else {
                  return("Access to Health Data successfully granted")
              }
          }
      }
      return ("iOS system is outdated")
  }
    
    //Read Data from assynchronous walking and get all the samples from the health data
    func readLatestData()  {
        var arrayPercentages = [Double]()
        var arrayOccurDates = [Date]()
        if #available(iOS 15.0, *) {
            guard let sampleType = HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage) else {
                return
            }
            let startDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) {(sample,result, error ) in
                guard error == nil else {
                    return
                }
                if let result = result {
                    var resultDictionairy = [String: String]()
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US")
                    dateFormatter.dateFormat = "HH:mm, MM-dd-yyyy"
                    for entry in result as? [HKQuantitySample] ?? []{
                        let value = entry.quantity.doubleValue(for: HKUnit.percent())
                        let occurDate = entry.startDate
                        arrayPercentages.append(value)
                        arrayOccurDates.append(occurDate)
                        var testvalue = dateFormatter.string(from: occurDate)
                        //Fill each sample into a global dictionary using the date as key and the percetnage as value
                        resultDictionairy[testvalue] = String(format: "%.2f", value)
                       
                    }
                    guard let eventSinkGlobal = self.eventSinkGlobal else {
                          return
                        }
                    //Dictionary into JSON Conversion :https://stackoverflow.com/questions/29625133/convert-dictionary-to-json-in-swift

                    let encoder = JSONEncoder()
                    if let jsonData = try? encoder.encode(resultDictionairy) {
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            eventSinkGlobal(jsonString)
                        }
                    }
                }
                return
            }
            healthStore.execute(query)
            
            
        }
       
    }
}
   
    






