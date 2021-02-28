import Foundation

public protocol Persisting {
    init()
    func get(key: String) throws -> Data?
    func set(key: String, to data: Data) throws
    func remove(key: String)
}
