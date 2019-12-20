@testable import BSON
import Nimble
import XCTest

final class BSONTests: XCTestCase {
    func testDocument() throws {
        let doc: Document = [
                                "double": 1.0,
                                "string": "hi",
                                "doc": ["a": 1],
                                "array": [1, 2],
                                "binary": .binary(try Binary(data: Data([0, 0, 0, 0]), subtype: .generic)),
                                "undefined": .undefined,
                                "objectid": .objectId(ObjectId()),
                                "false": false,
                                "true": true,
                                "date": .date(Date()),
                                "null": .null,
                                "regex": .regex(RegularExpression(pattern: "abc", options: "ix")),
                                "dbPointer": .dbPointer(DBPointer(ref: "foo", id: ObjectId())),
                                "symbol": .symbol("hi"),
                                "code": .code(Code(code: "xyz")),
                                "codewscope": .codeWithScope(CodeWithScope(code: "xyz", scope: ["a": 1])),
                                "int32": .int32(32),
                                "timestamp": .timestamp(Timestamp(timestamp: UInt32(2), inc: UInt32(3))),
                                "int64": 64,
                                "minkey": .minKey,
                                "maxkey": .maxKey,
                            ]
        // test we can convert to an array successfully
        _ = Array(doc)
    }

    func testBSONCorpus() throws {
        let testFilesPath = "./Tests/bson-corpus/tests"
        var testFiles = try FileManager.default.contentsOfDirectory(atPath: testFilesPath)
        testFiles = testFiles.filter { $0.hasSuffix(".json") }

        for fileName in testFiles {
            // unsupported type
            if fileName.contains("decimal128") { continue }

            let testFilePath = URL(fileURLWithPath: "\(testFilesPath)/\(fileName)")
            let testFileData = try Data(contentsOf: testFilePath)
            let testCase = try JSONDecoder().decode(BSONCorpusTestFile.self, from: testFileData)

            if let valid = testCase.valid {
                for v in valid {
                    let canonicalData = Data(hex: v.canonicalBSON)!

                    // native_to_bson( bson_to_native(cB) ) = cB
                    let canonicalDoc = try Document(fromBSON: canonicalData)
                    let canonicalDocAsArray = try canonicalDoc.toArray()
                    let roundTrippedCanonicalDoc = Document(fromArray: canonicalDocAsArray)
                    expect(roundTrippedCanonicalDoc).to(equal(canonicalDoc))

                    // native_to_bson( bson_to_native(dB) ) = cB
                    if let db = v.degenerateBSON {
                        let degenerateData = Data(hex: db)!
                        let degenerateDoc = try Document(fromBSON: degenerateData)
                        let degenerateDocAsArray = try degenerateDoc.toArray()
                        let roundTrippedDegenerateDoc = Document(fromArray: degenerateDocAsArray)
                        expect(roundTrippedDegenerateDoc).to(equal(canonicalDoc))
                    }
                }
            }

            if let decodeErrors = testCase.decodeErrors {
                for error in decodeErrors {
                    let badData = Data(hex: error.bson)!
                    do {
                        let badDoc = try Document(fromBSON: badData)
                        _ = try badDoc.toArray()
                    } catch {
                        expect(error).toNot(beNil())
                    }
                }
            }

            // todo: test parse errors once decimal128 is supported

            // todo: test parse errors from top.json once extJSON is supported
        }
    }

    func testEncoderDecoder() throws {
        let s = TestStruct(x: 1, y: "hi", z: true)
        let encoded = try BSONEncoder().encode(s)
        expect(encoded).to(equal(["x": 1, "y": "hi", "z": true]))

        let decoded = try BSONDecoder().decode(TestStruct.self, from: encoded)
        expect(decoded).to(equal(s))
    }
}

struct TestStruct: Codable, Equatable {
    let x: Int
    let y: String
    let z: Bool
}

extension Document {
    func toArray() throws -> [(String, BSON)] {
        var out = [(String, BSON)]()
        var iter = self.makeIterator()
        while let next = try iter.nextOrError() {
            out.append(next)
        }
        return out
    }

    init(fromArray array: [(String, BSON)]) {
        var out = Document()
        for (key, value) in array {
            out[key] = value
        }
        self = out
    }
}

struct BSONCorpusTestFile: Codable {
    let description: String
    let bsonType: String
    let testKey: String?
    let valid: [BSONCorpusTestCase]?
    let decodeErrors: [BSONCorpusDecodeError]?
    let parseErrors: [BSONCorpusParseError]?

    private enum CodingKeys: String, CodingKey {
        case description,
            bsonType = "bson_type",
            testKey = "test_key",
            valid,
            decodeErrors,
            parseErrors
    }
}

struct BSONCorpusTestCase: Codable {
    let description: String
    let canonicalBSON: String
    let degenerateBSON: String?
    let relaxedExtJSON: String?
    let canonicalExtJSON: String
    let convertedExtJSON: String?

    private enum CodingKeys: String, CodingKey {
        case description,
            canonicalBSON = "canonical_bson",
            degenerateBSON = "degenerate_bson",
            relaxedExtJSON = "relaxed_extjson",
            canonicalExtJSON = "canonical_extjson",
            convertedExtJSON = "converted_extjson"
    }
}

struct BSONCorpusDecodeError: Codable {
    let description: String
    let bson: String
}

struct BSONCorpusParseError: Codable {
    let description: String
    let string: String
}