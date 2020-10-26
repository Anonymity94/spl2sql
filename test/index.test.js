#!/usr/bin/env node
const converter = require("../index");
describe("Splunk SPL to SQL test", () => {
  const spl1 = "| search age=30";
  test(spl1, () => {
    const dsl1 = converter.parse(spl1, { json: true });
    expect(dsl1).toStrictEqual({
      result: {
        source: "| search age=30",
        target: "`age`=:param_1_9_1_15",
        params: { param_1_9_1_15: "30" },
        dev: {
          expression: { WHERE: "`age`=:param_1_9_1_15" },
          fields: ["age"]
        }
      }
    });
  });
});
