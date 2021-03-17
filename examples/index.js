const converter = require("../lib/converter");
try {
  const result = converter.parse(`| search a=1 and b=2`);
  console.log(result);
} catch (error) {
  console.log(error.message);
}
