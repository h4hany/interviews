# Go (Golang) Interview Questions

## 1. What is Go (Golang)?

**Answer:**
Go is an open-source programming language developed by Google. It's statically typed, compiled, and designed for simplicity, concurrency, and performance.

## 2. What are the main features of Go?

**Answer:**
- Simple syntax
- Fast compilation
- Built-in concurrency (goroutines, channels)
- Garbage collection
- Static typing
- Cross-platform compilation

## 3. What is a goroutine?

**Answer:**
A goroutine is a lightweight thread managed by the Go runtime. Goroutines are cheaper than OS threads and enable concurrent execution.

### Example:
```go
go func() {
    fmt.Println("Running in goroutine")
}()
```

## 4. What is a channel in Go?

**Answer:**
A channel is a typed conduit for communication between goroutines. It enables safe data sharing and synchronization.

### Example:
```go
ch := make(chan int)
go func() { ch <- 42 }()
value := <-ch
```

## 5. What is the difference between buffered and unbuffered channels?

**Answer:**
- **Unbuffered Channel**: Synchronous, sender blocks until receiver receives.
- **Buffered Channel**: Asynchronous, sender blocks only when buffer is full.

### Example:
```go
unbuffered := make(chan int)        // Unbuffered
buffered := make(chan int, 10)      // Buffered with capacity 10
```

## 6. What is the difference between `make` and `new` in Go?

**Answer:**
- **`make`**: Allocates and initializes slices, maps, channels (returns initialized value).
- **`new`**: Allocates memory for types (returns pointer to zero value).

## 7. What is the difference between arrays and slices in Go?

**Answer:**
- **Array**: Fixed size, value type, copied when passed.
- **Slice**: Dynamic size, reference type, points to underlying array.

## 8. What is a pointer in Go?

**Answer:**
A pointer stores the memory address of a value. Go uses pointers for efficiency and to modify values.

### Example:
```go
x := 42
p := &x  // p is pointer to x
*p = 21  // modify value through pointer
```

## 9. What is the difference between `var`, `:=`, and `=` in Go?

**Answer:**
- **`var`**: Declares variable with zero value.
- **`:=`**: Short variable declaration (infers type).
- **`=`**: Assignment to existing variable.

## 10. What is an interface in Go?

**Answer:**
An interface defines a set of method signatures. Types implicitly implement interfaces by implementing all methods.

### Example:
```go
type Writer interface {
    Write([]byte) (int, error)
}
```

## 11. What is the difference between `interface{}` and `any`?

**Answer:**
- **`interface{}`**: Empty interface (accepts any type), older syntax.
- **`any`**: Alias for `interface{}`, introduced in Go 1.18.

## 12. What is error handling in Go?

**Answer:**
Go uses explicit error returns instead of exceptions. Functions return `error` as the last return value.

### Example:
```go
result, err := doSomething()
if err != nil {
    return err
}
```

## 13. What is `defer` in Go?

**Answer:**
`defer` schedules a function call to run after the surrounding function returns, useful for cleanup.

### Example:
```go
file, err := os.Open("file.txt")
defer file.Close()  // Closes file when function returns
```

## 14. What is `panic` and `recover` in Go?

**Answer:**
- **`panic`**: Stops normal execution, unwinds stack.
- **`recover`**: Catches panic, allows graceful handling.

## 15. What is the difference between `select` and `switch`?

**Answer:**
- **`switch`**: Chooses based on value.
- **`select`**: Chooses based on channel operations (non-blocking).

### Example:
```go
select {
case msg := <-ch1:
    fmt.Println(msg)
case ch2 <- 42:
    fmt.Println("sent")
default:
    fmt.Println("no communication")
}
```

## 16. What is a struct in Go?

**Answer:**
A struct is a collection of fields, similar to a class in OOP languages.

### Example:
```go
type Person struct {
    Name string
    Age  int
}
```

## 17. What is method in Go?

**Answer:**
A method is a function with a receiver, allowing types to have behavior.

### Example:
```go
func (p Person) String() string {
    return fmt.Sprintf("%s (%d)", p.Name, p.Age)
}
```

## 18. What is the difference between value and pointer receivers?

**Answer:**
- **Value Receiver**: Operates on copy, can't modify original.
- **Pointer Receiver**: Operates on original, can modify.

## 19. What is `context` in Go?

**Answer:**
`context` package provides cancellation, deadlines, and request-scoped values across API boundaries.

### Example:
```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
```

## 20. What is `sync.WaitGroup`?

**Answer:**
`WaitGroup` waits for a collection of goroutines to finish.

### Example:
```go
var wg sync.WaitGroup
wg.Add(1)
go func() {
    defer wg.Done()
    // work
}()
wg.Wait()
```

## 21. What is `sync.Mutex`?

**Answer:**
`Mutex` provides mutual exclusion, ensuring only one goroutine accesses shared data at a time.

### Example:
```go
var mu sync.Mutex
mu.Lock()
// critical section
mu.Unlock()
```

## 22. What is the difference between `Mutex` and `RWMutex`?

**Answer:**
- **`Mutex`**: Exclusive lock (one reader or writer).
- **`RWMutex`**: Allows multiple readers or one writer.

## 23. What is `sync.Once`?

**Answer:**
`Once` ensures a function is executed only once, useful for initialization.

### Example:
```go
var once sync.Once
once.Do(func() {
    // initialization code
})
```

## 24. What is `sync.Pool`?

**Answer:**
`Pool` provides a pool of temporary objects to reduce allocations and garbage collection pressure.

## 25. What is JSON marshaling/unmarshaling in Go?

**Answer:**
- **Marshal**: Converts Go struct to JSON.
- **Unmarshal**: Converts JSON to Go struct.

### Example:
```go
data, _ := json.Marshal(person)
json.Unmarshal(data, &person)
```

## 26. What is HTTP server in Go?

**Answer:**
Go's `net/http` package provides HTTP server and client functionality.

### Example:
```go
http.HandleFunc("/", handler)
http.ListenAndServe(":8080", nil)
```

## 27. What is middleware in Go HTTP?

**Answer:**
Middleware wraps HTTP handlers, enabling cross-cutting concerns like logging, authentication.

## 28. What is the difference between `http.Get` and `http.Post`?

**Answer:**
- **`http.Get`**: Makes GET request.
- **`http.Post`**: Makes POST request with body.

## 29. What is `io.Reader` and `io.Writer`?

**Answer:**
- **`io.Reader`**: Interface for reading data.
- **`io.Writer`**: Interface for writing data.

## 30. What is `io.Copy`?

**Answer:**
`io.Copy` copies data from a Reader to a Writer efficiently.

## 31. What is reflection in Go?

**Answer:**
Reflection allows examining and modifying program structure at runtime using the `reflect` package.

## 32. What is `go mod`?

**Answer:**
`go mod` is Go's module system for dependency management, introduced in Go 1.11.

## 33. What is the difference between `go get` and `go install`?

**Answer:**
- **`go get`**: Downloads and adds dependency to go.mod.
- **`go install`**: Compiles and installs binary to GOPATH/bin.

## 34. What is `go test`?

**Answer:**
`go test` runs tests in packages. Test functions start with `Test`.

### Example:
```go
func TestAdd(t *testing.T) {
    result := Add(2, 3)
    if result != 5 {
        t.Errorf("Expected 5, got %d", result)
    }
}
```

## 35. What is benchmarking in Go?

**Answer:**
Benchmarking measures function performance. Benchmark functions start with `Benchmark`.

### Example:
```go
func BenchmarkAdd(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Add(2, 3)
    }
}
```

## 36. What is `go fmt`?

**Answer:**
`go fmt` formats Go code according to standard style, ensuring consistency.

## 37. What is `go vet`?

**Answer:**
`go vet` examines Go code for common errors and suspicious constructs.

## 38. What is `go build` vs `go run`?

**Answer:**
- **`go build`**: Compiles package, produces binary.
- **`go run`**: Compiles and runs in one step (no binary saved).

## 39. What is `GOPATH` and `GOROOT`?

**Answer:**
- **`GOROOT`**: Go installation directory.
- **`GOPATH`**: Workspace directory (legacy, replaced by modules).

## 40. What is Go best practices?

**Answer:**
- Use `gofmt` for formatting
- Handle errors explicitly
- Use interfaces for abstraction
- Prefer composition over inheritance
- Use channels for communication
- Avoid premature optimization
- Write tests
- Use `context` for cancellation
- Avoid global state
- Use `defer` for cleanup


