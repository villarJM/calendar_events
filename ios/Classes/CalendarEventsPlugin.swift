import EventKit
import Flutter
import UIKit

public class CalendarEventsPlugin: NSObject, FlutterPlugin {
    var eventStore = EKEventStore()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "calendar_events", binaryMessenger: registrar.messenger())
        let instance = CalendarEventsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "addEvents" {
            guard let args = call.arguments as? [String: Any], let events = args["events"] as? [[String: Any]] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments passed", details: nil))
                return
            }
            addEventsToCalendar(events: events, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func addEventsToCalendar(events: [[String: Any]], result: @escaping FlutterResult) {
        // Solicitar permiso para acceder a los calendarios
        eventStore.requestAccess(to: .event) { (granted, error) in
            if !granted {
                result(FlutterError(code: "PERMISSION_DENIED", message: "Access to calendar denied", details: nil))
                return
            }

            for eventInfo in events {
                let event = EKEvent(eventStore: self.eventStore)
                event.title = eventInfo["title"] as? String ?? "Evento sin título"
                event.startDate = Date(timeIntervalSince1970: (eventInfo["startDate"] as! Double) / 1000)
                event.endDate = Date(timeIntervalSince1970: (eventInfo["endDate"] as! Double) / 1000)
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                
                // Guardar el evento
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                    
                    // Agregar recordatorio 10 minutos antes (o tiempo definido por el usuario)
                    let reminderMinutes = eventInfo["reminder"] as? Int ?? 10 // Por defecto 10 minutos antes
                    let alarm = EKAlarm(relativeOffset: TimeInterval(-reminderMinutes * 60)) // Tiempo en segundos antes del evento
                    event.addAlarm(alarm)
                    
                    try self.eventStore.save(event, span: .thisEvent)
                    
                    print("Evento y recordatorio añadidos")
                } catch let error {
                    result(FlutterError(code: "EVENT_SAVE_ERROR", message: "Failed to save event", details: error.localizedDescription))
                }
            }
            result("Events and reminders added successfully")
        }
    }
}

// <key>NSCalendarsUsageDescription</key>
// <string>Esta aplicación necesita acceso al calendario para agregar eventos.</string>
