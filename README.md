# Splunk-SPL-to-SQL

## Usage

```js
const converter = require("splunk-to-sql")

try {
  const result = converter.parse(`source=table | search a=1 and b=2`, {
    applications: {"1":"腾讯","2":"阿里"},
    json: true // 结果以json形式返回
  });
  // 完整的es搜索语句
  console.log(result)
} catch (error) {
  console.log(error.message);
}

```

## Test

```sh
yarn
npm run test
```

## 一个完整的搜索


## 语法说明




## 参数说明



## Demo

### 查全部


### 时间条件

### 字段条件


#### ① 查询一个字段


#### ② 使用逻辑关系表达式查询多个字段


#### ③ 模糊查询


#### ④ 查询范围


#### ⑤ 字段命中多个值


## 时间范围

针对时间格式做处理一些调整，这里的时间格式和`Splunk`中标准的时间格式不同。

#### splunk标准格式

`Splunk` 中的时间格式为：`| gentimes start=<timestamp> [end=<timestamp>] [increment=<increment>]` [Gentimes文档](https://docs.splunk.com/Documentation/Splunk/8.0.5/SearchReference/Gentimes)

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

    例如：`now-7d`，7天前

- 绝对时间

  - `2017-04-01T12:34:56+08`
  - `2017-04-01T12:34:56+0800`
  - `2017-04-01T12:34:56+08:00`
  - 时间戳（毫秒）

#### 使用Demo

- `| gentimes time-field start=2020-07-13T00:00:00+08 end=2020-07-13T23:59:59+08`
- `| gentimes start=now-7d end=now`
- `| gentimes start=1594569600000 end=1594624363506`


## Links

- [SELECT Query](https://clickhouse.tech/docs/en/sql-reference/statements/select/)
