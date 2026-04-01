# React Interview Mastery — Yassir Staff Engineer

> **Context:** Although this is a Backend Staff Engineer role, Yassir explicitly requires **deep knowledge of React** and **full-stack experience**. Glassdoor reports mention: component libraries, CI/CD, accessibility, core/advanced React, monorepo management, state management, and library selection. Yassir's frontend stack is **React + TypeScript**, part of a Node.js/React full-stack setup. Expect advanced React questions, architectural thinking, and staff-level judgment on technology decisions.

---

## TABLE OF CONTENTS

1. [Glassdoor Questions — React Specific Answers](#1-glassdoor-questions--react-specific-answers)
2. [React Core — Hooks Deep Dive](#2-react-core--hooks-deep-dive)
3. [Advanced React Patterns](#3-advanced-react-patterns)
4. [State Management](#4-state-management)
5. [Performance Optimization](#5-performance-optimization)
6. [Component Libraries & Design Systems](#6-component-libraries--design-systems)
7. [Accessibility (a11y)](#7-accessibility-a11y)
8. [Testing React Applications](#8-testing-react-applications)
9. [Monorepo & Tooling](#9-monorepo--tooling)
10. [CI/CD for Frontend](#10-cicd-for-frontend)
11. [React Architecture at Scale](#11-react-architecture-at-scale)
12. [Quick-Fire Reference Cheatsheet](#12-quick-fire-reference-cheatsheet)

---

## 1. Glassdoor Questions — React Specific Answers

---

### Q1 — How do you implement state management? 🔥 PROBABILITY: 92%

**Short answer:** Choose the right tool for the scope of state. Not all state is the same.

**The state classification framework (give this to the interviewer):**

| State Type | Where it lives | Best tool |
|---|---|---|
| Local UI state | One component | `useState`, `useReducer` |
| Shared UI state | Component subtree | `useContext` + `useReducer` |
| Server/async state | Cached from API | React Query / SWR |
| Global app state | Across routes/features | Zustand, Redux Toolkit |
| URL state | Browser URL | React Router search params |
| Form state | Form component | React Hook Form |

**Decision tree:**

```
Does only one component need it?
  └─ YES → useState / useReducer

Does a subtree need it (prop drilling > 2 levels)?
  └─ YES → useContext (if updates are infrequent) or Zustand slice

Is it data fetched from a server?
  └─ YES → React Query (TanStack Query) — handles cache, loading, refetch, stale-while-revalidate

Is it complex global state with many updates?
  └─ YES → Redux Toolkit (if team knows Redux) or Zustand (simpler, less boilerplate)

Is it form state?
  └─ YES → React Hook Form — uncontrolled approach, minimal re-renders
```

**Zustand example (modern, minimal, no boilerplate):**
```typescript
// store/useOrderStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface OrderState {
  cart: CartItem[];
  total: number;
  addItem: (item: CartItem) => void;
  removeItem: (productId: string) => void;
  clearCart: () => void;
}

export const useOrderStore = create<OrderState>()(
  devtools(
    persist(
      (set, get) => ({
        cart: [],
        total: 0,
        addItem: (item) =>
          set((state) => {
            const existing = state.cart.find(i => i.productId === item.productId);
            const cart = existing
              ? state.cart.map(i => i.productId === item.productId
                  ? { ...i, quantity: i.quantity + item.quantity }
                  : i)
              : [...state.cart, item];
            return { cart, total: cart.reduce((sum, i) => sum + i.price * i.quantity, 0) };
          }),
        removeItem: (productId) =>
          set((state) => {
            const cart = state.cart.filter(i => i.productId !== productId);
            return { cart, total: cart.reduce((sum, i) => sum + i.price * i.quantity, 0) };
          }),
        clearCart: () => set({ cart: [], total: 0 }),
      }),
      { name: 'order-store' } // persists to localStorage
    )
  )
);
```

**React Query example (server state — most important for Yassir's data-heavy app):**
```typescript
// hooks/useOrders.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export function useOrders(userId: string) {
  return useQuery({
    queryKey: ['orders', userId],
    queryFn: () => api.getOrders(userId),
    staleTime: 30_000,        // Consider fresh for 30s
    gcTime: 5 * 60 * 1000,   // Keep in cache 5 min
    refetchOnWindowFocus: true,
  });
}

export function usePlaceOrder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (orderData: CreateOrderDto) => api.placeOrder(orderData),
    onSuccess: (newOrder) => {
      // Optimistic update OR invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      queryClient.setQueryData(['orders', newOrder.id], newOrder);
    },
    onError: (err) => {
      toast.error('Order failed. Please try again.');
    },
  });
}

// Component usage — clean and declarative
function OrderList({ userId }: { userId: string }) {
  const { data: orders, isLoading, error } = useOrders(userId);
  const { mutate: placeOrder, isPending } = usePlaceOrder();

  if (isLoading) return <Spinner />;
  if (error) return <ErrorBoundary error={error} />;

  return (
    <div>
      {orders.map(order => <OrderCard key={order.id} order={order} />)}
      <Button onClick={() => placeOrder(cartData)} disabled={isPending}>
        {isPending ? 'Placing...' : 'Place Order'}
      </Button>
    </div>
  );
}
```

---

### Q2 — How do you choose a library? 🔥 PROBABILITY: 78%

*See Node.js guide Q5 for the general framework. React-specific additions:*

**For React libraries, additionally evaluate:**

1. **React version compatibility** — does it support React 18 (concurrent mode, Suspense)?
2. **Server Components compatibility** — can it work with Next.js RSC? (Zustand yes, most context-based libs need client boundary)
3. **Bundle size impact** — use bundlephobia.com; tree-shakeable exports?
4. **Re-render behavior** — does it cause unnecessary re-renders? (use React DevTools Profiler to test)
5. **SSR compatibility** — hydration issues? (state management libs must handle SSR)

**Example — choosing between date pickers:**
- `react-datepicker` (400kb, lots of features, heavy) 
- `react-day-picker` (35kb, accessible, modern) 
- `@mui/x-date-pickers` (requires full MUI, 500kb+)
- Decision: `react-day-picker` — small, accessible, works with any design system

---

### Q3 — Core React questions: Hooks, rendering, architecture 🔥 PROBABILITY: 95%

*Covered in depth in sections 2–5 below.*

---

## 2. React Core — Hooks Deep Dive

---

### Q4 — `useState` vs `useReducer` — when to use which 🔥 PROBABILITY: 85%

```typescript
// useState — simple, independent state values
const [isOpen, setIsOpen] = useState(false);
const [count, setCount] = useState(0);

// useReducer — multiple related values, complex transitions
type CartState = { items: CartItem[]; total: number; discount: number };
type CartAction =
  | { type: 'ADD_ITEM'; payload: CartItem }
  | { type: 'REMOVE_ITEM'; payload: string }
  | { type: 'APPLY_DISCOUNT'; payload: number }
  | { type: 'CLEAR' };

function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD_ITEM': {
      const items = [...state.items, action.payload];
      return { ...state, items, total: calculateTotal(items, state.discount) };
    }
    case 'REMOVE_ITEM': {
      const items = state.items.filter(i => i.id !== action.payload);
      return { ...state, items, total: calculateTotal(items, state.discount) };
    }
    case 'APPLY_DISCOUNT':
      return { ...state, discount: action.payload, total: calculateTotal(state.items, action.payload) };
    case 'CLEAR':
      return { items: [], total: 0, discount: 0 };
    default:
      return state;
  }
}

// Usage — all cart logic is testable in isolation
const [cart, dispatch] = useReducer(cartReducer, { items: [], total: 0, discount: 0 });
dispatch({ type: 'ADD_ITEM', payload: newItem });
```

**Rule of thumb:**
- `useState` when state transitions are simple and independent
- `useReducer` when next state depends on previous state, or multiple sub-values are tightly related
- `useReducer` when you want to test state logic separately from the component

---

### Q5 — `useEffect` — every subtlety you need to know 🔥 PROBABILITY: 90%

```typescript
// Pattern 1: Run on mount only
useEffect(() => {
  const subscription = ws.subscribe(channelId);
  return () => subscription.unsubscribe(); // Cleanup on unmount
}, []); // ← empty array = mount only

// Pattern 2: Sync with prop
useEffect(() => {
  document.title = `Order #${orderId}`;
}, [orderId]); // ← runs when orderId changes

// Pattern 3: The wrong way to fetch data (race condition!)
useEffect(() => {
  fetch(`/api/orders/${id}`)
    .then(r => r.json())
    .then(setOrder); // If id changes quickly, responses can arrive out of order!
}, [id]);

// Pattern 4: Correct way to fetch — abort controller
useEffect(() => {
  const controller = new AbortController();

  fetch(`/api/orders/${id}`, { signal: controller.signal })
    .then(r => r.json())
    .then(setOrder)
    .catch(err => {
      if (err.name !== 'AbortError') setError(err); // Ignore abort errors
    });

  return () => controller.abort(); // Abort if id changes before fetch completes
}, [id]);

// Pattern 5: Avoid effect for derived state (React anti-pattern)
// BAD:
useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);

// GOOD: Compute during render
const fullName = `${firstName} ${lastName}`;
```

**React 18 StrictMode double-invocation:** In development, React runs effects twice to detect side effects. Your cleanup function must fully reverse the effect.

**useLayoutEffect vs useEffect:**
- `useLayoutEffect` fires synchronously after DOM mutations but before browser paint — use for DOM measurements
- `useEffect` fires asynchronously after paint — use for everything else
- `useLayoutEffect` on server will cause a warning — use with caution in SSR apps

---

### Q6 — `useCallback` and `useMemo` — when they actually help 🔥 PROBABILITY: 88%

**The trap:** Many developers add `useMemo`/`useCallback` everywhere. This is wrong — they add overhead and cognitive complexity.

**When `useMemo` is justified:**
```typescript
// 1. Expensive calculation
const sortedAndFilteredOrders = useMemo(() =>
  orders
    .filter(o => o.status === activeFilter)
    .sort((a, b) => b.createdAt - a.createdAt),
  [orders, activeFilter] // Only recalculate when these change
);

// 2. Stable reference for context value (prevents all consumers re-rendering)
const contextValue = useMemo(() => ({
  user,
  login,
  logout
}), [user]); // login and logout are stable functions

// NOT justified:
const name = useMemo(() => `${first} ${last}`, [first, last]); // Trivial — overhead > benefit
```

**When `useCallback` is justified:**
```typescript
// 1. Passed as prop to memoized child component
const handleAddToCart = useCallback((item: CartItem) => {
  dispatch({ type: 'ADD_ITEM', payload: item });
}, [dispatch]); // dispatch from useReducer is always stable

// Memoized child only re-renders when handleAddToCart reference changes
const MemoizedProductCard = React.memo(ProductCard);
<MemoizedProductCard onAddToCart={handleAddToCart} />;

// 2. Used as useEffect dependency
useEffect(() => {
  const unsubscribe = eventBus.on('order.updated', handleOrderUpdate);
  return unsubscribe;
}, [handleOrderUpdate]); // Without useCallback, this runs every render!
```

**Golden rule:** Profile first with React DevTools → Profiler. If you can't measure the problem, don't add memoization.

---

### Q7 — Custom Hooks — design and best practices 🔥 PROBABILITY: 85%

Custom hooks extract and reuse stateful logic. The key rule: **always prefix with `use`**.

```typescript
// useDebounce — rate-limit input (search-as-you-type at Yassir)
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

// useLocalStorage — persist state with SSR safety
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === 'undefined') return initialValue;
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = useCallback((value: T | ((val: T) => T)) => {
    const valueToStore = value instanceof Function ? value(storedValue) : value;
    setStoredValue(valueToStore);
    localStorage.setItem(key, JSON.stringify(valueToStore));
  }, [key, storedValue]);

  return [storedValue, setValue] as const;
}

// useIntersectionObserver — infinite scroll / lazy loading
function useIntersectionObserver(
  ref: RefObject<Element>,
  options?: IntersectionObserverInit
): boolean {
  const [isIntersecting, setIsIntersecting] = useState(false);

  useEffect(() => {
    if (!ref.current) return;
    const observer = new IntersectionObserver(
      ([entry]) => setIsIntersecting(entry.isIntersecting),
      options
    );
    observer.observe(ref.current);
    return () => observer.disconnect();
  }, [ref, options]);

  return isIntersecting;
}

// Usage — lazy load images in Yassir's product listings
function ProductImage({ src, alt }: { src: string; alt: string }) {
  const imgRef = useRef<HTMLImageElement>(null);
  const isVisible = useIntersectionObserver(imgRef, { threshold: 0.1 });

  return <img ref={imgRef} src={isVisible ? src : undefined} alt={alt} />;
}
```

---

### Q8 — `useRef` — beyond just DOM refs 🔥 PROBABILITY: 75%

```typescript
// 1. DOM reference (classic use)
const inputRef = useRef<HTMLInputElement>(null);
useEffect(() => { inputRef.current?.focus(); }, []);

// 2. Mutable value that doesn't trigger re-render
const renderCount = useRef(0);
useEffect(() => { renderCount.current += 1; }); // Doesn't cause re-render

// 3. Previous value
function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();
  useEffect(() => { ref.current = value; }, [value]);
  return ref.current; // Returns value from BEFORE this render
}

// 4. Stable reference for callbacks (avoid stale closure in event listeners)
function useEventListener(event: string, handler: (e: Event) => void) {
  const handlerRef = useRef(handler);

  useLayoutEffect(() => {
    handlerRef.current = handler; // Always latest handler
  });

  useEffect(() => {
    const listener = (e: Event) => handlerRef.current(e);
    window.addEventListener(event, listener);
    return () => window.removeEventListener(event, listener);
  }, [event]); // Only re-subscribe if event name changes
}
```

---

### Q9 — React 18 Concurrent Features 🔥 PROBABILITY: 80%

**`useTransition` — mark state updates as non-urgent:**
```typescript
function SearchResults() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [isPending, startTransition] = useTransition();

  function handleSearch(e: ChangeEvent<HTMLInputElement>) {
    const value = e.target.value;
    setQuery(value); // Urgent — update input immediately

    startTransition(() => {
      // Non-urgent — can be interrupted if user keeps typing
      setResults(heavyFilterOperation(value));
    });
  }

  return (
    <>
      <input value={query} onChange={handleSearch} />
      {isPending && <Spinner />}
      <ResultsList results={results} style={{ opacity: isPending ? 0.5 : 1 }} />
    </>
  );
}
```

**`useDeferredValue` — defer expensive child renders:**
```typescript
function ProductSearch({ query }: { query: string }) {
  const deferredQuery = useDeferredValue(query);
  const isStale = query !== deferredQuery;

  return (
    <div style={{ opacity: isStale ? 0.5 : 1 }}>
      <Suspense fallback={<Spinner />}>
        <ProductList query={deferredQuery} /> {/* Re-renders with slight delay */}
      </Suspense>
    </div>
  );
}
```

**`Suspense` for data fetching (with React Query):**
```typescript
// Wrap in Suspense — React Query 5 supports useSuspenseQuery
function OrderDetails({ orderId }: { orderId: string }) {
  const { data: order } = useSuspenseQuery({
    queryKey: ['order', orderId],
    queryFn: () => api.getOrder(orderId),
  });
  return <div>{order.status}</div>; // Never undefined here
}

// Parent component
<Suspense fallback={<OrderSkeleton />}>
  <ErrorBoundary fallback={<ErrorMessage />}>
    <OrderDetails orderId={id} />
  </ErrorBoundary>
</Suspense>
```

---

## 3. Advanced React Patterns

---

### Q10 — Compound Components Pattern 🔥 PROBABILITY: 72%

Allows parent-child components to share implicit state, like how HTML `<select>` and `<option>` work together:

```typescript
// Context for shared state
const SelectContext = createContext<{
  value: string;
  onChange: (v: string) => void;
} | null>(null);

// Parent component
function Select({ value, onChange, children }: SelectProps) {
  return (
    <SelectContext.Provider value={{ value, onChange }}>
      <div role="listbox" className="select-wrapper">
        {children}
      </div>
    </SelectContext.Provider>
  );
}

// Child component — accesses parent state implicitly
function Option({ value, children }: OptionProps) {
  const ctx = useContext(SelectContext);
  if (!ctx) throw new Error('Option must be used within Select');

  return (
    <div
      role="option"
      aria-selected={ctx.value === value}
      onClick={() => ctx.onChange(value)}
      className={ctx.value === value ? 'selected' : ''}
    >
      {children}
    </div>
  );
}

Select.Option = Option; // Attach as namespace

// Usage — clean and semantic
<Select value={status} onChange={setStatus}>
  <Select.Option value="pending">Pending</Select.Option>
  <Select.Option value="confirmed">Confirmed</Select.Option>
  <Select.Option value="delivered">Delivered</Select.Option>
</Select>
```

---

### Q11 — Render Props & Higher-Order Components (HOC) 🔥 PROBABILITY: 68%

```typescript
// Render props — pass rendering responsibility to consumer
function DataFetcher<T>({
  url,
  render
}: {
  url: string;
  render: (data: T | null, loading: boolean, error: Error | null) => ReactNode;
}) {
  const [state, setState] = useState<{ data: T | null; loading: boolean; error: Error | null }>
    ({ data: null, loading: true, error: null });

  useEffect(() => {
    fetch(url)
      .then(r => r.json())
      .then(data => setState({ data, loading: false, error: null }))
      .catch(error => setState({ data: null, loading: false, error }));
  }, [url]);

  return <>{render(state.data, state.loading, state.error)}</>;
}

// Usage
<DataFetcher<Order[]>
  url="/api/orders"
  render={(orders, loading, error) => (
    loading ? <Spinner /> : error ? <ErrorMsg /> : <OrderList orders={orders!} />
  )}
/>

// HOC — enhance components with cross-cutting concerns (auth, logging)
function withAuthGuard<P extends object>(
  WrappedComponent: ComponentType<P>,
  requiredRole: string
) {
  return function AuthGuardedComponent(props: P) {
    const { user } = useAuth();

    if (!user) return <Navigate to="/login" />;
    if (!user.roles.includes(requiredRole)) return <Forbidden />;

    return <WrappedComponent {...props} />;
  };
}

const AdminDashboard = withAuthGuard(Dashboard, 'admin');
```

**Modern note:** Custom hooks have largely replaced both patterns for logic sharing. Render props are still valid for render-level flexibility (like react-table). HOCs are still used in libraries (Redux `connect`, `React.memo`).

---

### Q12 — Error Boundaries 🔥 PROBABILITY: 82%

Error boundaries only work as class components (as of React 18), but you can wrap with hooks:

```typescript
// Class-based error boundary (required)
class ErrorBoundary extends Component<
  { fallback: ReactNode; onError?: (error: Error, info: ErrorInfo) => void; children: ReactNode },
  { hasError: boolean; error: Error | null }
> {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    // Log to error tracking (Sentry, Datadog)
    this.props.onError?.(error, info);
    logErrorToService(error, info.componentStack);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }
    return this.props.children;
  }
}

// Functional wrapper using 'react-error-boundary' (popular library)
import { ErrorBoundary, useErrorBoundary } from 'react-error-boundary';

function OrdersPage() {
  return (
    <ErrorBoundary
      fallbackRender={({ error, resetErrorBoundary }) => (
        <div role="alert">
          <p>Something went wrong: {error.message}</p>
          <button onClick={resetErrorBoundary}>Try again</button>
        </div>
      )}
      onError={(error, info) => errorReporter.captureException(error, info)}
    >
      <Suspense fallback={<OrdersSkeleton />}>
        <OrdersList />
      </Suspense>
    </ErrorBoundary>
  );
}
```

---

## 4. State Management

---

### Q13 — Redux Toolkit — modern Redux 🔥 PROBABILITY: 75%

```typescript
// store/ordersSlice.ts
import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

export const fetchOrders = createAsyncThunk(
  'orders/fetchAll',
  async (userId: string, { rejectWithValue }) => {
    try {
      return await api.getOrders(userId);
    } catch (err) {
      return rejectWithValue((err as Error).message);
    }
  }
);

const ordersSlice = createSlice({
  name: 'orders',
  initialState: {
    items: [] as Order[],
    status: 'idle' as 'idle' | 'loading' | 'succeeded' | 'failed',
    error: null as string | null,
  },
  reducers: {
    orderUpdated(state, action: PayloadAction<Order>) {
      const index = state.items.findIndex(o => o.id === action.payload.id);
      if (index !== -1) state.items[index] = action.payload; // Immer handles immutability
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchOrders.pending, (state) => { state.status = 'loading'; })
      .addCase(fetchOrders.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.items = action.payload;
      })
      .addCase(fetchOrders.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.payload as string;
      });
  },
});

// RTK Query — data fetching integrated into Redux
const ordersApi = createApi({
  reducerPath: 'ordersApi',
  baseQuery: fetchBaseQuery({ baseUrl: '/api' }),
  tagTypes: ['Order'],
  endpoints: (builder) => ({
    getOrders: builder.query<Order[], string>({
      query: (userId) => `/orders?userId=${userId}`,
      providesTags: (result) => result
        ? [...result.map(({ id }) => ({ type: 'Order' as const, id })), 'Order']
        : ['Order'],
    }),
    placeOrder: builder.mutation<Order, CreateOrderDto>({
      query: (body) => ({ url: '/orders', method: 'POST', body }),
      invalidatesTags: ['Order'],
    }),
  }),
});
```

---

### Q14 — Context API — right patterns and common pitfalls 🔥 PROBABILITY: 80%

```typescript
// WRONG — putting everything in one context causes all consumers to re-render
const AppContext = createContext({ user, orders, cart, theme, notifications });

// RIGHT — split by update frequency
const UserContext = createContext<User | null>(null);      // Rarely changes
const ThemeContext = createContext<Theme>('light');         // Rarely changes
const CartContext = createContext<CartState>(initialCart);  // Frequently changes

// WRONG — creating new object every render
function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  return (
    <UserContext.Provider value={{ user, setUser }}> {/* New object every render! */}
      {children}
    </UserContext.Provider>
  );
}

// RIGHT — memoize the context value
function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const value = useMemo(() => ({ user, setUser }), [user]); // Stable unless user changes

  return <UserContext.Provider value={value}>{children}</UserContext.Provider>;
}

// RIGHT — separate state and dispatch contexts (dispatch is always stable with useReducer)
const CartStateContext = createContext<CartState | null>(null);
const CartDispatchContext = createContext<Dispatch<CartAction> | null>(null);

function CartProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(cartReducer, initialState);
  return (
    <CartStateContext.Provider value={state}>
      <CartDispatchContext.Provider value={dispatch}>
        {children}
      </CartDispatchContext.Provider>
    </CartStateContext.Provider>
  );
}
```

---

## 5. Performance Optimization

---

### Q15 — React rendering optimization strategies 🔥 PROBABILITY: 90%

**`React.memo` — prevent re-renders when props haven't changed:**
```typescript
// Without memo: re-renders whenever parent renders, even if props are identical
const OrderCard = React.memo(function OrderCard({ order, onCancel }: OrderCardProps) {
  return (
    <div>
      <h3>{order.id}</h3>
      <button onClick={() => onCancel(order.id)}>Cancel</button>
    </div>
  );
});

// Custom comparison (use sparingly — usually default shallow comparison is enough)
const OrderCard = React.memo(OrderCardComponent, (prevProps, nextProps) =>
  prevProps.order.id === nextProps.order.id &&
  prevProps.order.status === nextProps.order.status
);
```

**Code splitting with `React.lazy` and `Suspense`:**
```typescript
// Route-level splitting — don't load admin bundle until user navigates there
const AdminDashboard = React.lazy(() => import('./pages/AdminDashboard'));
const Analytics = React.lazy(() => import('./pages/Analytics'));

function AppRoutes() {
  return (
    <Suspense fallback={<PageLoader />}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/admin" element={<AdminDashboard />} /> {/* Loaded on demand */}
        <Route path="/analytics" element={<Analytics />} />
      </Routes>
    </Suspense>
  );
}

// Component-level splitting — lazy load heavy modals
const MapPicker = React.lazy(() => import('./components/MapPicker')); // Leaflet is heavy!

function AddressForm() {
  const [showMap, setShowMap] = useState(false);
  return (
    <>
      <button onClick={() => setShowMap(true)}>Pick on map</button>
      {showMap && (
        <Suspense fallback={<div>Loading map...</div>}>
          <MapPicker onSelect={handleSelect} />
        </Suspense>
      )}
    </>
  );
}
```

**Virtualization — render only visible rows (critical for Yassir's order lists):**
```typescript
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualOrderList({ orders }: { orders: Order[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: orders.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 80, // Estimated row height
    overscan: 5, // Render 5 extra items above/below viewport
  });

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map((virtualItem) => (
          <div
            key={virtualItem.key}
            style={{
              position: 'absolute',
              top: virtualItem.start,
              height: virtualItem.size,
            }}
          >
            <OrderRow order={orders[virtualItem.index]} />
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

### Q16 — Web Vitals & Core Web Vitals for React apps 🔥 PROBABILITY: 70%

**Key metrics:**
| Metric | Stands for | Good | How to improve |
|---|---|---|---|
| LCP | Largest Contentful Paint | < 2.5s | Preload hero images, CDN, SSR |
| FID/INP | Interaction to Next Paint | < 200ms | Break up long tasks, `useTransition` |
| CLS | Cumulative Layout Shift | < 0.1 | Reserve space for images/ads, avoid inserting above content |
| TTFB | Time to First Byte | < 800ms | SSR/SSG, edge caching |
| FCP | First Contentful Paint | < 1.8s | Reduce bundle, inline critical CSS |

**React-specific optimizations for mobile users (Yassir's core demographic):**
```typescript
// 1. Avoid layout shifts — always set image dimensions
<img src={product.image} width={300} height={200} alt={product.name} />

// 2. Preload critical resources
<link rel="preload" href="/fonts/yassir-brand.woff2" as="font" type="font/woff2" crossOrigin="" />

// 3. Measure with web-vitals package
import { onCLS, onFID, onLCP } from 'web-vitals';
onLCP(({ value }) => analytics.track('lcp', { value }));
```

---

## 6. Component Libraries & Design Systems

---

### Q17 — Building and choosing a component library 🔥 PROBABILITY: 80%

**When to build vs buy:**

| | Buy (MUI, Ant Design, Shadcn) | Build custom |
|---|---|---|
| Brand requirements | Generic is OK | Strong brand identity (Yassir's app) |
| Timeline | Need fast | Have design system budget |
| Accessibility | Included | Must build yourself |
| Customization | Via theming API | Full control |
| Bundle size | Heavy (MUI ~500kb gzipped) | Only what you need |

**Modern choice: Shadcn/ui + Radix UI (headless):**
```typescript
// Radix UI provides accessible, unstyled primitives
// Shadcn copies the source into your project (no runtime dep!)
// You own the code and can customize freely

import * as Dialog from '@radix-ui/react-dialog';

function OrderConfirmModal({ order, onConfirm }: Props) {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>
        <Button>Confirm Order</Button>
      </Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay className="dialog-overlay" />
        <Dialog.Content className="dialog-content" aria-describedby="order-desc">
          <Dialog.Title>Confirm Order #{order.id}</Dialog.Title>
          <Dialog.Description id="order-desc">
            Total: {order.total} DZD
          </Dialog.Description>
          <Button onClick={onConfirm}>Confirm</Button>
          <Dialog.Close asChild>
            <Button variant="ghost">Cancel</Button>
          </Dialog.Close>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

**Design tokens — the foundation of a design system:**
```typescript
// tokens/colors.ts — single source of truth
export const colors = {
  brand: {
    primary: '#00B14F',   // Yassir green
    secondary: '#FF6B35',
    dark: '#0A1628',
  },
  semantic: {
    success: '#22C55E',
    error: '#EF4444',
    warning: '#F59E0B',
    info: '#3B82F6',
  },
} as const;

// CSS custom properties — runtime theming
:root {
  --color-primary: #00B14F;
  --color-error: #EF4444;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --radius-md: 8px;
  --shadow-card: 0 2px 8px rgba(0,0,0,0.08);
}
```

---

### Q18 — Storybook — component documentation and testing 🔥 PROBABILITY: 65%

```typescript
// Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  component: Button,
  title: 'Components/Button',
  argTypes: {
    variant: { control: 'select', options: ['primary', 'secondary', 'ghost'] },
    size: { control: 'select', options: ['sm', 'md', 'lg'] },
    disabled: { control: 'boolean' },
  },
};
export default meta;

type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: { variant: 'primary', children: 'Place Order' },
};

export const Loading: Story = {
  args: { variant: 'primary', loading: true, children: 'Placing Order...' },
};

// Visual regression testing with Chromatic
// Every story becomes a visual test — auto-detects UI changes on PR
```

---

## 7. Accessibility (a11y)

---

### Q19 — Accessibility fundamentals for React 🔥 PROBABILITY: 78%

**WCAG 2.1 Level AA — the industry standard. Key principles:**

1. **Perceivable** — Users can perceive the interface
2. **Operable** — Users can operate it (keyboard navigation)
3. **Understandable** — Content is clear
4. **Robust** — Works with assistive technologies

**Practical React accessibility:**

```typescript
// 1. Semantic HTML first
// BAD:
<div onClick={handleClick} className="button">Submit</div>
// GOOD:
<button type="submit" onClick={handleClick}>Submit</button>

// 2. ARIA labels for non-obvious elements
<button aria-label="Remove item from cart" onClick={() => removeItem(id)}>
  <TrashIcon aria-hidden="true" /> {/* Icon is decorative */}
</button>

// 3. aria-live regions — announce dynamic content to screen readers
function OrderStatus({ status }: { status: string }) {
  return (
    <div aria-live="polite" aria-atomic="true">
      Order status: {status}
    </div>
  );
}

// 4. Focus management — modal dialogs must trap focus
function Modal({ isOpen, onClose, children }: ModalProps) {
  const dialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    if (isOpen) {
      dialogRef.current?.focus(); // Move focus into modal
    }
  }, [isOpen]);

  return isOpen ? (
    <dialog
      ref={dialogRef}
      aria-modal="true"
      aria-labelledby="modal-title"
      onKeyDown={(e) => e.key === 'Escape' && onClose()}
    >
      {children}
    </dialog>
  ) : null;
}

// 5. Color contrast — minimum 4.5:1 for normal text, 3:1 for large text
// Use Figma plugins or Chrome DevTools accessibility tab to check

// 6. Form labels — every input must have a label
<div>
  <label htmlFor="phone-input">Phone number</label>
  <input
    id="phone-input"
    type="tel"
    aria-describedby="phone-hint"
    aria-invalid={!!errors.phone}
    aria-errormessage="phone-error"
  />
  <span id="phone-hint">Include country code, e.g. +213</span>
  {errors.phone && <span id="phone-error" role="alert">{errors.phone.message}</span>}
</div>

// 7. Skip navigation link — allows keyboard users to skip repeated nav
<a href="#main-content" className="skip-link">Skip to main content</a>
<nav>...</nav>
<main id="main-content">...</main>
```

**Testing accessibility:**
```bash
# Automated: eslint-plugin-jsx-a11y (catches ~30% of issues)
npm install eslint-plugin-jsx-a11y --save-dev

# axe-core integration with jest
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

test('OrderCard has no a11y violations', async () => {
  const { container } = render(<OrderCard order={mockOrder} />);
  expect(await axe(container)).toHaveNoViolations();
});

# Manual: keyboard navigation testing + NVDA/VoiceOver
```

---

## 8. Testing React Applications

---

### Q20 — React Testing Library — philosophy and patterns 🔥 PROBABILITY: 88%

**Core principle:** Test behavior, not implementation. Query by what the user sees, not internal state.

```typescript
// BAD — testing implementation details
expect(wrapper.state('isLoading')).toBe(true);
expect(component.find('.order-item').length).toBe(3);

// GOOD — testing user-visible behavior
const { getByRole, getByText, findByText, queryByRole } = render(
  <OrderList userId="user-1" />
);

// Query priority (use in this order):
// 1. getByRole    — most semantic, mirrors what screen readers see
// 2. getByLabelText — for form inputs
// 3. getByPlaceholderText — fallback for inputs
// 4. getByText    — visible text content
// 5. getByTestId  — last resort (use data-testid sparingly)

test('user can add item to cart', async () => {
  const user = userEvent.setup();
  render(<ProductCard product={mockProduct} />);

  const addButton = screen.getByRole('button', { name: /add to cart/i });
  await user.click(addButton);

  expect(screen.getByText(/item added/i)).toBeInTheDocument();
  expect(screen.getByRole('status')).toHaveTextContent('1 item in cart');
});

test('shows error when order fails', async () => {
  server.use(
    http.post('/api/orders', () => HttpResponse.json({ message: 'Payment failed' }, { status: 402 }))
  );

  render(<CheckoutPage />);
  await user.click(screen.getByRole('button', { name: /place order/i }));

  expect(await screen.findByRole('alert')).toHaveTextContent('Payment failed');
});
```

**MSW (Mock Service Worker) — realistic API mocking:**
```typescript
// handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/orders', ({ request }) => {
    const url = new URL(request.url);
    const userId = url.searchParams.get('userId');
    return HttpResponse.json(mockOrders.filter(o => o.userId === userId));
  }),

  http.post('/api/orders', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: 'new-order-1', ...body, status: 'PENDING' }, { status: 201 });
  }),
];

// setup.ts — shared between tests and browser
const server = setupServer(...handlers);
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

---

## 9. Monorepo & Tooling

---

### Q21 — Monorepo with Nx for React + NestJS (Yassir's setup) 🔥 PROBABILITY: 82%

```
yassir-platform/
├── apps/
│   ├── consumer-web/          React (Vite)
│   ├── driver-app/            React Native or React
│   ├── admin-dashboard/       React
│   ├── order-service/         NestJS
│   └── notification-service/  NestJS
├── libs/
│   ├── shared/
│   │   ├── ui/                Shared React component library
│   │   ├── dto/               Shared TypeScript interfaces (used by FE + BE)
│   │   ├── utils/             date formatting, currency, validation
│   │   └── hooks/             useOrders, useAuth, useGeolocation
│   └── backend/
│       ├── auth/              Shared NestJS auth guards
│       └── database/          Shared TypeORM entities
├── nx.json
└── package.json
```

**Key Nx commands:**
```bash
# Only build/test apps affected by your changes
nx affected:build --base=main
nx affected:test --base=main

# Dependency graph visualization
nx graph

# Generate new library
nx generate @nx/react:library shared-ui --directory=libs/shared/ui

# Run a specific app
nx serve consumer-web
nx serve order-service

# Lint everything
nx run-many --target=lint --all
```

**Shared DTO example (enforces contract between FE and BE):**
```typescript
// libs/shared/dto/src/lib/order.dto.ts
export interface CreateOrderDto {
  userId: string;
  items: Array<{ productId: string; quantity: number }>;
  deliveryAddressId: string;
  idempotencyKey: string;
}

export interface OrderResponseDto {
  id: string;
  status: 'PENDING' | 'CONFIRMED' | 'ASSIGNED' | 'DELIVERED' | 'CANCELLED';
  total: number;
  currency: 'DZD' | 'MAD' | 'TND' | 'EUR';
  estimatedDelivery: string; // ISO 8601
}

// Both NestJS and React import from the same lib — no drift
import { CreateOrderDto } from '@yassir/shared/dto';
```

---

## 10. CI/CD for Frontend

---

### Q22 — CI/CD pipeline for a React app in a monorepo 🔥 PROBABILITY: 75%

```yaml
# .github/workflows/consumer-web.yml
name: Consumer Web CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  affected-check:
    runs-on: ubuntu-latest
    outputs:
      consumer-web-affected: ${{ steps.nx-affected.outputs.consumer-web }}
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 } # Need full history for nx affected
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - id: nx-affected
        run: |
          AFFECTED=$(nx affected:apps --plain --base=origin/main)
          echo "consumer-web=$( echo $AFFECTED | grep -c 'consumer-web' )" >> $GITHUB_OUTPUT

  test-and-lint:
    needs: affected-check
    if: needs.affected-check.outputs.consumer-web-affected == '1'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: nx lint consumer-web
      - run: nx test consumer-web --coverage --ci
      - run: nx build consumer-web  # Type check + build verification
      - uses: codecov/codecov-action@v4

  visual-regression:
    needs: test-and-lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx chromatic --project-token=${{ secrets.CHROMATIC_TOKEN }} --only-changed

  deploy-staging:
    needs: [test-and-lint, visual-regression]
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: nx build consumer-web --configuration=staging
      - uses: google-github-actions/deploy-cloudrun@v2
        with:
          service: consumer-web-staging
          region: europe-west1

  deploy-production:
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    environment: production
    runs-on: ubuntu-latest
    steps:
      - run: nx build consumer-web --configuration=production
      # Blue-green deploy via Cloud Run traffic splitting
      - run: |
          gcloud run deploy consumer-web \
            --image=gcr.io/yassir/consumer-web:${{ github.sha }} \
            --no-traffic  # Deploy without routing traffic yet
          gcloud run services update-traffic consumer-web \
            --to-revisions=LATEST=10  # 10% canary first
```

---

## 11. React Architecture at Scale

---

### Q23 — Feature-based folder structure 🔥 PROBABILITY: 72%

```
src/
├── features/                  # Each feature is self-contained
│   ├── orders/
│   │   ├── api/              orderApi.ts (React Query hooks)
│   │   ├── components/       OrderCard, OrderList, OrderStatus
│   │   ├── hooks/            useOrderActions.ts
│   │   ├── store/            ordersSlice.ts (if using Redux)
│   │   ├── types/            order.types.ts
│   │   └── index.ts          Public API — only export what other features need
│   ├── auth/
│   ├── cart/
│   └── delivery/
├── shared/
│   ├── components/           Button, Input, Modal, Spinner (design system)
│   ├── hooks/                useDebounce, useMediaQuery, useGeolocation
│   ├── utils/                formatCurrency, formatDate, validators
│   └── types/                common.types.ts
├── app/
│   ├── router.tsx            Route definitions
│   ├── store.ts              Redux store configuration
│   └── App.tsx
└── pages/                    Thin page components that compose features
    ├── HomePage.tsx
    ├── OrdersPage.tsx
    └── ProfilePage.tsx
```

**Import rules (enforce with ESLint):**
- Features can import from `shared`
- Features cannot import from other features directly (use events or shared types)
- Pages import from features
- No circular imports

---

### Q24 — Micro-frontends (for Staff-level discussion) 🔥 PROBABILITY: 62%

Relevant at Yassir because different teams own different parts of the super-app (rides, food, wallet).

```javascript
// Module Federation (Webpack 5) — share components across apps at runtime
// ride-app/webpack.config.js (remote)
new ModuleFederationPlugin({
  name: 'rideApp',
  filename: 'remoteEntry.js',
  exposes: {
    './RideMap': './src/components/RideMap',
    './RideBooking': './src/features/booking/RideBooking',
  },
  shared: { react: { singleton: true }, 'react-dom': { singleton: true } },
});

// shell-app/webpack.config.js (host)
new ModuleFederationPlugin({
  name: 'shell',
  remotes: {
    rideApp: 'rideApp@https://rides.yassir.com/remoteEntry.js',
    foodApp: 'foodApp@https://food.yassir.com/remoteEntry.js',
  },
});

// Usage in shell
const RideBooking = React.lazy(() => import('rideApp/RideBooking'));
```

**When to consider MFEs:** When teams are large enough (5+ squads) and deployment independence is more valuable than the added complexity. At Yassir's scale, this is a real architectural consideration.

---

## 12. Quick-Fire Reference Cheatsheet

---

### React Concepts — Fast Answers

| Topic | Key Answer |
|---|---|
| What triggers a re-render? | State change, prop change, context change, parent re-render |
| How to prevent re-render from parent? | `React.memo` + stable prop references (`useCallback`/`useMemo`) |
| Controlled vs uncontrolled input? | Controlled: value from state. Uncontrolled: ref to DOM value (React Hook Form uses uncontrolled) |
| What is reconciliation? | React's diffing algorithm that determines minimal DOM updates needed |
| What is the virtual DOM? | In-memory representation of DOM; React diffs it against real DOM before committing |
| What is hydration? | Attaching React event handlers to server-rendered HTML without re-rendering |
| Keys in lists — why? | Help React identify which items changed/added/removed during reconciliation |
| When does `useEffect` run? | After every render by default; after specific deps change; cleanup runs before next effect or unmount |
| What is prop drilling? | Passing props through many intermediate components; solved by context or state management |
| React Fiber? | React's reconciler rewrite (React 16+); enables incremental rendering and concurrent mode |
| Difference between state and props? | Props: external, passed in, immutable in component. State: internal, managed by component, mutable |

### Hooks Rules

| Rule | Reason |
|---|---|
| Only call at top level | React depends on call order being stable across renders |
| Only call from React functions | Hooks use React's internal state tracking system |
| Custom hooks must start with `use` | Allows linter (eslint-plugin-react-hooks) to enforce hook rules |
| Dependencies must be exhaustive | Stale closures cause bugs when deps are omitted |

### Performance Checklist

| Check | Tool |
|---|---|
| Unnecessary re-renders | React DevTools Profiler → Highlight updates |
| Bundle size | Webpack Bundle Analyzer, bundlephobia.com |
| Core Web Vitals | Lighthouse, PageSpeed Insights, Chrome UX Report |
| Memory leaks | Chrome DevTools Memory tab, heap snapshots |
| Accessibility | axe DevTools extension, Lighthouse a11y audit |
| Network waterfalls | Chrome DevTools Network tab, React Query DevTools |

### State Management Decision Matrix

| Scenario | Solution |
|---|---|
| Toggle open/closed | `useState` |
| Form with many fields | React Hook Form |
| Data from API | TanStack Query (React Query) |
| Sharing between 2-3 components | Lift state + props |
| Sharing across a feature | `useContext` + `useReducer` |
| Complex global state (multiple features) | Zustand or Redux Toolkit |
| URL-driven state (filters, pagination) | React Router + `useSearchParams` |
| Optimistic UI updates | TanStack Query `onMutate` |

---

*Built for Yassir Staff Backend Engineer Interview — React Track*
*Stack context: React 18 · TypeScript · TanStack Query · Zustand · Nx Monorepo · Vite · Shadcn/Radix UI*
