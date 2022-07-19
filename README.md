# Splunk-SPL-to-ClickHouse-SQL

一个将 `Splunk SPL` 转化成 `ClickHouse SQL` 的转换器，并做了一些拓展。

可以用来做自定义过滤查询。

## 使用

```ts
import converter from "spl2sql";

try {
  const result = converter.parse(`| search a=1 and b=2`, {
    json: true, // 结果以json形式返回
  });
  console.log(result);
} catch (error) {
  console.log(error.message);
}
```

```html
<script src="../dist/spl2sql.js"></script>

<script>
  try {
    var result = splToSqlConverter.parse(value, {
      json: true,
    });
  } catch (error) {
    console.log(error);
  }
</script>
```

## 开发

```sh
# install package
yarn

# build
yarn build

# test
yarn test
```


## 一个完整的搜索

```
# 源IPv4等于1.1.1.1 并且 (省份=北京 或者 北京=山东)
ipv4_initiator<IPv4> = '1.1.1.1' AND (province = '北京' OR province = '山东')
# 时间范围7天内
| gentimes start_time start=now-7d end=now
# 按照 start_time 倒序
| sort -start_time
# 返回前1000条数据
| head 1000
```

## 语法说明

```
# 搜索表名，可以省略
[source <tableName>]
# 搜索字段
[[| search] <field-name> <operate> <field-value>] [<logical-connector> <field-name> <operate> <field-value>]]

# 限制时间
[| gentimes <time-field> start <time-value> [end <time-value>]]

# 字段排序
# +: ASC
# -: DESC
[| sort [+/-]<field-name>[,[+/-]<field-name>]]

# 返回命中条件的前 N 条
[| head <number>]

# 查询结果中包含（排除）的字段
# +: 包含字段
# -: 排除字段
[| fields [+/-]<field-name>[,[+/-]<field-name>]
```

## 参数说明

|         参数          |    名称    | 描述                                                                                                                     |
| :-------------------: | :--------: | :----------------------------------------------------------------------------------------------------------------------- |
|    `<field-name>`     |   字段名   | 允许输入大小字母、数字、下划线`_`、英文的点`.`<br />例如：`start_time`、`cup.usage`                                      |
|      `<operate>`      |   操作符   | `=`、`!=`、`>`、`>=`、`<`、`<=`、`IN`、`NOT IN`、`LIKE`、`NOT LIKE`、`EXISTS`、`NOT_EXISTS`<br />注意：不区分大小写      |
|    `<field-value>`    |   字段值   | 无特殊限制，允许内容被单引号`''`或双引号`""`包裹，但是引号内不允许出现引号。<br />例如：`12`、`"1.2"`、`"中国"`、`"a_b"` |
| `<logical-connector>` | 逻辑关系符 | `AND`、`OR`、`&&`<br />注意：不区分大小写                                                                                |
|    `<time-field>`     | 时间字段名 | 同`<field-name>`                                                                                                         |
|    `<time-value>`     | 时间内容值 | [时间范围](#时间范围)<br/>绝对时间值请用单引号或双引号包裹                                                               |

## 字段带类型时的转换逻辑

### IPv4

> [toIPv4(string)](https://clickhouse.tech/docs/en/sql-reference/functions/ip-address-functions/#toipv4string)

```
ipv4_field<IPv4> = 1.1.1.1
```

支持 `CIDR` 格式

> [ipv4cidrtorangeipv4-cidr](https://clickhouse.tech/docs/en/sql-reference/functions/ip-address-functions/#ipv4cidrtorangeipv4-cidr)

```
ipv4_cidr_field<IPv4> = 1.1.1.1/10
```

### IPv6

> [toIPv6(string)](https://clickhouse.tech/docs/en/sql-reference/functions/ip-address-functions/#toipv6string)

```
ipv6_field<IPv6> = 8090::4
```

支持 `CIDR` 格式

> [ipv4cidrtorangeipv4-cidr](https://clickhouse.tech/docs/en/sql-reference/functions/ip-address-functions/#ipv4cidrtorangeipv4-cidr)

```
ipv6_cidr_field<IPv6> = 8090::4/10
```

### Array

> [has(arr, elem)](https://clickhouse.tech/docs/en/sql-reference/functions/array-functions/#hasarr-elem)

```
array_fieid<Array> = '测试'
```

### Array<IPv4>

```
ipv4_array_fieid<Array<IPv4>> = '1.1.1.1'
```

### Array<IPv6>

```
ipv6_array_fieid<Array<IPv6>> = '8090::4'
```

## Demo

### 字段条件

⚠️ 开头的 `| search` 可省略

#### 操作符 `=`

```
# 含义：字段a 等于 1.2.3.4
| search a = 1.2.3.4
# 等价于
 a = 1.2.3.4

```

#### 操作符 `!=`

```
# 含义：字段 name 不等于 张三
name != '张三'
```

#### 操作符 `>`

```
# 含义：字段 age 大于 18
age > 18
```

#### 操作符 `>=`

```
# 含义：字段 age 大于等于 18
c >= 18
```

#### 操作符 `<`

```
# 含义：字段 age 小于 18
age < 18
```

#### 操作符 `<=`

```
# 含义：字段 age 小于等于 18
age <= 18
```

#### 操作符 `IN`

可用于搜索多个值

```
# 含义：字段name=张三 或者 name=李四
name IN ("张三", "李四")

# 等价于
name = "张三" OR name = "李四"
```

#### 操作符 `NOT IN`

可用于排除多个值

```
# 含义：字段name!=张三 并且 name!=李四
name NOT IN ("张三", "李四")

# 等价于
name != "张三" AND name != "李四"
```

#### 操作符 `LIKE`

可用于模糊查询，条件可以分为四种匹配模式

① `％` 表示零个或任意多个字符

```
# 以"山"开头的省份，例如：山东、山西
province LIKE "山%"

# 以"东"结尾的省份，例如：山东、广东
province LIKE "%东"

# 包含"马"名字，例如：马云、马化腾、司马光、
name LIKE "%马%"
```

② `_` 任意单个字符、匹配单个任意字符

```
# 以 "C" 开头，然后是一个任意字符，然后是 "r，然后是任意字符，然后是 "er"：
name LIKE "C_r_er"
```

#### 操作符 `NOT LIKE`

可用于排除字段。用法同操作符 `LIKE`

#### 操作符 `EXISTS`

**⚠️ 因 `empty()` 仅适用于 `String` 和`Array` 类型，所以需要格外注意使用场景**

> [string-functions/#empty](https://clickhouse.tech/docs/en/sql-reference/functions/string-functions/#empty)

排除 `''` 或 `NULL` 或 `[]` ，其他的都会被命中。

```
# name 字段不为空
name EXISTS
```

#### 操作符 `NOT_EXISTS`

**⚠️ 因 `NOT empty()` 仅适用于 `String` 和`Array` 类型，所以需要格外注意使用场景**

> [string-functions/#notempty](https://clickhouse.tech/docs/en/sql-reference/functions/string-functions/#notempty)

搜索不存在值的字段，字段值为 `''` 或 `NULL` 或 `[]` 时会被命中。

```
# name 不存在值
name NOT_EXISTS
```

#### 使用逻辑关系表达式查询多个字段

```
a=1 AND b>4
a=1 && (b=1 AND (c="2" OR c='3')) OR d!='2'
a=1 and b IN ('2','3','4') and c LIKE "%a_b%"
a=1 or b in ('2','3','4')
```

#### 字段排序

```
# 按 create_time 倒序，按 age 正序
| sort -create_time, +age
```

#### 返回前 N 条记录

```
| head 100
```

#### 自定义结果中返回的字段

```
| fields +name,+age
```

针对时间格式做处理一些调整，这里的时间格式和`Splunk`中标准的时间格式不同。

#### splunk 标准格式

`Splunk` 中的时间格式为：`| gentimes start=<timestamp> [end=<timestamp>] [increment=<increment>]` [Gentimes 文档](https://docs.splunk.com/Documentation/Splunk/8.0.5/SearchReference/Gentimes)

其中 `timestamp` 的格式为：`MM/DD/YYYY[:HH:MM:SS] | <int>`

---

#### 修改后的时间内容值

`| gentimes <time-field> start=<time-value> [end=<time-value>]`

时间的内容值可以分为**相对时间**和**绝对时间**：

- 相对时间

  - `now` 当前时间

  - `now-<int>(y | M | w | d | H | h | m | s)`

    | 单位       | 说明      |
    | ---------- | --------- |
    | `y`        | `Year`    |
    | `M`        | `Months`  |
    | `w`        | `Weeks`   |
    | `d`        | `Days`    |
    | `h` or `H` | `Hours`   |
    | `m`        | `Minutes` |
    | `s`        | `Seconds` |

    例如：`now-7d`，7 天前

- 绝对时间

  - `2017-10-14T12:34:56+08`
  - `2017-10-14T12:34:56+0800`
  - `2017-10-14T12:34:56+08:00`
  - `2020-10-14 12:34:56` 没有时区时以当前时区为准

  - 时间戳（毫秒）

#### 使用 Demo

- `| gentimes <time-field> start="2020-07-13T00:00:00+08" end="2020-07-13T23:59:59+08"`
- `| gentimes <time-field> start=now-7d end=now`
- `| gentimes <time-field> start=1594569600000 end=1594624363506`

## Links

- [SPL: Search Commands](https://docs.splunk.com/Documentation/Splunk/8.1.2/SearchReference/Abstract)
- [SELECT Query](https://clickhouse.tech/docs/en/sql-reference/statements/select/)
