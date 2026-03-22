# Mongodb Interview Questions

## 1. What is MongoDB?

**Answer:**  
MongoDB is a NoSQL, document-oriented database that stores data in flexible, JSON-like format called BSON (Binary JSON).
It is designed to handle large volumes of unstructured data and is horizontally scalable.

## 2. What is the difference between MongoDB and SQL databases?

**Answer:**

- **SQL databases** use a relational model and store data in tables with predefined schemas.
- **MongoDB** is schema-less and stores data in collections of documents, which can vary in structure.
    - *Example*: A User document can have `social_links` for Twitter and LinkedIn, while another user in the same collection only has `email`, without needing a database migration.

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
- *Example*: In a 3-node replica set, if the Primary node crashes, the other two nodes hold an election and one becomes the new Primary, ensuring your app stays online with minimal downtime.

## 10. What is the default port for MongoDB?

**Answer:**  
The default port for MongoDB is `27017`.

## 11. What is the difference between `find()` and `findOne()` in MongoDB?

**Answer:**

- `find()` retrieves all documents that match the query criteria and returns a cursor.
- `findOne()` retrieves the first document that matches the query criteria and returns the document directly.

## 12. What is an index in MongoDB?

**Answer:**  
An index in MongoDB is a data structure that improves the speed of data retrieval operations.
- *Example*: Searching for a user by `email` in a collection of 10 million users might take 5 seconds without an index (scanning every document), but only 5 milliseconds with an index.

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
reaches its maximum size.
- *Example*: Storing the last 10,000 lines of application logs. Once the 10,001st log comes in, the 1st log is automatically deleted to make room.

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

### Example:
```javascript
db.orders.insert(
    { order_id: 123, total: 100 },
    { writeConcern: { w: "majority", wtimeout: 5000 } }
);
```

## 30. What is the difference between `findOneAndUpdate()` and `updateOne()` in MongoDB?

**Answer:**
- **`findOneAndUpdate()`**: Atomically finds a document and updates it, returning the original or updated document based on options.
- **`updateOne()`**: Updates a single document matching the filter but doesn't return the document.

```javascript
// findOneAndUpdate - returns the document
db.users.findOneAndUpdate(
    { email: "user@example.com" },
    { $set: { status: "active" } },
    { returnDocument: "after" }
);

// updateOne - returns update result
db.users.updateOne(
    { email: "user@example.com" },
    { $set: { status: "active" } }
);
```

## 31. What is the `$lookup` operator in MongoDB aggregation?

**Answer:**  
The `$lookup` operator performs a left outer join between two collections, allowing you to combine documents from different collections based on a common field.

### Example:
```javascript
db.orders.aggregate([
    {
        $lookup: {
            from: "users",
            localField: "user_id",
            foreignField: "_id",
            as: "user_details"
        }
    }
]);
```

## 32. What is the difference between `insertOne()` and `insertMany()` in MongoDB?

**Answer:**
- **`insertOne()`**: Inserts a single document into a collection.
- **`insertMany()`**: Inserts multiple documents in a single operation, which is more efficient than multiple `insertOne()` calls.

```javascript
// insertOne
db.users.insertOne({ name: "John", email: "john@example.com" });

// insertMany
db.users.insertMany([
    { name: "John", email: "john@example.com" },
    { name: "Jane", email: "jane@example.com" }
]);
```

## 33. What is the `$unwind` operator in MongoDB aggregation?

**Answer:**  
The `$unwind` operator deconstructs an array field from input documents and outputs one document for each element of the array.

### Example:
```javascript
db.orders.aggregate([
    { $unwind: "$items" },
    { $group: { _id: "$items.product", total: { $sum: "$items.quantity" } } }
]);
```

## 34. What is the difference between `deleteOne()` and `deleteMany()` in MongoDB?

**Answer:**
- **`deleteOne()`**: Deletes the first document that matches the filter criteria.
- **`deleteMany()`**: Deletes all documents that match the filter criteria.

```javascript
// deleteOne - deletes first matching document
db.users.deleteOne({ status: "inactive" });

// deleteMany - deletes all matching documents
db.users.deleteMany({ status: "inactive" });
```

## 35. What is the `$group` operator in MongoDB aggregation?

**Answer:**  
The `$group` operator groups documents by a specified expression and applies accumulator expressions to compute aggregated values.

### Example:
```javascript
db.orders.aggregate([
    {
        $group: {
            _id: "$customer_id",
            total_amount: { $sum: "$amount" },
            order_count: { $sum: 1 }
        }
    }
]);
```

## 36. What is the difference between `find()` and `findOne()` performance?

**Answer:**
- **`findOne()`**: Stops after finding the first matching document, which can be faster for queries where you only need one result.
- **`find()`**: Returns a cursor that can iterate through all matching documents, which is more efficient for processing multiple documents.

## 37. What is the `$match` operator in MongoDB aggregation?

**Answer:**  
The `$match` operator filters documents to pass only those that match the specified condition(s) to the next pipeline stage. It's similar to the `WHERE` clause in SQL.

### Example:
```javascript
db.orders.aggregate([
    { $match: { status: "completed", amount: { $gt: 100 } } },
    { $group: { _id: "$customer_id", total: { $sum: "$amount" } } }
]);
```

## 38. What is the `$project` operator in MongoDB aggregation?

**Answer:**  
The `$project` operator reshapes documents by including, excluding, or adding new fields. It's similar to the `SELECT` clause in SQL.

### Example:
```javascript
db.users.aggregate([
    {
        $project: {
            name: 1,
            email: 1,
            full_name: { $concat: ["$first_name", " ", "$last_name"] }
        }
    }
]);
```

## 39. What is the difference between `$push` and `$addToSet` in MongoDB update operations?

**Answer:**
- **`$push`**: Adds a value to an array field, even if the value already exists (allows duplicates).
- **`$addToSet`**: Adds a value to an array field only if it doesn't already exist (no duplicates).

```javascript
// $push - allows duplicates
db.users.updateOne(
    { _id: 1 },
    { $push: { tags: "developer" } }
);

// $addToSet - no duplicates
db.users.updateOne(
    { _id: 1 },
    { $addToSet: { tags: "developer" } }
);
```

## 40. What is the `$inc` operator in MongoDB?

**Answer:**  
The `$inc` operator increments a field by a specified value. It's commonly used for counters, scores, or any numeric field that needs to be incremented atomically.

### Example:
```javascript
db.products.updateOne(
    { _id: 1 },
    { $inc: { stock: -1 } }  // Decrement stock by 1
);
```

## 41. What is the difference between embedded documents and references in MongoDB?

**Answer:**
- **Embedded Documents**: Store related data within a single document. *Example*: Storing "Line Items" inside an "Order" document because they are always read together.
- **References**: Store references (ObjectIds) to other documents. *Example*: Storing a `user_id` inside an "Order" document because a user can have thousands of orders, and you don't want to bloat the User document.

### Example:
```javascript
// Embedded (denormalized)
{
    _id: 1,
    name: "John",
    address: {
        street: "123 Main St",
        city: "New York"
    }
}

// Reference (normalized)
// users collection
{ _id: 1, name: "John", address_id: ObjectId("...") }
// addresses collection
{ _id: ObjectId("..."), street: "123 Main St", city: "New York" }
```

## 42. What is the `$set` operator in MongoDB?

**Answer:**  
The `$set` operator sets the value of a field in a document. If the field doesn't exist, it creates it. If it exists, it updates the value.

### Example:
```javascript
db.users.updateOne(
    { _id: 1 },
    { $set: { status: "active", last_login: new Date() } }
);
```

## 43. What is the `$unset` operator in MongoDB?

**Answer:**  
The `$unset` operator removes a field from a document.

### Example:
```javascript
db.users.updateOne(
    { _id: 1 },
    { $unset: { temporary_field: "" } }
);
```

## 44. What is the difference between `$or` and `$and` operators in MongoDB?

**Answer:**
- **`$or`**: Returns documents that match at least one of the specified conditions.
- **`$and`**: Returns documents that match all of the specified conditions (implicitly used when multiple conditions are in the same object).

```javascript
// $or - matches if any condition is true
db.users.find({
    $or: [
        { status: "active" },
        { age: { $gt: 18 } }
    ]
});

// $and - matches if all conditions are true
db.users.find({
    $and: [
        { status: "active" },
        { age: { $gt: 18 } }
    ]
});
```

## 45. What is the `$exists` operator in MongoDB?

**Answer:**  
The `$exists` operator matches documents that have or don't have a specified field.

### Example:
```javascript
// Find documents with email field
db.users.find({ email: { $exists: true } });

// Find documents without email field
db.users.find({ email: { $exists: false } });
```

## 46. What is the `$regex` operator in MongoDB?

**Answer:**  
The `$regex` operator provides regular expression pattern matching for string fields.

### Example:
```javascript
// Find users with email containing "gmail"
db.users.find({ email: { $regex: /gmail/i } });

// Alternative syntax
db.users.find({ email: /gmail/i });
```

## 47. What is the difference between `$elemMatch` and regular array queries in MongoDB?

**Answer:**
- **Regular array queries**: Match documents where any element in the array satisfies the condition.
- **`$elemMatch`**: Matches documents where a single array element satisfies all specified conditions.

```javascript
// Regular query - matches if any element satisfies
db.users.find({ scores: { $gt: 80 } });

// $elemMatch - matches if one element satisfies all conditions
db.users.find({
    scores: {
        $elemMatch: { $gt: 80, $lt: 90 }
    }
});
```

## 48. What is the `$slice` operator in MongoDB?

**Answer:**  
The `$slice` operator limits the number of array elements returned in a query result.

### Example:
```javascript
// Return first 3 comments
db.posts.find({ _id: 1 }, { comments: { $slice: 3 } });

// Return last 3 comments
db.posts.find({ _id: 1 }, { comments: { $slice: -3 } });

// Return 3 comments starting from index 5
db.posts.find({ _id: 1 }, { comments: { $slice: [5, 3] } });
```

## 49. What is the `$sort` operator in MongoDB aggregation?

**Answer:**  
The `$sort` operator sorts all input documents and passes them to the next pipeline stage in sorted order.

### Example:
```javascript
db.orders.aggregate([
    { $match: { status: "completed" } },
    { $sort: { amount: -1 } },  // Sort by amount descending
    { $limit: 10 }  // Get top 10
]);
```

## 50. What is the difference between `createIndex()` and `ensureIndex()` in MongoDB?

**Answer:**
- **`createIndex()`**: Creates an index if it doesn't exist. Returns an error if the index already exists.
- **`ensureIndex()`**: Creates an index if it doesn't exist, or does nothing if it already exists (deprecated in MongoDB 3.0+, use `createIndex()` instead).

```javascript
// createIndex - recommended
db.users.createIndex({ email: 1 });

// ensureIndex - deprecated
db.users.ensureIndex({ email: 1 });
```

## 51. What is the `$limit` operator in MongoDB aggregation?

**Answer:**  
The `$limit` operator limits the number of documents passed to the next pipeline stage.

### Example:
```javascript
db.orders.aggregate([
    { $match: { status: "completed" } },
    { $sort: { created_at: -1 } },
    { $limit: 10 }  // Get only 10 documents
]);
```

## 52. What is the `$skip` operator in MongoDB aggregation?

**Answer:**  
The `$skip` operator skips a specified number of documents and passes the remaining documents to the next pipeline stage. Often used with `$limit` for pagination.

### Example:
```javascript
// Pagination: skip first 20, return next 10
db.orders.aggregate([
    { $skip: 20 },
    { $limit: 10 }
]);
```

## 53. What is the difference between `drop()` and `remove()` in MongoDB?

**Answer:**
- **`drop()`**: Removes the entire collection and its indexes. Cannot be rolled back.
- **`remove()`**: Removes documents from a collection based on a filter. The collection structure remains.

```javascript
// drop - removes entire collection
db.users.drop();

// remove - removes documents matching filter
db.users.remove({ status: "inactive" });
```

## 54. What is the `$size` operator in MongoDB?

**Answer:**  
The `$size` operator matches arrays with a specific number of elements.

### Example:
```javascript
// Find users with exactly 3 tags
db.users.find({ tags: { $size: 3 } });
```

## 55. What is the difference between `$all` and `$in` operators in MongoDB?

**Answer:**
- **`$in`**: Matches documents where the field value is in the specified array (matches if any value matches).
- **`$all`**: Matches documents where the field contains all specified values (all values must be present).

```javascript
// $in - matches if any value is in the array
db.users.find({ tags: { $in: ["developer", "designer"] } });

// $all - matches if all values are in the array
db.users.find({ tags: { $all: ["developer", "designer"] } });
```

## 56. What is the `$type` operator in MongoDB?

**Answer:**  
The `$type` operator matches documents where the field is of a specified BSON type.

### Example:
```javascript
// Find documents where age is a number
db.users.find({ age: { $type: "number" } });

// Find documents where email is a string
db.users.find({ email: { $type: "string" } });
```

## 57. What is the difference between `$min` and `$max` operators in MongoDB aggregation?

**Answer:**
- **`$min`**: Returns the minimum value from a group of values.
- **`$max`**: Returns the maximum value from a group of values.

```javascript
db.orders.aggregate([
    {
        $group: {
            _id: "$customer_id",
            min_order: { $min: "$amount" },
            max_order: { $max: "$amount" }
        }
    }
]);
```

## 58. What is the `$avg` operator in MongoDB aggregation?

**Answer:**  
The `$avg` operator calculates the average value of numeric values.

### Example:
```javascript
db.orders.aggregate([
    {
        $group: {
            _id: "$customer_id",
            average_order: { $avg: "$amount" }
        }
    }
]);
```

## 59. What is the `$sum` operator in MongoDB aggregation?

**Answer:**  
The `$sum` operator calculates the sum of numeric values.

### Example:
```javascript
db.orders.aggregate([
    {
        $group: {
            _id: "$customer_id",
            total_spent: { $sum: "$amount" },
            order_count: { $sum: 1 }
        }
    }
]);
```

## 60. What is the difference between `$first` and `$last` operators in MongoDB aggregation?

**Answer:**
- **`$first`**: Returns the first value in a group (based on document order).
- **`$last`**: Returns the last value in a group (based on document order).

```javascript
db.orders.aggregate([
    { $sort: { created_at: 1 } },
    {
        $group: {
            _id: "$customer_id",
            first_order: { $first: "$amount" },
            last_order: { $last: "$amount" }
        }
    }
]);
```

## 61. What is the `$concat` operator in MongoDB aggregation?

**Answer:**  
The `$concat` operator concatenates strings together.

### Example:
```javascript
db.users.aggregate([
    {
        $project: {
            full_name: {
                $concat: ["$first_name", " ", "$last_name"]
            }
        }
    }
]);
```

## 62. What is the difference between `$cond` and `$ifNull` operators in MongoDB?

**Answer:**
- **`$cond`**: A ternary operator that evaluates a condition and returns one value if true, another if false.
- **`$ifNull`**: Returns the first expression if it's not null, otherwise returns the second expression.

```javascript
// $cond
db.users.aggregate([
    {
        $project: {
            status_label: {
                $cond: {
                    if: { $eq: ["$status", "active"] },
                    then: "User is active",
                    else: "User is inactive"
                }
            }
        }
    }
]);

// $ifNull
db.users.aggregate([
    {
        $project: {
            display_name: {
                $ifNull: ["$nickname", "$full_name"]
            }
        }
    }
]);
```

## 63. What is the `$dateToString` operator in MongoDB aggregation?

**Answer:**  
The `$dateToString` operator converts a date object to a string according to a specified format.

### Example:
```javascript
db.orders.aggregate([
    {
        $project: {
            order_date: {
                $dateToString: {
                    format: "%Y-%m-%d",
                    date: "$created_at"
                }
            }
        }
    }
]);
```

## 64. What is the difference between `$addFields` and `$project` in MongoDB aggregation?

**Answer:**
- **`$addFields`**: Adds new fields to documents while keeping all existing fields.
- **`$project`**: Reshapes documents by including, excluding, or adding fields (can remove existing fields).

```javascript
// $addFields - keeps all fields, adds new ones
db.users.aggregate([
    {
        $addFields: {
            full_name: { $concat: ["$first_name", " ", "$last_name"] }
        }
    }
]);

// $project - can exclude fields
db.users.aggregate([
    {
        $project: {
            name: 1,
            email: 1,
            full_name: { $concat: ["$first_name", " ", "$last_name"] }
            // Other fields are excluded
        }
    }
]);
```

## 65. What is the `$facet` operator in MongoDB aggregation?

**Answer:**  
The `$facet` operator allows you to run multiple aggregation pipelines in parallel on the same set of input documents.

### Example:
```javascript
db.orders.aggregate([
    {
        $facet: {
            "total_orders": [{ $count: "count" }],
            "by_status": [
                { $group: { _id: "$status", count: { $sum: 1 } } }
            ],
            "top_customers": [
                { $sort: { amount: -1 } },
                { $limit: 10 }
            ]
        }
    }
]);
```

## 66. What is the difference between `$merge` and `$out` operators in MongoDB aggregation?

**Answer:**
- **`$out`**: Writes the aggregation results to a collection, replacing the collection if it exists.
- **`$merge`**: Writes the aggregation results to a collection, with options to merge or replace documents (more flexible than `$out`).

```javascript
// $out - replaces collection
db.orders.aggregate([
    { $match: { status: "completed" } },
    { $out: "completed_orders" }
]);

// $merge - can merge with existing data
db.orders.aggregate([
    { $match: { status: "completed" } },
    {
        $merge: {
            into: "completed_orders",
            whenMatched: "replace",
            whenNotMatched: "insert"
        }
    }
]);
```

## 67. What is the `$bucket` operator in MongoDB aggregation?

**Answer:**  
The `$bucket` operator groups documents into buckets based on a specified expression and boundaries.

### Example:
```javascript
db.orders.aggregate([
    {
        $bucket: {
            groupBy: "$amount",
            boundaries: [0, 50, 100, 200, 500],
            default: "Other",
            output: {
                count: { $sum: 1 },
                total: { $sum: "$amount" }
            }
        }
    }
]);
```

## 68. What is the difference between `$sample` and `$limit` in MongoDB aggregation?

**Answer:**
- **`$limit`**: Returns the first N documents in the order they appear.
- **`$sample`**: Randomly selects N documents from the input.

```javascript
// $limit - first 10 documents
db.users.aggregate([
    { $limit: 10 }
]);

// $sample - random 10 documents
db.users.aggregate([
    { $sample: { size: 10 } }
]);
```

## 69. What is the `$replaceRoot` operator in MongoDB aggregation?

**Answer:**  
The `$replaceRoot` operator replaces a document with a specified embedded document, promoting the embedded document to the top level.

### Example:
```javascript
db.users.aggregate([
    {
        $replaceRoot: {
            newRoot: "$address"
        }
    }
]);
```

## 70. What is the difference between `$count` and `$sum` in MongoDB aggregation?

**Answer:**
- **`$count`**: Counts the number of documents in a pipeline stage.
- **`$sum`**: Sums numeric values, often used with `$group` to count documents by using `$sum: 1`.

```javascript
// $count - counts documents
db.orders.aggregate([
    { $match: { status: "completed" } },
    { $count: "total_completed" }
]);

// $sum - sums values or counts in groups
db.orders.aggregate([
    {
        $group: {
            _id: "$status",
            count: { $sum: 1 },
            total: { $sum: "$amount" }
        }
    }
]);
```


