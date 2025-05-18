### 🔑 The Sliding Window Mindset

Imagine you’re a photographer framing a perfect shot. You adjust your camera’s viewfinder (the window) to capture the
best possible segment of a scene (the array). You keep expanding until something ruins the shot (e.g., a photobomber),
then you reposition the frame to exclude the problem. This is sliding window!

### 🌟 When to Use Sliding Window

Use it when the problem asks for:

- Subarrays/substrings (contiguous elements).
- Maximizing/minimizing length, sum, or frequency.
- Constraints that let you adjust the window incrementally (e.g., "at most K zeros allowed").

### Key Signal:

If brute force would check all subarrays (O(n²)), sliding window can often optimize it to O(n).

### 🛠️ The Universal Framework

For any sliding window problem, follow these steps:

1️⃣ Define the Window State

- Track what defines a "valid" window.
    - Example: In the problem, a valid window has ≤1 zeros (since deleting one zero makes it all 1s).
    - Another Example: For "longest substring with ≤2 distinct characters", track character frequencies.

2️⃣ Initialize Pointers and Trackers

- left = 0, right expands the window.
- Variables like zero_count, max_length, or a frequency map.

3️⃣ Expand the Window

- Loop with right to add elements to the window.
- Update your tracker (e.g., increment zero_count if nums[right] == 0).

4️⃣ Shrink Until Valid

- While the window is invalid (e.g., zero_count > 1), move left forward.
- Update the tracker as elements leave the window (e.g., decrement zero_count if nums[left] == 0).

5️⃣ Update the Answer

- After ensuring the window is valid, calculate the current window size.
- Compare it with the best answer so far.

### 💡 How to Adapt to Any Problem

Let’s break down the thought process using your problem 1493:

Step 1: Define Validity

- After deleting one element, the subarray must be all 1s.
- This means the original window can have at most 1 zero (we’ll delete it).

Step 2: Track State

- zero_count: How many zeros are in the current window.
- max_length: Best window length found.

Step 3: Expand and Shrink

- For each right, add nums[right] to the window.
- If zero_count > 1, shrink the window by moving left until zero_count ≤ 1.

Step 4: Calculate Result

- The longest valid window is max_length - 1 (since we must delete one element, even if it’s a 1).
- Edge Case: If all elements are 1s, you still delete one, so subtract 1.

### 🧠 Build Intuition with Analogies

Think of the window as a car’s sunroof:

- You open it fully (right moves) until rain (invalid condition) starts pouring in.
- You close it just enough (left moves) to block the rain.
- The goal is to maximize the open area while staying dry.

# 🚀 Apply to Other Problems

Example 1: Longest Substring Without Repeating Characters

- Validity: All characters in the window are unique.
- Track: A frequency map of characters.
- Shrink: When a duplicate appears, move left past the last occurrence.

Example 2: Maximum Average Subarray I (Fixed Size)

- Validity: Window size exactly k.
- Track: Sum of the window.
- Expand/Shrink: Not needed—window size is fixed. Just slide it.

### ⚠️ Common Pitfalls

- Forgetting Edge Cases:
  All elements valid? All invalid? Handle these explicitly.

- Updating the Result Incorrectly:
  Ensure the window is valid before calculating the answer.

- Overcomplicating State Tracking:
  Track only what’s necessary for validity (e.g., don’t count 1s if you only care about 0s).

### 🔄 Practice Strategy

- Start with fixed-size window problems (e.g., "Find max sum of subarrays of size K").
- Move to dynamic windows with simple constraints (e.g., "Smallest subarray with sum ≥ S").
- Tackle complex constraints (e.g., "Longest substring with at most K distinct characters").

