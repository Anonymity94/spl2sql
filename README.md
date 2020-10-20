# Splunk-SPL-to-SQL

## Usage

```js
const converter = require("splunk-to-sql")

try {
  const result = converter.parse(`source=table | search a=1 and b=2`, {
    applications: {"1":"腾讯","2":"阿里"},
    json: true // 结果以json形式返回
  });
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



##  字段带类型时的转换逻辑

### IPv4

> [toIPv4(string)](https://clickhouse.tech/docs/en/sql-reference/functions/ip-address-functions/#toipv4string)

```json
# 输入
ipv4_field<IPv4> = 1.1.1.1

# 输出
 sql: `ipv4_field` = toIPv4(:paramId)
 params:  {paramId: '1.1.1.1'}
```

### IPv6

> [toIPv6(string)](https://clickhouse.tech/docs/en/sql-reference/functions/ip-address-functions/#toipv6string)

```json
# 输入
ipv6_field<IPv6> = 8090::4

# 输出
 sql: `ipv6_field` = toIPv6(:paramId)
 params: {paramId: '8090::4'}
```



### Array

> [has(arr, elem)](https://clickhouse.tech/docs/en/sql-reference/functions/array-functions/#hasarr-elem)

```json
# 输入
array_fieid<Array> = '测试'

# 输出
sql: has(`array_fieid`, :paramId) = 1
params: {paramId: '测试'}
```



### Array<IPv4>

```json
# 输入
ipv4_array_fieid<Array<IPv4>> = '1.1.1.1'

# 输出
sql: has(`ipv4_array_fieid`, toIPv4(:paramId)) = 1
params: {paramId: '测试'}
```



### Array<IPv6>

```json
# 输入
ipv4_array_fieid<Array<IPv6>> = '1.1.1.1'

# 输出
sql: has(`ipv4_array_fieid`, toIPv6(:paramId)) = 1
params: {paramId: '测试'}
```





## 一个完整的搜索


## 语法说明

```JSON
source <tableName>
# 搜索字段
[[| search] <field-name> <operate> <field-value>] [<logical-connector> <field-name> <operate> <field-value>]]

# 限制时间
[| gentimes <time-field> start <time-value> [end <time-value>]]
```

## 参数说明

|         参数          |    名称    | 描述                                                         |
| :-------------------: | :--------: | :----------------------------------------------------------- |
|    `<field-name>`     |   字段名   | 允许输入大小字母、数字、下划线[`_`]、英文的点[`.`]<br />例如：`start_time`、`cup.usage` |
|      `<operate>`      |   操作符   | `=`、`!=`、`>`、`>=`、`<`、`<=`、`IN`、`NOT IN`、`LIKE`、`NOT LIKE`<br />注意：不区分大小写 |
|    `<field-value>`    |   字段值   | 允许输入大小字母、数字、下划线[`_`]、英文的点[`.`]、冒号[`:`]、正斜杠[`/`]、通配符[`%`]、通配符[`_`]。<br />允许内容被单引号[`''`]或双引号[`""`]包裹。<br />例如：`12`、`"1.2"`、`"中国"`、`"a_b"` |
| `<logical-connector>` | 逻辑关系符 | `AND`、`OR`、`&&`、`||`<br />注意：不区分大小写              |
|    `<time-field>`     | 时间字段名 | 同`<field-name>`                                             |
|    `<time-value>`     | 时间内容值 | [时间范围](#时间范围)<br/>绝对时间值请用单引号或双引号包裹                                        |



## Demo

### 字段条件

⚠️ 开头的 `| search` 可省略

#### 操作符 `=`

```json
# 含义：字段a 等于 1.2.3.4
source=table | search a = 1.2.3.4
# 等价于
source=table a = 1.2.3.4

```

#### 操作符 `!=`

```json
# 含义：字段b 不等于 1.2.3.4
source=table b != 1.2.3.4
```

#### 操作符 `>`

```json
# 含义：字段c 大于 100
source=table c > 100
```

#### 操作符 `>=`

```json
# 含义：字段c 大于等于 100
source=table c >= 100
```

#### 操作符 `<`

```json
# 含义：字段d 小于 100
source=table d < 200
```

#### 操作符 `<=`

```json
# 含义：字段d 小于等于 <200
source=table c <= 200
```

#### 操作符 `IN`

可用于搜索多个值

```json
# 含义：字段name=张三 或者 name=李四
source=table name IN ("张三", "李四")

# 等价于
source=table name = "张三" OR name = "李四"
```

#### 操作符 `NOT IN`

可用于排除多个值

```json
# 含义：字段name!=张三 并且 name!=李四
source=table name NOT IN ("张三", "李四")

# 等价于
source=table name != "张三" AND name != "李四"
```

#### 操作符 `LIKE`

可用于模糊查询，条件可以分为四种匹配模式

① `％` 表示零个或任意多个字符

```json
# 以"山"开头的省份，例如：山东、山西
source=table province LIKE "山%"

# 以"东"结尾的省份，例如：山东、广东
source=table province LIKE "%东"

# 包含"马"名字，例如：马云、马化腾、司马光、
source=table name LIKE "%马%"
```

② `_` 任意单个字符、匹配单个任意字符

```json
# 以 "C" 开头，然后是一个任意字符，然后是 "r，然后是任意字符，然后是 "er"：
source=table name LIKE "C_r_er"
```


#### 操作符 `NOT LIKE`

可用于排除字段。用法同操作符 `LIKE`



#### 使用逻辑关系表达式查询多个字段

```
source=table a=1 AND b>4
source=table a=1 && (b=1 AND (c="2" OR c='3')) OR d!='2'
source=table a=1 and b IN ('2','3','4') and c LIKE "%a_b%"
source=table a=1 or b in ('2','3','4')
```




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

  - `2017-10-14T12:34:56+08`
  - `2017-10-14T12:34:56+0800`
  - `2017-10-14T12:34:56+08:00`
  - `2020-10-14 12:34:56`  没有时区时以当前时区为准
  
  - 时间戳（毫秒）

#### 使用Demo

- `| gentimes <time-field> start="2020-07-13T00:00:00+08" end="2020-07-13T23:59:59+08"`
- `| gentimes <time-field> start=now-7d end=now`
- `| gentimes <time-field> start=1594569600000 end=1594624363506`


## 关于应用名字的处理

因为数据库存储的是应用的ID，web界面查询的是应用的名字，所以需要特殊处理一下。

### `LIKE` 和 `NOT LIKE` 时

会把通配符转换为正则表达式

- `$` => `.{0,}`
- `_` => `.{1}`
- 如果首字母不是 `$` 和 `_`， 正则表达式增加 `^` 
- 如果尾字母不是 `$` 和 `_`， 正则表达式增加 `$` 

### 模糊查询时

- 先忽略大小写，进行精确查询
- 如果精确匹配没有找到结果，再进行模糊查询

## Links

- [SELECT Query](https://clickhouse.tech/docs/en/sql-reference/statements/select/)
