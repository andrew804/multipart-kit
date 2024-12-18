import Foundation
import NIOCore

/// Encodes `Encodable` items to `multipart/form-data` encoded `Data`.
///
/// See [RFC#2388](https://tools.ietf.org/html/rfc2388) for more information about `multipart/form-data` encoding.
///
/// Seealso `MultipartParser` for more information about the `multipart` encoding.
public struct FormDataEncoder: Sendable {

    /// Any contextual information set by the user for encoding.
    public var userInfo: [CodingUserInfoKey: any Sendable] = [:]

    /// Creates a new `FormDataEncoder`.
    public init() { }

    /// Encodes an `Encodable` item to `String` using the supplied boundary.
    ///
    ///     let a = Foo(string: "a", int: 42, double: 3.14, array: [1, 2, 3])
    ///     let data = try FormDataEncoder().encode(a, boundary: "123")
    ///
    /// - Parameters:
    ///     - encodable: An `Encodable` item.
    ///     - boundary: The multipart boundary to use for encoding. This string must not appear in the encoded data.
    /// - Throws: Any errors encoding the model with `Codable` or serializing the data.
    /// - Returns: A `multipart/form-data`-encoded `String`.
    public func encode(_ encodable: some Encodable, boundary: String) throws -> String {
        try MultipartSerializer().serialize(parts: parts(from: encodable), boundary: boundary)
    }
    
    /// Encodes an `Encodable` item to `Data` using the supplied boundary.
    ///
    ///     let a = Foo(string: "a", int: 42, double: 3.14, array: [1, 2, 3])
    ///     let data = try FormDataEncoder().encodeToData(a, boundary: "123")
    ///
    /// - Parameters:
    ///     - encodable: An `Encodable` item.
    ///     - boundary: The multipart boundary to use for encoding. This string must not appear in the encoded data.
    /// - Throws: Any errors encoding the model or serializing the data.
    /// - Returns: A `multipart/form-data`-encoded `String`.
    public func encodeToData(_ encodable: some Encodable, boundary: String) throws -> Data {
        try MultipartSerializer().serializeToData(parts: parts(from: encodable), boundary: boundary)
    }

    /// Encodes an `Encodable` item into a `ByteBuffer` using the supplied boundary.
    ///
    ///     let a = Foo(string: "a", int: 42, double: 3.14, array: [1, 2, 3])
    ///     var buffer = ByteBuffer()
    ///     let data = try FormDataEncoder().encode(a, boundary: "123", into: &buffer)
    ///
    /// - Parameters:
    ///     - encodable: An `Encodable` item.
    ///     - boundary: The multipart boundary to use for encoding. This string must not appear in the encoded data.
    ///     - buffer: Buffer to write to.
    /// - Throws: Any errors encoding the model with `Codable` or serializing the data.
    public func encode(_ encodable: some Encodable, boundary: String, into buffer: inout ByteBuffer) throws {
        try MultipartSerializer().serialize(parts: parts(from: encodable), boundary: boundary, into: &buffer)
    }

    private func parts(from encodable: some Encodable) throws -> [MultipartPart] {
        let encoder = Encoder(codingPath: [], userInfo: userInfo)
        try encodable.encode(to: encoder)
        return encoder.storage.data?.namedParts() ?? []
    }
}
