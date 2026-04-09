// const fs = require("fs");
//
// fs.readFile(__filename, () => {
//   console.log("this is readFile 1");
// });
// setTimeout(() => {
//   console.log("this is setTimeout 2");
//   process.nextTick(
//     console.log.bind(console, "this is the inner next tick inside setTimeout")
//   );
// }, 0);
// setTimeout(() => {
//     console.log("this is setTimeout 3");
//     Promise.resolve().then(() => console.log("this is Promise.resolve 4"));
//
// }, 0);
// setTimeout(() => console.log("this is setTimeout 4"), 0);
//



process.nextTick(() => console.log("this is process.nextTick 1"));
process.nextTick(() => {
  console.log("this is process.nextTick 2");
  process.nextTick(
    console.log.bind(console, "this is the inner next tick inside next tick")
  );
});
process.nextTick(() => console.log("this is process.nextTick 3"));

Promise.resolve().then(() => console.log("this is Promise.resolve 1"));
Promise.resolve().then(() => {
  console.log("this is Promise.resolve 2");
  process.nextTick(
    console.log.bind(
      console,
      "this is the inner next tick inside Promise then block"
    )
  );
});
Promise.resolve().then(() => console.log("this is Promise.resolve 3"));
