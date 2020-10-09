#!/usr/bin/env node
const converter = require("../index");

describe("Splunk SPL to SQL test", () => {
  const spl1 = "source=table | search age=30";
  test(spl1, () => {
    const sql1 = converter.parse(spl1);
    expect(sql1).toStrictEqual({
      target: "",
      dev: {
        time_range: {},
        fields: ["age"]
      }
    });
  });
});
