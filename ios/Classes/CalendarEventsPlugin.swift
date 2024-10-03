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
                result(FlutterError(code: "PERMISSION_DENIED", message: "Acceso al calendario denegado", details: nil))
                return
            }

            for eventInfo in events {
                let event = EKEvent(eventStore: self.eventStore)
                event.title = eventInfo["title"] as? String ?? "Evento sin título"

                // Imprimir el contenido de eventInfo para depuración
                print("eventInfo: \(eventInfo)")

                // Asegúrate de que startDate y endDate sean de tipo Double
                if let startDateTimestamp = eventInfo["startDate"] as? Double ?? (eventInfo["startDate"] as? String).flatMap({ Double($0) }),
                let endDateTimestamp = eventInfo["endDate"] as? Double ?? (eventInfo["endDate"] as? String).flatMap({ Double($0) }) {
                    event.startDate = Date(timeIntervalSince1970: startDateTimestamp / 1000)
                    event.endDate = Date(timeIntervalSince1970: endDateTimestamp / 1000)
                } else {
                    result(FlutterError(code: "INVALID_DATE", message: "La fecha de inicio o fin es inválida", details: nil))
                    return
                }

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
                    result(FlutterError(code: "EVENT_SAVE_ERROR", message: "Error al guardar el evento", details: error.localizedDescription))
                }
            }
            result("Eventos y recordatorios añadidos con éxito")
        }
    }

}
// <key>NSCalendarsUsageDescription</key>
// <string>Esta aplicación necesita acceso al calendario para agregar eventos.</string>
