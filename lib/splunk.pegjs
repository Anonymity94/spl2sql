{
  var EQUAL = '=';
  var NOT_EQUAL = '!=';

  var AND = 'AND';
  var OR = 'OR';

  var PLUS = '+';
  
  var fields = [];

  /**
  * 数组去重
  */
  function uniqueArray(arr) {
    return arr.reduce(
      (prev, cur) => (prev.includes(cur) ? prev : [...prev, cur]),
      []
    );
  }

  /**
  * 判断对象是否为空
  */
  function objectIsEmpty(obj) {
    if (!obj) return true;
    if (Object.keys(obj).length === 0) return true;

    return false;
  }

  function fixedZero(val) {
    return val * 1 < 10 ? `0${val}` : val;
  }

  function getUtcDate(time) {
    const d = new Date(time);
    const YYYY = d.getUTCFullYear();
    const M = d.getUTCMonth() + 1;
    const D = d.getUTCDate();
    const H = d.getUTCHours();
    const m = d.getUTCMinutes();
    const s = d.getUTCSeconds();
    return YYYY + '-' + fixedZero(M) + '-' + fixedZero(D) + ' ' + fixedZero(H) + ':' + fixedZero(m) + ':' + fixedZero(s);
  }

  /**
  * 组合查询条件语句
  * @param {Object} searchDsl 字段的搜索条件
  * @param {Object} timeQuery 时间搜索条件
  */
  function renderFullDsl(searchDsl, timeQuery) {
    var isFieldQueryEmpty = objectIsEmpty(searchDsl);
    var isTimeQueryEmpty = objectIsEmpty(timeQuery);

    if (isFieldQueryEmpty && isTimeQueryEmpty) {
      return { query: { match_all: {} } };
    }

    if (!isFieldQueryEmpty && isTimeQueryEmpty) {
      return {
        query: {
          bool: {
            filter: [searchDsl],
            adjust_pure_negative: true,
            boost: 1.0
          }
        }
      };
    }

    if (isFieldQueryEmpty && !isTimeQueryEmpty) {
      return {
        query: {
          bool: {
            filter: [timeQuery],
            adjust_pure_negative: true,
            boost: 1.0
          }
        }
      };
    }

    return {
      query: {
        bool: {
          filter: [{
            bool: {
              must: [searchDsl, timeQuery]
            }
          }],
          adjust_pure_negative: true,
          boost: 1.0
        }
      }
    };
  }
}

start
  = SplExpression

SplExpression "SplExpression"
  = sourceAndsearch:SourceAndSearchExpression tail:(_? divider _? TailCommand)* __? {
    const [sourceName, search] = sourceAndsearch;
    // select * from tableName where xxxx order by xxxx limit 0,10;
    var sql = '';
    var tailMap = {
      WHERE: search
    };
    // 组装sql
    tail.forEach(item => {
    	if(item && item[3]) {
        tailMap = Object.assign(tailMap, item[3])
      }
    })

    // 展示的字段
    if(tailMap.COLUMNS) {
      sql += 'SELECT ' + tailMap.COLUMNS;
    } else {
    sql += 'SELECT *';
    }
    // from
    sql += ' FROM ' + sourceName;
    // where
    if(search) {
      sql += ' WHERE ' + search
    }

    // order by
    if(tailMap.ORDER_BY) {
      sql += ' ' + tailMap.ORDER_BY;
    }

    if(tailMap.LIMIT) {
      sql += ' ' + tailMap.LIMIT;
    }

    return {
      target: sql,
      dev: {
        expression: tailMap,
        fields: fields
      }
    }
  }

// ----- 查询条件 -----
SourceAndSearchExpression "SourceAndSearchExpression"
  = SOURCE __ equal __ source:DataSource search:(_ SearchExpression)? {
  	if(!search || !search[1] || search.length === 0) {
    	return [source, ""]
    }
    return [source, search[1]];
  }

SearchExpression "SearchExpression"
  = divider? __ (SEARCH _)? region:RegionOr {
    console.log('region', region)
    return region
  }

RegionOr "RegionOr"
  = left:RegionAnd Whitespace+ OrExpression Whitespace+ right:RegionOr { return left + ' OR ' + right }
  / RegionAnd

RegionAnd "RegionAnd"
  = left:FactorBlock Whitespace+ AndExpression Whitespace+ right:RegionAnd { return left + ' AND ' + right }
  / FactorBlock

FactorBlock "FactorBlock"
 = BasicCondition
 / parenStart Whitespace* RegionOr:RegionOr Whitespace* parenEnd { return '(' + RegionOr + ')' }

// 基本的等式
BasicCondition "BasicCondition"
  = field:Field __ op:(equal / notEqual / gte / gt / lte / lt) __ value:Value {
    var opText = '';
    // @see: https://clickhouse.tech/docs/zh/sql-reference/operators/
    if(op === '=') {opText = '='}
    if(op === '!=') {opText = '!='}
    if(op === '>') {opText = '>'}
    if(op === '>=') {opText = '>='}
    if(op === '<') {opText = '<'}
    if(op === '<=') {opText = '<='}
    if(opText) {
      return field + opText + '`' + value + '`'
    }
    return ""
  }
  / InCondition
  / NotInCondition
  / LikeCondition
  
InCondition "InCondition"
  = field:Field _ IN _ parenStart __ values:MultipleValue __ parenEnd {
    return field + ' IN ' +  '(' + values.map(v => '`' + v + '`').join(',') + ')';
  }
  
NotInCondition "NotInCondition"
  = field:Field _ NOT_IN _ parenStart __ values:MultipleValue __ parenEnd {
    return field + ' NOT IN ' +  '(' + values.map(v => '`' + v + '`').join(',') + ')';
  }

MultipleValue "MultipleValue"
  = first:Value rest:MoreMultipleValues* {
    var result = [first].concat(rest);
    return uniqueArray(result)
  }

MoreMultipleValues "MoreMultipleValues"
	= __ ',' __ value:Value { return value }

LikeCondition "LikeCondition"
 = field:Field __ LIKE __ value:LikeValue {
   return field + ' LIKE ' +  '`' + value + '`';
 }

LikeValue
	= $[a-zA-Z0-9\._\-%_]+
  / '"' char:LikeValue '"' {
    return char
  }
  / "'" char:LikeValue "'" {
    return char
  }
   / "`" char:LikeValue "`" {
    return char
  }

// ----- search后面的其他命令 -----
TailCommand "TailCommand"
  // = SortCommand
  = GentimesCommand
  // = FieldsCommand
  // = HeadCommand

// ----- 查询结果中包含（排除）的字段 -----
// @see: https://docs.splunk.com/Documentation/Splunk/8.0.4/SearchReference/Fields
FieldsCommand "FieldsCommand"
  = __ FIELDS _ first:Column rest:MoreColumns* {
    var fieldsArr = [first].concat(rest)
    // +的放在includes，-放在excludes
    var includes = [];
    var excludes = [];
    fieldsArr.forEach(({op, field}) => {
      if(op === '+') {includes.push(field)}
      if(op === '-') {excludes.push(field)}
    })
    return {
      COLUMNS: includes.map(v => '`' + v + '`').join(',')
    }
  }

Column "Column"
  = _? op:(plus / minus)? _? field:Field { return {op: op || '+', field} }

MoreColumns 'MoreColumns'
  = __ ',' __ field:Column { return field }

// ----- head -----
// @see: https://docs.splunk.com/Documentation/Splunk/8.0.4/SearchReference/Head
HeadCommand "HeadCommand"
  = __ HEAD _ number:Integer {
    if(number <=0) {
      throw Error('返回结果的数量至少为1');
    }
 	  return {
      LIMIT: 'LIMIT 0,' + number
    }
  }

// ----- sort 排序 -----
// @see: https://docs.splunk.com/Documentation/Splunk/8.0.4/SearchReference/Sort
SortCommand "SortCommand"
  = __ SORT _ op:(plus / minus)? first:Field rest:MoreSort* {
 	  // +ip/ip ==> {ip: {order: 'asc'}}
    // -ip ==> {ip: {order: 'desc'}}
    // [[操作符, 字段], [操作符, 字段]]
    var sortsArr = [[op, first]].concat(rest);
    var sortText = sortsArr.map(([op, field]) => {
      return field + ' ' + ((!op || op === PLUS) ? 'ASC': 'DESC')
    })

    return {
      ORDER_BY: 'ORDER BY' + ' ' + sortText
    }
  }

MoreSort "MoreSort"
  = __ ',' __ op:(plus / minus)? field:Field { return [op, field] }

// ----- 时间范围 -----
// @see: https://docs.splunk.com/Documentation/Splunk/8.0.4/SearchReference/Gentimes
GentimesCommand "GentimesCommand"
  // 开始时间 / 截至时间
  = __ GENTIMES _ field:Field _ 'start'i __ equal __ startTime:TimeValue endTimeArr:(_ 'end'i __ equal __ TimeValue __)* {
    var endTime = 'now';
    if(endTimeArr.length > 0) {
    	endTime = endTimeArr[0][5]
    }
    
    return {
      gentimes: {
        time_field: field,
        time_from: startTime,
        time_to: endTime
      }
    }
  }

TimeValue "TimeValue"
  = UTCTime
  / Timestamp
  / '"' char:TimeValue '"' {
    return char
  }
  / "'" char:TimeValue "'" {
    return char
  }

// 毫秒时间戳
Timestamp "Timestamp" = timestamp:Integer {
  if(String(timestamp).length !== 13) {
    throw Error('请输入毫秒级的时间戳')
  }
  // 时间转UTC标准时间
  return timestamp
}

// UTC时间
UTCTime "UTCTime"
  // @eg. 2017-04-01T12:34:56+08
  // @eg. 2017-04-01T12:34:56+0800
  // @eg. 2017-04-01T12:34:56+08:00
  = year:Integer '-' month:Integer '-' day:Integer 'T' hours:Integer ':' minutes:Integer ':' seconds:Integer timeZone:TimeZone {
    if(timeZone) {
      var [op, timeZoneString, suffix] = timeZone;
      // 判断时区范围
      var timeZoneNumber = parseInt(timeZoneString);
      if(timeZoneNumber > 12 || timeZoneNumber < -12) {
        throw Error('错误的时区范围')
        // throw Error('Wrong time zone range')
      }
      if(
      	(suffix && suffix.length < 2)
        || (suffix && suffix.length === 2 && (suffix[0] !== '0' || suffix[1] !== '0'))
      	|| (timeZoneNumber < 10 && (timeZoneString.charAt(0) !== '0' || (timeZoneString.charAt(0) === '0' && timeZoneString.length !== 2)))) {
          throw Error(`时区格式错误. 未能解析日期字段 [${text()}], 请输入 [${op}0${timeZoneNumber}] 或 [${op}0${timeZoneNumber}:00]`)
          // throw Error(`Bad time zone format. failed to parse date field [${text()}], please enter [${op}0${timeZoneNumber}] or [${op}0${timeZoneNumber}:00]`)
      }
      
      return text()
    } else {
    	// 拼接时区信息
    	return `${text()}+08:00`
    }
  }

TimeZone "TimeZone" = op:('+' / '-') numberArr:(num:[0-9]+) suffix:('00' / ':00')? {
  var numberstring = numberArr.join('')
  suffix = suffix || numberstring.slice(2, 4);

	return [op, numberstring.slice(0, 2), suffix]
}

// ----- 空白、换行符 -----
_ = [ \t\r\n]+
__ = [ \t\r\n]*
Whitespace = [ ]

// ----- 数据来源 -----
DataSource "DataSource" = $[a-zA-Z0-9\._\-\*]+

// ----- 字段名称 -----
Field 'Field' 
  = str:[A-Za-z0-9_\.]+ {
    const field = str.join('');
    // TODO: 排除命令
    // 这里为什么会识别到命令前缀呢？
    if (
      fields.indexOf(field) === -1 &&
      [
        "fields", "FIELDS",
        "sort",  "SORT",
        "gentimes", "GENTIMES",
        "head", "HEAD",
        "timeout", "TIMEOUT",
        "track_total_hits", "TRACK_TOTAL_HITS",
        "terminate_after", "TERMINATE_AFTER"
      ].indexOf(field) === -1
    ) {
      fields.push(field);
    }
    return field
  }
// ----- 字段值 -----
Value "Value"
  = $[\u4e00-\u9fa5_a-zA-Z0-9\.\-?*:\/<>]+
  / '"' char:QuotedValue '"' {
    return char
  }
  / "'" char:QuotedValue "'" {
    return char
  }

QuotedValue "QuotedValue"
   = $[\u4e00-\u9fa5_a-zA-Z0-9\.\-?*:\/<> =,]+

Integer = num:[0-9]+ { return parseInt(num.join('')); }

AndExpression
  = 'AND'i
  / '&&' { return AND }

OrExpression
  = "OR"i
  / '||' { return OR }

Boolean
  = 'true' { return true; }
  / 'false' { return false; }

divider = '|'
equal = '='
notEqual = '!='
gte = '>='
gt = '>'
lte = '<='
lt = '<'
plus = '+'
minus = '-'
parenStart = '('
parenEnd = ')'

SOURCE = 'SOURCE'i
SEARCH = 'SEARCH'i
FIELDS = "FIELDS"i
HEAD = 'HEAD'i
SORT = 'SORT'i
GENTIMES = 'GENTIMES'i
SIZE = 'SIZE'i
TIMEOUT = 'TIMEOUT'i
TRACK_TOTAL_HITS = 'TRACK_TOTAL_HITS'i
TERMINATE_AFTER = 'TERMINATE_AFTER'i
TOP = "TOP"i
LIMIT = "LIMIT"i
IN = 'IN'i
NOT_IN = "NOT IN"i
LIKE = "LIKE"i
