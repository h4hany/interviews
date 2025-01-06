# Mongodb Interview Questions

## 1. What is MongoDB?

**Answer:**  
MongoDB is a NoSQL, document-oriented database that stores data in flexible, JSON-like format called BSON (Binary JSON).
It is designed to handle large volumes of unstructured data and is horizontally scalable.

## 2. What is the difference between MongoDB and SQL databases?

**Answer:**

- **SQL databases** use a relational model and store data in tables with predefined schemas.
- **MongoDB** is schema-less and stores data in collections of documents, which can vary in structure, providing more
  flexibility.

## 3. What is a document in MongoDB?

**Answer:**  
A document in MongoDB is a set of key-value pairs, often represented as a JSON-like object (BSON). It is analogous to a
row in SQL.

### Example:

```json
{
  "_id": ObjectId(
  "61c4a6d2a29d6a3b49521f5d"
  ),
  "name": "John Doe",
  "age": 29,
  "email": "john.doe@example.com"
}
```

## 4. What is a collection in MongoDB?

**Answer:**  
A collection in MongoDB is a group of MongoDB documents. It is equivalent to a table in SQL databases, but collections
do not enforce a schema.

## 5. Explain the concept of BSON.

**Answer:**  
BSON (Binary JSON) is a binary-encoded serialization format that MongoDB uses to store documents. BSON supports
additional data types not present in JSON, such as `ObjectId` and `Date`.

## 6. What is an `ObjectId` in MongoDB?

**Answer:**  
An `ObjectId` is a unique identifier for documents in MongoDB. It is a 12-byte identifier composed of:

- A 4-byte timestamp (seconds since the Unix epoch)
- A 5-byte random value
- A 3-byte incrementing counter

## 7. What are the advantages of MongoDB over relational databases?

**Answer:**

- **Flexible schema**: Allows for easy changes to the data structure.
- **Scalability**: MongoDB can be scaled horizontally by sharding.
- **Performance**: MongoDB can handle large volumes of data with high write throughput.
- **High availability**: Supports replica sets for automatic failover and redundancy.

## 8. What is sharding in MongoDB?

**Answer:**  
Sharding is the process of distributing data across multiple servers or clusters. This helps to scale horizontally and
manage large data sets efficiently.

## 9. What is a replica set in MongoDB?

**Answer:**  
A replica set is a group of MongoDB servers that maintain the same data set. It provides redundancy and high
availability, ensuring data remains accessible even if one or more servers fail.

## 10. What is the default port for MongoDB?

**Answer:**  
The default port for MongoDB is `27017`.

## 11. What is the difference between `find()` and `findOne()` in MongoDB?

**Answer:**

- `find()` retrieves all documents that match the query criteria and returns a cursor.
- `findOne()` retrieves the first document that matches the query criteria and returns the document directly.

## 12. What is an index in MongoDB?

**Answer:**  
An index in MongoDB is a data structure that improves the speed of data retrieval operations. MongoDB creates an index
for every field in a query to make the search process faster.

## 13. What are the different types of indexes in MongoDB?

**Answer:**

- **Single Field Index**: An index on a single field.
- **Compound Index**: An index on multiple fields.
- **Multikey Index**: An index on an array field.
- **Text Index**: Used for text search.
- **Geospatial Index**: Used for geospatial queries.

## 14. How does MongoDB handle concurrency control?

**Answer:**  
MongoDB uses a locking mechanism to ensure that multiple operations on the same data do not lead to conflicts. It uses *
*read and write locks** at the document level for concurrency control.

## 15. What is the `aggregate()` function in MongoDB?

**Answer:**  
The `aggregate()` function in MongoDB is used to process data records and return computed results. It allows performing
operations like filtering, sorting, grouping, and projecting.

### Example:

```javascript   
db.orders.aggregate([
    {$match: {status: "delivered"}},
    {$group: {_id: "$customerId", totalAmount: {$sum: "$amount"}}}
]);
```

## 16. What is a MongoDB schema?

**Answer:**  
A MongoDB schema defines the structure of documents within a collection. Unlike SQL, MongoDB does not enforce a schema,
so documents in the same collection can have different fields.

## 17. What is the `mapReduce()` function in MongoDB?

**Answer:**  
`mapReduce()` is a MongoDB function used for processing large volumes of data and returning computed results. It
performs a map step and a reduce step to aggregate data.

## 18. What is the difference between `update()` and `save()` in MongoDB?

**Answer:**

- `update()` modifies existing documents based on a query.
- `save()` inserts a new document if it doesn't exist or updates an existing document if the document’s `_id` field
  matches.

## 19. How does MongoDB handle data consistency?

**Answer:**  
MongoDB provides eventual consistency in a distributed setup, especially with replica sets. It offers **read preferences
** to balance consistency and availability depending on the application’s needs.

## 20. What are the benefits of using MongoDB?

**Answer:**

- **High performance** for both reads and writes.
- **Horizontal scalability** with sharding.
- **Flexible data model** with schema-less documents.
- **Rich querying** capabilities, including aggregation.
- **High availability** with replica sets.

## 21. What is the `MongoDB Atlas`?

**Answer:**  
MongoDB Atlas is a fully managed cloud database service provided by MongoDB. It handles tasks like backups, monitoring,
scaling, and security, and can run on AWS, Azure, and Google Cloud.

## 22. How would you handle large amounts of data in MongoDB?

**Answer:**

- **Sharding**: Split data across multiple servers to scale horizontally.
- **Indexes**: Create indexes on frequently queried fields to optimize performance.
- **Compression**: Use data compression to reduce storage requirements.
- **Aggregation Pipeline**: Use efficient aggregation pipelines for processing data.

## 23. What is a capped collection in MongoDB?

**Answer:**  
A capped collection is a fixed-size collection in MongoDB that automatically overwrites the oldest documents when it
reaches its maximum size. It is typically used for logging.

## 24. What is the `distinct()` function in MongoDB?

**Answer:**  
The `distinct()` function is used to find the distinct values for a given field across a collection. It returns an array
of unique values.

## 25. What is the `sort()` function in MongoDB?

**Answer:**  
The `sort()` function is used to sort the documents in a collection based on one or more fields in either ascending or
descending order.

## 26. What is the `upsert` operation in MongoDB?

**Answer:**  
The `upsert` operation is a combination of insert and update. If no document matches the query, it inserts a new
document; otherwise, it updates the existing document.

### Example:

```javascript
db.users.update(
    {email: "john.doe@example.com"},
    {$set: {age: 30}},
    {upsert: true}
);
```

## 27. What are the differences between `MongoDB` and `Cassandra`?

**Answer:**

- **MongoDB** is document-based, while **Cassandra** is a wide-column store.
- MongoDB supports complex queries, whereas Cassandra focuses on high write availability and scalability.
- MongoDB provides ACID transactions (with replica sets), while Cassandra prioritizes availability and partition
  tolerance.

## 28. What is a `tailable cursor` in MongoDB?

**Answer:**  
A tailable cursor is a special type of cursor used to query capped collections. It allows clients to iterate through the
collection as new documents are added.

## 29. What is the `write concern` in MongoDB?

**Answer:**  
Write concern defines the level of acknowledgment requested from MongoDB for write operations. It can be configured to
ensure data is written to a certain number of nodes or until a majority of replica set members acknowledge the
operation.


