//
//  IORegistry.swift
//  IOExplorer
//
//  Created by Svetoslav on 08.08.2023.
//

import Foundation

final class IORegistry {
    private var plane = kIOServicePlane

    func enumerateEntries(for plane: IORegistryPlane) -> IORegistryEntry {
        self.plane = plane.ioKitPlane

        let rootEntry = IORegistryGetRootEntry(kIOMainPortDefault)
        return getEntryInfo(rootEntry)
    }

    private func getEntryInfo(_ entry: io_registry_entry_t) -> IORegistryEntry {
        let id = getEntryId(entry) ?? 0
        let name = getEntryName(entry) ?? "Root"
        let path = getEntryPath(entry)
        let className = getEntryClassName(entry)
        let properties = Self.convertDicionary(getEntryProperties(entry) ?? NSDictionary())

        let kernelRetainCount = getEntryKernelRetainCount(entry)

        let childs = getEntryChilds(entry)

        return IORegistryEntry(
            id: id,
            name: name,
            className: className,
            path: path,
            kernelRetainCount: Int(kernelRetainCount),
            properties: properties,
            childs: childs
        )
    }

    private func getEntryChilds(_ entry: io_registry_entry_t) -> [IORegistryEntry] {
        var childs: [IORegistryEntry] = []

        var iterator = io_iterator_t()
        let result = IORegistryEntryGetChildIterator(
            entry,
            plane,
            &iterator
        )

        guard result == kIOReturnSuccess else {
            print("Error IORegistryEntryGetChildIterator")
            return childs
        }

        var childEntry = IOIteratorNext(iterator)
        while childEntry != 0 {
            childs.append(getEntryInfo(childEntry))
            IOObjectRelease(childEntry)
            childEntry = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)

        return childs
    }

    private func getBusyState(_ entry: io_registry_entry_t) -> UInt32 {
        var busy: UInt32 = 0
        guard IOServiceGetBusyState(entry, &busy) == kIOReturnSuccess else {
            print("Error IOServiceGetBusyState")
            return busy
        }
        return busy
    }

    private func getEntryKernelRetainCount(_ entry: io_registry_entry_t) -> UInt32 {
        IOObjectGetKernelRetainCount(entry)
    }

    private func getEntryClassName(_ entry: io_registry_entry_t) -> String? {
        let className = UnsafeMutablePointer<io_string_t>.allocate(capacity: 1)
        let classNamePtr = UnsafeMutableRawPointer(className).bindMemory(to: Int8.self, capacity: 1)

        guard IOObjectGetClass(entry, classNamePtr) == kIOReturnSuccess else {
            print("Error IOObjectGetClass")
            return nil
        }

        return String(cString: UnsafeRawPointer(classNamePtr).assumingMemoryBound(to: CChar.self))
    }

    private func getEntryId(_ entry: io_registry_entry_t) -> Int? {
        var id: UInt64 = 0
        guard IORegistryEntryGetRegistryEntryID(entry, &id) == kIOReturnSuccess else {
            return nil
        }

        return Int(id)
    }

    private func getEntryPath(_ entry: io_registry_entry_t) -> String? {
        let pathName = UnsafeMutablePointer<io_string_t>.allocate(capacity: 1)
        let namePtr = UnsafeMutableRawPointer(pathName).bindMemory(to: Int8.self, capacity: 1)

        guard IORegistryEntryGetPath(entry, plane, namePtr) == kIOReturnSuccess else {
            print("Error IORegistryEntryGetPath")
            return nil
        }

        return String(cString: UnsafeRawPointer(namePtr).assumingMemoryBound(to: CChar.self))
    }

    private func getEntryLocation(_ entry: io_registry_entry_t) -> String? {
        let location = UnsafeMutablePointer<io_string_t>.allocate(capacity: 1)
        let locationPtr = UnsafeMutableRawPointer(location).bindMemory(to: Int8.self, capacity: 1)

        guard IORegistryEntryGetLocationInPlane(entry, plane, locationPtr) == kIOReturnSuccess else {
            print("Error IORegistryEntryGetLocationInPlane")
            return nil
        }

        return String(cString: UnsafeRawPointer(locationPtr).assumingMemoryBound(to: CChar.self))
    }

    private func getEntryName(_ entry: io_registry_entry_t) -> String? {
        let pointer = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)

        let result = IORegistryEntryGetName(entry, pointer)
        if result != kIOReturnSuccess {
            print("Error IORegistryEntryGetName(): "
                  + (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
            return nil
        }

        return String(cString: UnsafeRawPointer(pointer).assumingMemoryBound(to: CChar.self))
    }

    private func getEntryProperties(_ entry: io_registry_entry_t) -> NSDictionary? {
        var properties: Unmanaged<CFMutableDictionary>?
        defer {
            properties?.release()
        }

        guard IORegistryEntryCreateCFProperties(entry, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess else {
            return nil
        }

        return properties?.takeUnretainedValue()
    }

    private static func convertDicionary(_ dictionary: NSDictionary) -> [EntryProperty] {
        var result: [EntryProperty] = []

        dictionary.allKeys.forEach { key in
            guard let name = key as? String, let value = dictionary[key] else {
                return
            }
            result.append(.init(name: name, value: convertAny(value)))
        }

        return result
    }

    private static func convertAny(_ value: Any) -> EntryProperty.Value {
        switch value {
            case let value as String:
                return .string(value)
            case let value as Bool:
                return .string(String(value))
            case let value as NSNumber:
                return .string(String(format: "0x%02x", value.intValue))
            case let value as Data:
                return .data(value)
            case let value as NSDictionary:
                return .property(convertDicionary(value))
            case let value as [Any]:
                return .array(value.map(convertAny))
            default:
                print("Unknown: \(type(of: value)) \(value)")
                return .unknown(value)
        }
    }
}
