import Foundation
import Models
import Contracts
import Extensions

print("This is just a playground for trying things out... (hence, not a client program).")

func xyz(input: Codable) {
    print("----------")
    print(input.self)
    print("----------")
}

func abc<I: Codable>(input: I) {
    print("----------")
    print(I.self)
    print("----------")
}

let user = User(id: 1234, name: "name")
print("----------")
print(user.self)
print("----------")
xyz(input: user)
abc(input: user)

let closure1: (_ p1: String, _ p2: Int) -> Void = { (p1, p2) -> Void in
    print("in closure... \(p1)")
}

let closure2 = { (p1: String, p2: Int) -> Void in
    print("in closure... \(p1)")
}

let closure3 = { (p1: String, p2: Int...) -> Void in
    print("in closure... \(p1)")
}

closure2("hello", 22)
closure3("hello", 22, 272, 2892)

func test(a1: String..., b1: Int, c1: Float) {
    //empty method
}

test(a1: "", "", "", b1: 1, c1: 2.3)
let routes: [String] = ["users", ":int", "orders", ":string"]
let route = "/" + routes.joined(separator: "/")
print("route: \(route)")

let json = """
{
 "name": "John Doe",
}
""".data(using: .utf8)! // our data in native (JSON) format

let testObj1: Test = try! JSONDecoder().decode(Test.self, from: json)
print("testObj1: \(testObj1)")

let testOb2: Test = Test(name: "testName")
let testType = type(of: testOb2)
let testObj3: Test = try! JSONDecoder().decode(testType.self, from: json)
print("testObj3: \(testObj3)")

//let anyType = testType as Any.Type
//let testObj4: Test = try! JSONDecoder().decode(anyType.self, from: json) // does not compile since T must conform to Decodable
// http://inessential.com/2015/07/20/swift_diary_1_class_or_struct_from_str :-/
let clazz: AnyClass? = NSClassFromString("Models.AuthUser")
print("clazz = \(clazz!)")

let encoder = JSONEncoder()
struct Foo : Encodable {
    let date: Date
    let name: String = "fooName"
}

let foo = Foo(date: Date())
let data = try! encoder.encode(foo)
print("data: \(data)")

// Prototyping...
func func3(param: String) { }
func func4<A: CustomStringConvertible>(param: A) { 
    //print("size: \(param.count)") // this line won't compile as expected
}
func func5<A: CustomStringConvertible>(param: [A]) { print("size: \(param.count)") }
let a: [String] = ["h1", "h2", "h3"]
//func3(param: a)   // this won't compile, as expected (we are passing an array)
func4(param: a)     // this does compile, though I was initially expecting this to not compile
func5(param: a)     // this compiles as expected

// Let's now also look at this

// aliases
public typealias CodableResultClosure<O: Codable> = (O?, Error?) -> Void
public typealias CodableArrayResultClosure<O: Codable> = ([O]?, Error?) -> Void

// sample usage
func func1<O: Codable>(param1: String, closure: @escaping CodableResultClosure<O>) { }


func func2<O: Codable>(param1: String, closure: @escaping CodableArrayResultClosure<O>) { }

let closureA: (User?, Error?) -> Void = { (user, error) -> Void in
    // the code does not compile, as expected
    // if let users = users {
    //     print(users.count)
    // }
}

let closureB: ([User]?, Error?) -> Void = { (users, error) -> Void in
    // the code below compiles without having to cast to an array (as expected)
    if let users = users {
        print(users.count)
    }
}

func1(param1: "a string", closure: closureA)
func2(param1: "a string", closure: closureB)
//func2(param1: "a string", closure: closureA)  // this does not not compile, as expected
func1(param1: "a string", closure: closureB)    //this compiles (as the above example), which I, initially, find odd.


class MyTest {
    func get<O: Codable>(param1: String, closure: @escaping CodableResultClosure<O>) { }
    func get<O: Codable>(param1: String, closure: @escaping CodableArrayResultClosure<O>) { }
}

let myTest = MyTest()
myTest.get(param1: "", closure: closureA)
myTest.get(param1: "", closure: closureB)

let closureMirror = Mirror(reflecting: closureB)
print("closureMirror: \(closureMirror)")
print("closureMirror.children: \(closureMirror.children)")
//print("closureMirror.displayStyle: \(closureMirror.displayStyle)")
print("closureMirror.subjectType: \(closureMirror.subjectType)")

let url = URL(string: "http://user:password@localhost:8080")
print("url: \(url!)")
print("url: \(url!.user!)")
print("url: \(url!.password!)")

let userQuery = UserQuery(category: "category1", date: Date(), weight: 23.39, start: 10, end: 15)
let rawDict = userQuery.rawDictionary
print("rawDict: \(rawDict)")
print("string: \(userQuery.string)")
let blah: Any? = nil

let intArray: [Int] = [1,2,3]
print(type(of: intArray))

print("==========Decoding with dictionary (instead of data) ==========")
let dict: [String : String] = ["optionalIntField": "282", "intField": "23", "stringField": "a string", "intArray" : "1,2,3", "dateField" : "2017-10-31T16:15:56+0000", "optionalDateField" : "2017-10-31T16:15:56+0000", "nested": "{\"nestedIntField\":333,\"nestedStringField\":\"nested string\"}" ]
let myQuery1 = try QueryDecoder(dictionary: dict).decode(MyQuery.self)
print("============Done============")
print(myQuery1)
print(myQuery1.intField)
print(myQuery1.stringField)
print(myQuery1.intArray)
print(myQuery1.dateField)
print(myQuery1.optionalDateField!)
print(myQuery1.optionalIntField!)
print(myQuery1.nested)

print("==========Encoding query object to dictionary ==========")
let myQuery1Dict: [String : String] = try QueryEncoder().encode(myQuery1)
print("myQuery1Dict: \(myQuery1Dict)")
let myQuery1Str: String = try QueryEncoder().encode(myQuery1)
print("myQuery1Str: \(myQuery1Str)")
print("============Done============")


var myDictionary: [String : Codable] = [:]

myDictionary["key1"] = 1
myDictionary["key2"] = "value2"
myDictionary["key3"] = myQuery1
print(myDictionary["key1"]!)
print(myDictionary["key2"]!)
print(myDictionary["key3"]!)

