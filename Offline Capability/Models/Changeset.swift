/**
 Struct to hold the data received by the database service containing information about changed items
 */
struct Changeset<T> {
    /** Array of received objects */
    var results: [T]
    /** Index of deleted objects in the result */
    var deleted: [Int]
    /** Index of inserted objects in the result */
    var inserted: [Int]
    /** Index of updated objects in the result */
    var updated: [Int]
}
