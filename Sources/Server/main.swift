import Kitura
import KituraContracts
import RouterExtension
import Models

// Dictionay of Employee entities
var employeeStore: [Int: Employee] = [:]
var userStore: [Int: User] = [1: User(id: 1, name: "Mike"), 2: User(id: 2, name: "Chris"), 3: User(id: 3, name: "Ricardo")]
// Dictionary of Order entities
var orderStore: [Int: Order] = [1: Order(id: 1, name: "order1"), 2: Order(id: 2, name: "order2"), 3: Order(id: 3, name: "order3")]

let router = Router()

// Traditional routing style (nothing new here)
router.get("/basic") { (request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) in
    print("basic")
    response.status(.OK)
    next()
}

// A possible implementation for query params
// Codable routing with type-safe like query parameters - supports
// codable as a value assigned to a key in a query parameter
// arrays assigned to a single key
// localhost:8080/users?category=animal&percentage=65&tags=tag1&tags=tag2&weights=32&weights=34&object=%7B"name":"john"%7D&start=100&end=400
router.get("/users") { (queryParams: QueryParams, respondWith: ([User]?, RequestError?) -> Void) in
    print("GET on /orders with query parameters")

    if let category: String = queryParams["category"].string {
        print("category(str): \(category)")
    }

    if let percentage: Int = queryParams["percentage"].int {
        print("percentagek1(int): \(percentage)")
    }

    if let tags: [String] = queryParams["tags"].stringArray {
        print("tags(strs): \(tags)")
    }

    if let weights: [Int] = queryParams["weights"].intArray {
        print("weights(ints): \(weights)")
    }

    if let object: Test = queryParams["object"].codable(Test.self) {
        print("object(codable): \(object)")
    }

    if let start = queryParams["start"].int, let end = queryParams["end"].int {
        print("start: \(start), end: \(end)")
    }

    respondWith(userStore.map({ $0.value }), nil)
}

// A possible implementation for multiple route params - codable
// See the identifiers array and its type
// localhost:8080/customers/3233/orders/1
router.get("/customers/:id1/orders/:id2") { (identifiers: [Int], respondWith: (Order?, RequestError?) -> Void) in
    print("GET on /orders with query parameters")
    print("identifiers: \(identifiers)")
    let order = orderStore[identifiers[1]]
    respondWith(order, nil)
}

// Besides what we see above, we would also need an additional API method to address the need where we have
// queryParams and multiple identifiers...
// router.get("/objs1/:id1/objs2:id2") { (queryParams: QueryParams, identifiers: [Int], respondWith: ([O]?, RequestError?) -> Void) in

// Another possible approach for providing query params... though it seems cleaner to use QueryParams
router.get("route") { (queryParams: String..., respondWith: ([User]?, RequestError?) -> Void) in
    // this is not implemented...
    respondWith(userStore.map({ $0.value }), nil)
}

// A possible approach for URL parameters & codable
// We could also provide route params and query params as this: Params.route, Params.query
// Now... if we were to take this approach, I am then thinking  we should change the new codable API we just released... so that the route is specified in the same
// way we do below...
// localhost:8080/users/1234/orders/1VZXY3/entity/4398/entity2/234r234 - think more from an API perspecitve as opposed to thinking of it in terms of URL
router.get("users", Int.parameter, "orders", String.parameter) { (routeParams: RouteParams, queryParams: QueryParams, respondWith: ([Order]?, RequestError?) -> Void) in
    if let param1 = routeParams.next(Int.self) {
         print("route param1 (int): \(param1)")
    }
    if let param2 = routeParams.next(String.self) {
        print("route param2 (str): \(param2)")
    }
    
    respondWith(orderStore.map({ $0.value }), nil)
}

//localhost:8080/xyz?category=manager&weight=65&start=100&end=400
router.get("/xyz") { (query: UserQuery, respondWith: ([User]?, RequestError?) -> Void) in
    print("In xyz with UserQuery")
    if let category = query.category {
        print("category = \(category)")
    }
	
    // if let date = query.date {
    //     print("date = \(date)")
    // }
	
    if let weight = query.weight {
        print("weight = \(weight)")
    } 

    if let start = query.start {
        print("start = \(start)")
    }

    if let end = query.end {
        print("end = \(end)")
    }

    respondWith(userStore.map({ $0.value }), nil)
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8080, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
