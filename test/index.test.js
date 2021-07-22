#!/usr/bin/env node
const converter = require("../index");

describe("Splunk SPL to ClickHouse SQL test", () => {
  const spl0 = `ipv4_initiator<IPv4> = '1.1.1.1' AND (province = '北京' OR province = '山东') | gentimes start_time start="2020-07-13T00:00:00+08" end="2020-07-13T23:59:59+08" | head 1000 | sort -start_time`;
  test(spl0, () => {
    expect(
      converter.parse(spl0, { json: true, hasAgingTime: false })
    ).toStrictEqual({
      result: {
        source:
          "ipv4_initiator<IPv4> = '1.1.1.1' AND (province = '北京' OR province = '山东') | gentimes start_time start=\"2020-07-13T00:00:00+08\" end=\"2020-07-13T23:59:59+08\" | head 1000 | sort -start_time",
        target:
          "(`ipv4_initiator`=toIPv4(:param_1_0_1_32) AND (`province`=:param_1_38_1_53 OR `province`=:param_1_57_1_72)) AND (`start_time`>= toDateTime64(:param_start_time, 9, 'UTC') AND `start_time` <= toDateTime64(:param_end_time, 9, 'UTC')) ORDER BY start_time DESC LIMIT 0,1000",
        params: {
          param_1_0_1_32: "1.1.1.1",
          param_1_38_1_53: "北京",
          param_1_57_1_72: "山东",
          param_start_time: "2020-07-12 16:00:00",
          param_end_time: "2020-07-13 15:59:59",
        },
        dev: {
          expression: {
            WHERE:
              "(`ipv4_initiator`=toIPv4(:param_1_0_1_32) AND (`province`=:param_1_38_1_53 OR `province`=:param_1_57_1_72)) AND (`start_time`>= toDateTime64(:param_start_time, 9, 'UTC') AND `start_time` <= toDateTime64(:param_end_time, 9, 'UTC'))",
            GENTIMES: {
              time_field: "start_time",
              time_from: 1594569600000,
              time_to: 1594655999000,
            },
            LIMIT: "LIMIT 0,1000",
            ORDER_BY: "ORDER BY start_time DESC",
          },
          fields: ["ipv4_initiator<IPv4>", "province", "start_time"],
        },
      },
    });
  });

  const spl1 = "| search age=30";
  test(spl1, () => {
    const dsl1 = converter.parse(spl1, { json: true });
    expect(dsl1).toStrictEqual({
      result: {
        source: "| search age=30",
        target: "(`age`=:param_1_9_1_15)",
        params: { param_1_9_1_15: "30" },
        dev: {
          expression: { WHERE: "(`age`=:param_1_9_1_15)" },
          fields: ["age"],
        },
      },
    });
  });

  const spl2 = "source=sourceName | search age=30";
  test(spl2, () => {
    const dsl2 = converter.parse(spl2, { json: true });
    expect(dsl2).toStrictEqual({
      result: {
        source: "source=sourceName | search age=30",
        target: "(`age`=:param_1_27_1_33)",
        params: { param_1_27_1_33: "30" },
        dev: {
          expression: { WHERE: "(`age`=:param_1_27_1_33)" },
          fields: ["age"],
        },
      },
    });
  });

  const spl3 = "ipv4_field<IPv4> = 1.1.1.1";
  test(spl3, () => {
    const dsl3 = converter.parse(spl3, { json: true });
    expect(dsl3).toStrictEqual({
      result: {
        source: "ipv4_field<IPv4> = 1.1.1.1",
        target: "(`ipv4_field`=toIPv4(:param_1_0_1_26))",
        params: {
          param_1_0_1_26: "1.1.1.1",
        },
        dev: {
          expression: {
            WHERE: "(`ipv4_field`=toIPv4(:param_1_0_1_26))",
          },
          fields: ["ipv4_field<IPv4>"],
        },
      },
    });
  });

  const spl4 = "ipv4_cidr_field<IPv4> = 1.1.1.1/10";
  test(spl4, () => {
    const dsl4 = converter.parse(spl4, { json: true });
    expect(dsl4).toStrictEqual({
      result: {
        source: "ipv4_cidr_field<IPv4> = 1.1.1.1/10",
        target:
          "(ipv4_cidr_field  between IPv4CIDRToRange(toIPv4(:param_1_0_1_34_ip), :param_1_0_1_34_mask).1 and IPv4CIDRToRange(toIPv4(:param_1_0_1_34_ip), :param_1_0_1_34_mask).2)",
        params: {
          param_1_0_1_34_ip: "1.1.1.1",
          param_1_0_1_34_mask: 10,
        },
        dev: {
          expression: {
            WHERE:
              "(ipv4_cidr_field  between IPv4CIDRToRange(toIPv4(:param_1_0_1_34_ip), :param_1_0_1_34_mask).1 and IPv4CIDRToRange(toIPv4(:param_1_0_1_34_ip), :param_1_0_1_34_mask).2)",
          },
          fields: ["ipv4_cidr_field<IPv4>"],
        },
      },
    });
  });

  const spl5 = "ipv6_cidr_field<IPv6> = 8090::4/10";
  test(spl5, () => {
    const dsl5 = converter.parse(spl5, { json: true });
    expect(dsl5).toStrictEqual({
      result: {
        source: "ipv6_cidr_field<IPv6> = 8090::4/10",
        target:
          "(ipv6_cidr_field  between IPv6CIDRToRange(toIPv6(:param_1_0_1_34_ip), :param_1_0_1_34_mask).1 and IPv6CIDRToRange(toIPv6(:param_1_0_1_34_ip), :param_1_0_1_34_mask).2)",
        params: {
          param_1_0_1_34_ip: "8090::4",
          param_1_0_1_34_mask: 10,
        },
        dev: {
          expression: {
            WHERE:
              "(ipv6_cidr_field  between IPv6CIDRToRange(toIPv6(:param_1_0_1_34_ip), :param_1_0_1_34_mask).1 and IPv6CIDRToRange(toIPv6(:param_1_0_1_34_ip), :param_1_0_1_34_mask).2)",
          },
          fields: ["ipv6_cidr_field<IPv6>"],
        },
      },
    });
  });

  const spl6 = "array_fieid<Array> = '测试'";
  test(spl6, () => {
    expect(converter.parse(spl6, { json: true })).toStrictEqual({
      result: {
        source: "array_fieid<Array> = '测试'",
        target: "( has(array_fieid, :param_1_0_1_25)=1)",
        params: {
          param_1_0_1_25: "测试",
        },
        dev: {
          expression: {
            WHERE: "( has(array_fieid, :param_1_0_1_25)=1)",
          },
          fields: ["array_fieid<Array>"],
        },
      },
    });
  });

  const spl7 = "ipv4_array_fieid<Array<IPv4>> = '1.1.1.1'";
  test(spl7, () => {
    expect(converter.parse(spl7, { json: true })).toStrictEqual({
      result: {
        source: "ipv4_array_fieid<Array<IPv4>> = '1.1.1.1'",
        target: "( has(ipv4_array_fieid, toIPv4(:param_1_0_1_41))=1)",
        params: {
          param_1_0_1_41: "1.1.1.1",
        },
        dev: {
          expression: {
            WHERE: "( has(ipv4_array_fieid, toIPv4(:param_1_0_1_41))=1)",
          },
          fields: ["ipv4_array_fieid<Array<IPv4>>"],
        },
      },
    });
  });

  const spl8 = "ipv6_array_fieid<Array<IPv6>> = '8090::4'";
  test(spl8, () => {
    expect(converter.parse(spl8, { json: true })).toStrictEqual({
      result: {
        source: "ipv6_array_fieid<Array<IPv6>> = '8090::4'",
        target: "( has(ipv6_array_fieid, toIPv6(:param_1_0_1_41))=1)",
        params: {
          param_1_0_1_41: "8090::4",
        },
        dev: {
          expression: {
            WHERE: "( has(ipv6_array_fieid, toIPv6(:param_1_0_1_41))=1)",
          },
          fields: ["ipv6_array_fieid<Array<IPv6>>"],
        },
      },
    });
  });

  const spl9 = "name != '张三'";
  test(spl9, () => {
    expect(converter.parse(spl9, { json: true })).toStrictEqual({
      result: {
        source: "name != '张三'",
        target: "(`name`!=:param_1_0_1_12)",
        params: {
          param_1_0_1_12: "张三",
        },
        dev: {
          expression: {
            WHERE: "(`name`!=:param_1_0_1_12)",
          },
          fields: ["name"],
        },
      },
    });
  });

  const spl10 = "age > 18";
  test(spl10, () => {
    expect(converter.parse(spl10, { json: true })).toStrictEqual({
      result: {
        source: "age > 18",
        target: "(`age`>:param_1_0_1_8)",
        params: {
          param_1_0_1_8: "18",
        },
        dev: {
          expression: {
            WHERE: "(`age`>:param_1_0_1_8)",
          },
          fields: ["age"],
        },
      },
    });
  });

  const spl11 = "age >= 18";
  test(spl11, () => {
    expect(converter.parse(spl11, { json: true })).toStrictEqual({
      result: {
        source: "age >= 18",
        target: "(`age`>=:param_1_0_1_9)",
        params: {
          param_1_0_1_9: "18",
        },
        dev: {
          expression: {
            WHERE: "(`age`>=:param_1_0_1_9)",
          },
          fields: ["age"],
        },
      },
    });
  });

  const spl12 = "age < 18";
  test(spl12, () => {
    expect(converter.parse(spl12, { json: true })).toStrictEqual({
      result: {
        source: "age < 18",
        target: "(`age`<:param_1_0_1_8)",
        params: {
          param_1_0_1_8: "18",
        },
        dev: {
          expression: {
            WHERE: "(`age`<:param_1_0_1_8)",
          },
          fields: ["age"],
        },
      },
    });
  });

  const spl13 = "age <= 18";
  test(spl13, () => {
    expect(converter.parse(spl13, { json: true })).toStrictEqual({
      result: {
        source: "age <= 18",
        target: "(`age`<=:param_1_0_1_9)",
        params: {
          param_1_0_1_9: "18",
        },
        dev: {
          expression: {
            WHERE: "(`age`<=:param_1_0_1_9)",
          },
          fields: ["age"],
        },
      },
    });
  });

  const spl14 = 'name IN ("张三", "李四")';
  test(spl14, () => {
    expect(converter.parse(spl14, { json: true })).toStrictEqual({
      result: {
        source: 'name IN ("张三", "李四")',
        target: "(`name` IN (:param_1_0_1_20))",
        params: {
          param_1_0_1_20: ["张三", "李四"],
        },
        dev: {
          expression: {
            WHERE: "(`name` IN (:param_1_0_1_20))",
          },
          fields: ["name"],
        },
      },
    });
  });

  const spl15 = 'name NOT IN ("张三", "李四")';
  test(spl15, () => {
    expect(converter.parse(spl15, { json: true })).toStrictEqual({
      result: {
        source: 'name NOT IN ("张三", "李四")',
        target: "(`name` NOT IN (:param_1_0_1_24))",
        params: {
          param_1_0_1_24: ["张三", "李四"],
        },
        dev: {
          expression: {
            WHERE: "(`name` NOT IN (:param_1_0_1_24))",
          },
          fields: ["name"],
        },
      },
    });
  });

  const spl16 = 'province LIKE "山%"';
  test(spl16, () => {
    expect(converter.parse(spl16, { json: true })).toStrictEqual({
      result: {
        source: 'province LIKE "山%"',
        target: "(`province` LIKE :param_1_0_1_18)",
        params: {
          param_1_0_1_18: "%山%%",
        },
        dev: {
          expression: {
            WHERE: "(`province` LIKE :param_1_0_1_18)",
          },
          fields: ["province"],
        },
      },
    });
  });

  const spl17 = 'province LIKE "%东"';
  test(spl17, () => {
    expect(converter.parse(spl17, { json: true })).toStrictEqual({
      result: {
        source: 'province LIKE "%东"',
        target: "(`province` LIKE :param_1_0_1_18)",
        params: {
          param_1_0_1_18: "%%东%",
        },
        dev: {
          expression: {
            WHERE: "(`province` LIKE :param_1_0_1_18)",
          },
          fields: ["province"],
        },
      },
    });
  });

  const spl18 = 'name LIKE "C_r_er"';
  test(spl18, () => {
    expect(converter.parse(spl18, { json: true })).toStrictEqual({
      result: {
        source: 'name LIKE "C_r_er"',
        target: "(`name` LIKE :param_1_0_1_18)",
        params: {
          param_1_0_1_18: "%C_r_er%",
        },
        dev: {
          expression: {
            WHERE: "(`name` LIKE :param_1_0_1_18)",
          },
          fields: ["name"],
        },
      },
    });
  });

  const spl19 = "name EXISTS";
  test(spl19, () => {
    expect(converter.parse(spl19, { json: true })).toStrictEqual({
      result: {
        source: "name EXISTS",
        target: "(not empty(`name`))",
        params: {},
        dev: {
          expression: {
            WHERE: "(not empty(`name`))",
          },
          fields: ["name"],
        },
      },
    });
  });

  const spl20 = "name NOT_EXISTS";
  test(spl20, () => {
    expect(converter.parse(spl20, { json: true })).toStrictEqual({
      result: {
        source: "name NOT_EXISTS",
        target: "(empty(`name`))",
        params: {},
        dev: {
          expression: {
            WHERE: "(empty(`name`))",
          },
          fields: ["name"],
        },
      },
    });
  });

  const spl21 = `a=1 && (b=1 AND (c="2" OR c='3')) OR d!='2'`;
  test(spl21, () => {
    expect(converter.parse(spl21, { json: true })).toStrictEqual({
      result: {
        source: "a=1 && (b=1 AND (c=\"2\" OR c='3')) OR d!='2'",
        target:
          "(`a`=:param_1_0_1_3 AND (`b`=:param_1_8_1_11 AND (`c`=:param_1_17_1_22 OR `c`=:param_1_26_1_31)) OR `d`!=:param_1_37_1_43)",
        params: {
          param_1_0_1_3: "1",
          param_1_8_1_11: "1",
          param_1_17_1_22: "2",
          param_1_26_1_31: "3",
          param_1_37_1_43: "2",
        },
        dev: {
          expression: {
            WHERE:
              "(`a`=:param_1_0_1_3 AND (`b`=:param_1_8_1_11 AND (`c`=:param_1_17_1_22 OR `c`=:param_1_26_1_31)) OR `d`!=:param_1_37_1_43)",
          },
          fields: ["a", "b", "c", "d"],
        },
      },
    });
  });

  const spl22 = `a=1 and b IN ('2','3','4') and c LIKE "%a_b%"`;
  test(spl22, () => {
    expect(converter.parse(spl22, { json: true })).toStrictEqual({
      result: {
        source: "a=1 and b IN ('2','3','4') and c LIKE \"%a_b%\"",
        target:
          "(`a`=:param_1_0_1_3 AND `b` IN (:param_1_8_1_26) AND `c` LIKE :param_1_31_1_45)",
        params: {
          param_1_0_1_3: "1",
          param_1_8_1_26: ["2", "3", "4"],
          param_1_31_1_45: "%%a_b%%",
        },
        dev: {
          expression: {
            WHERE:
              "(`a`=:param_1_0_1_3 AND `b` IN (:param_1_8_1_26) AND `c` LIKE :param_1_31_1_45)",
          },
          fields: ["a", "b", "c"],
        },
      },
    });
  });

  const spl23 = `| gentimes start_time start="2020-07-13T00:00:00+08" end="2020-07-13T23:59:59+08"`;
  test(spl23, () => {
    expect(
      converter.parse(spl23, { json: true, hasAgingTime: false })
    ).toStrictEqual({
      result: {
        source:
          '| gentimes start_time start="2020-07-13T00:00:00+08" end="2020-07-13T23:59:59+08"',
        target:
          "(`start_time`>= toDateTime64(:param_start_time, 9, 'UTC') AND `start_time` <= toDateTime64(:param_end_time, 9, 'UTC'))",
        params: {
          param_start_time: "2020-07-12 16:00:00",
          param_end_time: "2020-07-13 15:59:59",
        },
        dev: {
          expression: {
            WHERE:
              "(`start_time`>= toDateTime64(:param_start_time, 9, 'UTC') AND `start_time` <= toDateTime64(:param_end_time, 9, 'UTC'))",
            GENTIMES: {
              time_field: "start_time",
              time_from: 1594569600000,
              time_to: 1594655999000,
            },
          },
          fields: ["start_time"],
        },
      },
    });
  });

  const spl24 = `| gentimes start_time start="2020-07-13T00:00:00+08" end="2020-07-13T23:59:59+08"`;
  test(spl24, () => {
    expect(
      converter.parse(spl24, { json: true, hasAgingTime: false })
    ).toStrictEqual({
      result: {
        source:
          '| gentimes start_time start="2020-07-13T00:00:00+08" end="2020-07-13T23:59:59+08"',
        target:
          "(`start_time`>= toDateTime64(:param_start_time, 9, 'UTC') AND `start_time` <= toDateTime64(:param_end_time, 9, 'UTC'))",
        params: {
          param_start_time: "2020-07-12 16:00:00",
          param_end_time: "2020-07-13 15:59:59",
        },
        dev: {
          expression: {
            WHERE:
              "(`start_time`>= toDateTime64(:param_start_time, 9, 'UTC') AND `start_time` <= toDateTime64(:param_end_time, 9, 'UTC'))",
            GENTIMES: {
              time_field: "start_time",
              time_from: 1594569600000,
              time_to: 1594655999000,
            },
          },
          fields: ["start_time"],
        },
      },
    });
  });

  const spl25 = `| gentimes start_time start=1594569600000 end=1594624363506`;
  test(spl25, () => {
    expect(
      converter.parse(spl25, { json: true, hasAgingTime: false })
    ).toStrictEqual({
      result: {
        source: "| gentimes start_time start=1594569600000 end=1594624363506",
        target:
          "(`start_time`>= toDateTime64(:param_start_time, 9, 'UTC') AND `start_time` <= toDateTime64(:param_end_time, 9, 'UTC'))",
        params: {
          param_start_time: "2020-07-12 16:00:00",
          param_end_time: "2020-07-13 07:12:43",
        },
        dev: {
          expression: {
            WHERE:
              "(`start_time`>= toDateTime64(:param_start_time, 9, 'UTC') AND `start_time` <= toDateTime64(:param_end_time, 9, 'UTC'))",
            GENTIMES: {
              time_field: "start_time",
              time_from: 1594569600000,
              time_to: 1594624363506,
            },
          },
          fields: ["start_time"],
        },
      },
    });
  });

  const spl26 = `| sort -create_time, +age`;
  test(spl26, () => {
    expect(
      converter.parse(spl26, { json: true, hasAgingTime: false })
    ).toStrictEqual({
      result: {
        source: "| sort -create_time, +age",
        target: " ORDER BY create_time DESC,age ASC",
        params: {},
        dev: {
          expression: {
            WHERE: "",
            ORDER_BY: "ORDER BY create_time DESC,age ASC",
          },
          fields: ["create_time", "age"],
        },
      },
    });
  });

  const spl27 = `| head 100`;
  test(spl27, () => {
    expect(converter.parse(spl27, { json: true })).toStrictEqual({
      result: {
        source: "| head 100",
        target: " LIMIT 0,100",
        params: {},
        dev: {
          expression: {
            WHERE: "",
            LIMIT: "LIMIT 0,100",
          },
          fields: [],
        },
      },
    });
  });

  const spl28 = `| fields +name,+age`;
  test(spl28, () => {
    expect(converter.parse(spl28, { json: true })).toStrictEqual({
      result: {
        source: "| fields +name,+age",
        target: "",
        params: {},
        dev: {
          expression: {
            WHERE: "",
            COLUMNS: "`name`,`age`",
          },
          fields: ["name", "age"],
        },
      },
    });
  });
});
