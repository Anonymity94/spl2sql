{
  var AND = 'AND';
  var OR = 'OR';
  var PLUS = '+';
  var PARAMS_KEY = ':param_'
  var FIELD_TYPES = ['IPv4' , 'IPv6', 'Array', 'Array<IPv4>', 'Array<IPv6>']


  /**
  * IPv4正则校验
  * @see: https://github.com/sindresorhus/ip-regex/blob/master/index.js
  */
  const IPv4Regex = /^(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)$/;

  /**
  * IPv6正则校验
  * @see: https://github.com/richb-intermapper/IPv6-Regex/blob/master/ipv6validator.js#L15
  */
  const IPv6Regex = /^((?:[a-fA-F\d]{1,4}:){7}(?:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){6}(?:(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d)|:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){5}(?::(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d)|(:[a-fA-F\d]{1,4}){1,2}|:)|(?:[a-fA-F\d]{1,4}:){4}(?:(:[a-fA-F\d]{1,4}){0,1}:(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d)|(:[a-fA-F\d]{1,4}){1,3}|:)|(?:[a-fA-F\d]{1,4}:){3}(?:(:[a-fA-F\d]{1,4}){0,2}:(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d)|(:[a-fA-F\d]{1,4}){1,4}|:)|(?:[a-fA-F\d]{1,4}:){2}(?:(:[a-fA-F\d]{1,4}){0,3}:(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d)|(:[a-fA-F\d]{1,4}){1,5}|:)|(?:[a-fA-F\d]{1,4}:){1}(?:(:[a-fA-F\d]{1,4}){0,4}:(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d)|(:[a-fA-F\d]{1,4}){1,6}|:)|(?::((?::[a-fA-F\d]{1,4}){0,5}:(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d).(25[0-5]|2[0-4]d|[0-1]d{2}|[1-9]?d)|(?::[a-fA-F\d]{1,4}){1,7}|:)))(%[0-9a-zA-Z]{1,})?$/;

  var fields = [];
  var paramsValuesObj = {};

  const currentTime = new Date().getTime();

  /**
  * 判断对象是否为空
  */
  function objectIsEmpty(obj) {
    if (!obj) return true;
    if (Object.keys(obj).length === 0) return true;

    return false;
  }

  /**
  * 数组去重
  */
  function uniqueArray(array) {
    // return arr.reduce(
    //   (prev, cur) => (prev.includes(cur) ? prev : [...prev, cur]),
    //   []
    // );
    // java调用，无法使用ES6语法
    return array.filter((item,index,array)=>{
      return array.indexOf(item) === index 
    })
  }

  function getTimeZone() {
    const d = new Date();
    const timeZoneOffset = d.getTimezoneOffset();

    const op = timeZoneOffset > 0 ? '-' : '+';
    const timeZone = Math.abs(timeZoneOffset) / 60;

    return `${op}${fixedZero(timeZone)}:00`;
  }

  function fixedZero(val) {
    return val * 1 < 10 ? `0${val}` : val;
  }

  function getUtcDate(time) {
    const d = new Date(time || new Date());
    const YYYY = d.getUTCFullYear();
    const M = d.getUTCMonth() + 1;
    const D = d.getUTCDate();
    const H = d.getUTCHours();
    const m = d.getUTCMinutes();
    const s = d.getUTCSeconds();
    return YYYY + '-' + fixedZero(M) + '-' + fixedZero(D) + ' ' + fixedZero(H) + ':' + fixedZero(m) + ':' + fixedZero(s);
  }

  function getLocation(fieldName, fieldType) {
    const { start, end } = location();
    const paramKey = PARAMS_KEY + start.line + '_' + start.offset + '_' + end.line + '_' + end.offset;

    let paramName = paramKey;
      // 根据字段的类型，替换值
    // 'IPv4' , 'IPv6' , 'Array', 'Array<IPv4>' , 'Array<IPv6>' , 'Time'
    if(fieldType === 'IPv4') {
      paramName = `toIPv4(${paramKey})`
    }
    if(fieldType === 'IPv6') {
      paramName = `toIPv6(${paramKey})`
    }
    if(fieldType === 'Array') {
      paramName = `has(${fieldName}, ${paramKey})=1`
    }
    if(fieldType === 'Array<IPv4>') {
      paramName = `has(${fieldName}, toIPv4(${paramKey}))=1`
    }
    if(fieldType === 'Array<IPv6>') {
      paramName = `has(${fieldName}, toIPv6(${paramKey}))=1`
    }

    return {
      paramKey,
      paramName
    }
  }

  function updateParamsValues(key, value) {
    if(!paramsValuesObj.hasOwnProperty(key)) {
      paramsValuesObj[key.replace(':', '')] = value;
    }
  }

  /**
  * 应用名字转换为应用ID
  * @param {Array} names 应用名字
  */
  function replaceAppliationName2Id(names) {
    // 没有应用列表时，直接转成-1，不可搜索
    if (ALL_APPLICATIONS_LIST.length === 0) {
      return [-1];
    }

    let result = [];
    for (let i = 0; i < names.length; i++) {
      const appName = names[i];
      const appIds = ALL_APPLICATIONS_LIST.filter(
        item =>
          item.name &&
          item.name
            .toLocaleUpperCase()
            .indexOf(appName.trim().toLocaleUpperCase()) > -1
      ).map(app => app.id);

      result = [...result, ...appIds];
    }
    const uniqueResult = uniqueArray(result).join('');
    if(uniqueResult.length > 0) {
      return uniqueResult;
    }
    return [-1]
  }

  const APPLICATION_NAME_KEY = 'application_name'; 
  const APPLICATION_ID_KEY = 'application_id'; 
  const { applications, json = false } = options;
  let applicationsJson = {};
  // 解析应用列表
  if(Object.prototype.toString.call(applications) === '[object Object]') {
    applicationsJson = applications;
  } else if(typeof applications === 'string') {
    try {
      applicationsJson = JSON.parse(applications);
    } catch (error) {
      applicationsJson= {};
    }
  }
  // TODO: 解析可用字段，用于判断字段是否可用

  let ALL_APPLICATIONS_LIST = [];
  for(let key in applicationsJson) {
    ALL_APPLICATIONS_LIST.push({id: key, name: applicationsJson[key]});
  }
}

start
  = SplExpression

SplExpression "SplExpression"
  = sourceAndsearch:SourceAndSearchExpression tailArr:(_? divider _? TailCommand)* __? {
    // select * from tableName where xxxx order by xxxx limit 0,10;
    const [sourceName, search] = sourceAndsearch;
    var sql = '';
    var tailMap = {
      WHERE: search
    };
    // 组装sql
    tailArr.forEach(item => {
    	if(item && item[3]) {
        tailMap = Object.assign(tailMap, item[3])
      }
    })

    // // 展示的字段
    // if(tailMap.COLUMNS) {
    //   sql += 'SELECT ' + tailMap.COLUMNS;
    // } else {
    // sql += 'SELECT *';
    // }
    // // from
    // sql += ' FROM ' + '`' + sourceName + '`';
    // // where
    if(search) {
      sql += search
    }

    if(tailMap.GENTIMES) {
      const {time_field, time_from, time_to} = tailMap.GENTIMES;

      // 转UTC时间
      const startTime = getUtcDate(time_from);
      const endTime = getUtcDate(time_to);

      const timeWhere = '`' + time_field + '`'  + `>= toDateTime64(:param_start_time, 9, 'UTC') AND ` + '`' +  time_field + '`' + ` <= toDateTime64(:param_end_time, 9, 'UTC')`;
      if(!search) {
        tailMap.WHERE = sql = sql + timeWhere;
      } else {
        tailMap.WHERE = sql = sql + ` AND ${timeWhere}`;
      }
      paramsValuesObj['param_start_time'] = startTime;
      paramsValuesObj['param_end_time'] = endTime;
    }
    // order by
    if(tailMap.ORDER_BY) {
      sql += ' ' + tailMap.ORDER_BY;
    }

    if(tailMap.LIMIT) {
      sql += ' ' + tailMap.LIMIT;
    }

    // sql += ';'

    if(json) {
      return {
        result: {
          source: text(),
          target: sql,
          params: paramsValuesObj,
          dev: {
            expression: tailMap,
            fields: fields,
          }
        }
      };

    }

    return {
      result: JSON.stringify({
        source: text(),
        target: sql,
        params: paramsValuesObj,
        dev: {
          expression: tailMap,
          fields: fields,
        }
      })
    };
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
  = fieldObj:FieldWithType __ op:(equal / notEqual / gte / gt / lte / lt) __ value:Value {
    const { fieldName, fieldType } = fieldObj;
    var opText = '';
    // @see: https://clickhouse.tech/docs/zh/sql-reference/operators/
    if(op === '=') {opText = '='}
    if(op === '!=') {opText = '!='}
    if(op === '>') {opText = '>'}
    if(op === '>=') {opText = '>='}
    if(op === '<') {opText = '<'}
    if(op === '<=') {opText = '<='}
    var { paramKey, paramName } = getLocation(fieldName, fieldType);
    if(opText) {
      if(fieldName === APPLICATION_NAME_KEY) {
        // 把应用名字替换成应用ID
        // 这里肯定只有一个值
        const appIdsArray = replaceAppliationName2Id([value]);
        updateParamsValues(paramKey, appIdsArray);
        return '`' + APPLICATION_ID_KEY + '`' +  ' IN (' + paramKey +')';
      };
      // 检查IP
      if(fieldType === 'IPv4' || fieldType === 'Array<IPv4>') {
        if(!IPv4Regex.test(value)) {
          throw Error(`${value}不是个正确的IPv4`)
        }
      }
      if(fieldType === 'IPv6' || fieldType === 'Array<IPv6>') {
        if(!IPv6Regex.test(value)) {
          throw Error(`${value}不是个正确的IPv6`)
        }
      }
      updateParamsValues(paramKey, value)
      return '`' + fieldName + '`' + opText + paramName;
    }
    return ""
  }
  / InCondition
  / NotInCondition
  / LikeCondition
  / NotLikeCondition
  
InCondition "InCondition"
  = fieldObj:FieldWithType _ IN _ parenStart __ values:MultipleValue __ parenEnd {
    const { fieldName, fieldType } = fieldObj;
    const { paramKey, paramName } = getLocation(fieldName, fieldType);
    if(paramKey === APPLICATION_NAME_KEY) {
      const newValues = replaceAppliationName2Id(values);
      updateParamsValues(paramKey, newValues);
      return '`' + APPLICATION_ID_KEY + '`' + ' IN ' + '(' + paramKey + ')';
    }
    // ip类型的比较特殊
    if(fieldType === 'IPv4' || fieldType === 'IPv6') {
      // 输入 ip4<IPv4> IN ('10.0.0.1', '10.0.0.2')
      // 输出 `ip4` IN (toIPv4(:param_X_0),toIPv4(:param_X_1))
      const paramNameArr = [];
      values.forEach((item, index) => {
        var paramItem = paramKey + '_' + index;
        updateParamsValues(paramItem, item);
        if(fieldType === 'IPv4') {
          if(!IPv4Regex.test(item)) {
            throw Error(`${item}不是个正确的IPv4`)
          }
          paramNameArr.push(`toIPv4(${paramItem})`)
        } else {
          if(!IPv6Regex.test(item)) {
            throw Error(`${item}不是个正确的IPv6`)
          }
          paramNameArr.push(`toIPv6(${paramItem})`)
        }
      })
      return '`' + fieldName + '`' + ' IN ' + '(' + paramNameArr.join(',') + ')';
    } else if(fieldType === 'Array' || fieldType === 'Array<IPv4>' || fieldType === 'Array<IPv6>') {
      // 输入 ip4<Array<IPv4>> IN ('10.0.0.1', '10.0.0.2')
      // 输出 `ip4` hasAny(字段名, [toIPv4(:par1), toIPv4(:par2)])=1
      const paramNameArr = [];
      values.forEach((item, index) => {
        var paramItem = paramKey + '_' + index;
        updateParamsValues(paramItem, item);
        if(fieldType === 'Array<IPv4>') {
          if(!IPv4Regex.test(item)) {
            throw Error(`${item}不是个正确的IPv4`)
          }
          paramNameArr.push(`toIPv4(${paramItem})`)
        } else if(fieldType === 'Array<IPv6>') {
          if(!IPv6Regex.test(item)) {
            throw Error(`${item}不是个正确的IPv6`)
          }
          paramNameArr.push(`toIPv6(${paramItem})`)
        } else {
          paramNameArr.push(paramItem)
        }
      })
      // @see: https://clickhouse.tech/docs/en/sql-reference/functions/array-functions/#hasany
      return '`' + fieldName + '`' + ' hasAny(`'+ fieldName + '`, [' + paramNameArr.join(',') + '])=1';
    } else {
      updateParamsValues(paramKey, values)
      return '`' + fieldName + '`' + ' IN ' + '(' + paramName + ')';
    }
  }
  
NotInCondition "NotInCondition"
  = fieldObj:FieldWithType _ NOT_IN _ parenStart __ values:MultipleValue __ parenEnd {
    const { fieldName, fieldType } = fieldObj;
    const { paramKey, paramName } = getLocation(fieldName, fieldType);
    if(fieldName === APPLICATION_NAME_KEY) {
      const newValues = replaceAppliationName2Id(values);
      updateParamsValues(paramKey, newValues);
      return '`' + APPLICATION_ID_KEY + '`' + ' NOT IN ' + '(' + paramKey + ')';
    }

    // ip类型的比较特殊
    if(fieldType === 'IPv4' || fieldType === 'IPv6') {
      // 输入 ip4<IPv4> IN ('10.0.0.1', '10.0.0.2')
      // 输出 `ip4` IN (toIPv4(:param_X_0),toIPv4(:param_X_1))
      const paramNameArr = [];
      values.forEach((item, index) => {
        var paramItem = paramKey + '_' + index;
        updateParamsValues(paramItem, item);
        if(fieldType === 'IPv4') {
          if(!IPv4Regex.test(item)) {
            throw Error(`${item}不是个正确的IPv4`)
          }
          paramNameArr.push(`toIPv4(${paramItem})`)
        } else {
          if(!IPv6Regex.test(item)) {
            throw Error(`${item}不是个正确的IPv6`)
          }
          paramNameArr.push(`toIPv6(${paramItem})`)
        }
      })
      return '`' + fieldName + '`' + ' NOT IN ' + '(' + paramNameArr.join(',') + ')';
    } else if(fieldType === 'Array' || fieldType === 'Array<IPv4>' || fieldType === 'Array<IPv6>') {
      // 输入 ip4<Array<IPv4>> IN ('10.0.0.1', '10.0.0.2')
      // 输出 `ip4` hasAny(字段名, [toIPv4(:par1), toIPv4(:par2)])=1
      const paramNameArr = [];
      values.forEach((item, index) => {
        var paramItem = paramKey + '_' + index;
        updateParamsValues(paramItem, item);
        if(fieldType === 'Array<IPv4>') {
          if(!IPv4Regex.test(item)) {
            throw Error(`${item}不是个正确的IPv4`)
          }
          paramNameArr.push(`toIPv4(${paramItem})`)
        } else if(fieldType === 'Array<IPv6>') {
          if(!IPv6Regex.test(item)) {
            throw Error(`${item}不是个正确的IPv6`)
          }
          paramNameArr.push(`toIPv6(${paramItem})`)
        } else {
          paramNameArr.push(paramItem)
        }
      })
      // @see: https://clickhouse.tech/docs/en/sql-reference/functions/array-functions/#hasany
      return '`' + fieldName + '`' + ' hasAny(`'+ fieldName + '`, [' + paramNameArr.join(',') + '])=0';
    } else {
      updateParamsValues(paramKey, values)
      return '`' + fieldName + '`' + ' NOT IN ' + '(' + paramName + ')';
    }

  }

MultipleValue "MultipleValue"
  = first:Value rest:MoreMultipleValues* {
    var result = [first].concat(rest);
    return uniqueArray(result)
  }

MoreMultipleValues "MoreMultipleValues"
	= __ ',' __ value:Value { return value }

LikeCondition "LikeCondition"
 = fieldObj:FieldWithType __ LIKE __ value:LikeValue {
    const { fieldName, fieldType } = fieldObj;
    if (fieldType.indexOf('IP') > -1) {
      throw Error('IP类型的字段不支持LIKE')
    }
    const { paramKey, paramName } = getLocation(fieldName, fieldType);
    if(fieldName === APPLICATION_NAME_KEY) {
    const newValues = replaceAppliationName2Id([value]);
    updateParamsValues(paramKey, newValues);
    return '`' + APPLICATION_ID_KEY + '`' + ' IN ' + '(' + paramKey + ')';
  }

  updateParamsValues(paramKey, value)
  // @see: https://clickhouse.tech/docs/en/sql-reference/functions/array-functions/#array-filter
  if(fieldType === 'Array') {
    return 'arrayFilter(x -> x LIKE '+ paramKey +',`'+ fieldName  +'`)'
  }
  return '`' + fieldName + '`' + ' LIKE ' +  paramName;
 }

NotLikeCondition "NotLikeCondition"
 = fieldObj:FieldWithType __ NOT_LIKE __ value:LikeValue {
    const { fieldName, fieldType } = fieldObj;
    if (fieldType.indexOf('IP') > -1) {
      throw Error('IP类型的字段不支持 NOT LIKE')
    }
    const { paramKey, paramName } = getLocation(fieldName, fieldType);
    if(fieldName === APPLICATION_NAME_KEY) {
    const newValues = replaceAppliationName2Id([value]);
    updateParamsValues(paramKey, newValues);
    return '`' + APPLICATION_ID_KEY + '`' + ' NOT IN ' + '(' + paramKey + ')';
  }

  updateParamsValues(paramKey, value)
  // @see: https://clickhouse.tech/docs/en/sql-reference/functions/array-functions/#array-filter
  if(fieldType === 'Array') {
    return 'arrayFilter(x -> x NOT LIKE '+ paramKey +',`'+ fieldName  +'`)'
  }
  return '`' + fieldName + '`' + ' NOT LIKE ' +  paramName;
 }

LikeValue
	= $[\u4e00-\u9fa5_a-zA-Z0-9a-zA-Z0-9\._\-%_\[\]^]+
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
  // / FieldsCommand
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
    var endTime = currentTime;
    if(endTimeArr.length > 0) {
    	endTime = endTimeArr[0][5]
    }
    
    return {
      GENTIMES: {
        time_field: field,
        time_from: startTime,
        time_to: endTime
      }
    }
  }

TimeValue "TimeValue"
  = Timestamp
  / RelativeTime
  / TimeNow
  / '"' char:(UTCTime / YYYYMMDDHHmmss / RelativeTime / TimeNow / Timestamp) '"' {
    return char
  }
  / "'" char:(UTCTime / YYYYMMDDHHmmss / RelativeTime / TimeNow / Timestamp) "'" {
    return char
  }

// 相对时间
// @see: https://www.elastic.co/guide/en/elasticsearch/reference/7.8/common-options.html#date-math
// @eg. -10m #1分钟前
// @eg. -1d #1天前
// @eg. -1M #1个月前
// y - Year
// M - Months
// w - Weeks
// d - Days
// h - Hours
// H - Hours
// m - Minutes
// s - Seconds
RelativeTime "RelativeTime"
  = 'now-' number:Integer timeUnit:TimeUnit {
    var endTime = new Date(currentTime);
    var diffSenonds = 0;
    if (timeUnit === "y") {
      endTime = endTime.setFullYear(endTime.getFullYear() - number);
    }
    if (timeUnit === "M") {
      endTime = endTime.setMonth(endTime.getMonth() - number);
    }
    if (timeUnit === "w") {
      endTime = endTime.setDate(endTime.getDate() - number * 7);
    }
    if (timeUnit === "d") {
      endTime = endTime.setDate(endTime.getDate() - number);
    }
    if (timeUnit === "h" || timeUnit === "H") {
      endTime = endTime.setHours(endTime.getHours() - number);
    }
    if (timeUnit === "m") {
      endTime = endTime.setMinutes(endTime.getMinutes() - number);
    }
    if (timeUnit === "s") {
      endTime = endTime.setSeconds(endTime.getSeconds() - number);
    }

    return new Date(endTime).getTime();
  }

// 当前时间，转成时间戳
TimeNow "now" = 'now' { return currentTime }
// 时间单位
TimeUnit "TimeUnit" = ('y' / 'M' / 'w' / 'd' / 'h' / 'H' / 'm' / 's') {return text()}

// 毫秒时间戳
Timestamp "Timestamp" = timestamp:Integer {
  if(String(timestamp).length !== 13) {
    throw Error('请输入毫秒级的时间戳')
  }
  return timestamp
}

// UTC时间
UTCTime "UTCTime"
  // @eg. 2017-04-01T12:34:56+08
  // @eg. 2017-04-01T12:34:56+0800
  // @eg. 2017-04-01T12:34:56+08:00
  = year:TimeInteger '-' month:TimeInteger '-' day:TimeInteger 'T' hours:TimeInteger ':' minutes:TimeInteger ':' seconds:TimeInteger timeZone:TimeZone {
    if(String(year).length !== 4 || String(month).length !== 2 || String(day).length !== 2 || String(hours).length !== 2 || String(minutes).length !== 2 || String(seconds).length !== 2) {
      throw Error("时间格式错误。时间格式：YYYY-MM-DDTHH:mm:ssZ")
    }
    var time = '';
    if(timeZone) {
      var [op, timeZoneString, suffix] = timeZone;
      // 判断时区范围
      var timeZoneNumber = parseInt(timeZoneString);
      if(timeZoneNumber > 12 || timeZoneNumber < -12) {
        throw Error('错误的时区范围')
      }
      if(
      	(suffix && suffix.length < 2)
        || (suffix && suffix.length === 2 && (suffix[0] !== '0' || suffix[1] !== '0'))
      	|| (timeZoneNumber < 10 && (timeZoneString.charAt(0) !== '0' || (timeZoneString.charAt(0) === '0' && timeZoneString.length !== 2)))) {
          throw Error(`时区格式错误. 未能解析日期字段 [${text()}], 请输入 [${op}0${timeZoneNumber}] 或 [${op}0${timeZoneNumber}:00]`)
      }

      if(suffix.length === 0) {
        time = `${text()}:00`
      } else {
        time = text()
      }
    } else {
    	time = `${text()}+08:00`
    }

    return new Date(time).getTime();
  }

YYYYMMDDHHmmss "YYYYMMDDHHmmss"
 = year:TimeInteger '-' month:TimeInteger '-' day:TimeInteger _ hours:TimeInteger ':' minutes:TimeInteger ':' seconds:TimeInteger {
   if(String(year).length !== 4 || String(month).length !== 2 || String(day).length !== 2 || String(hours).length !== 2 || String(minutes).length !== 2 || String(seconds).length !== 2) {
     throw Error("时间格式错误。时间格式：YYYY-MM-DD HH:mm:ss")
   }
   return new Date(text().replace(/ /, 'T') + getTimeZone()).getTime()
 }

TimeInteger "TimeInteger"
 = num:[0-9]+ { return num.join('') }

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
      ].indexOf(field) === -1
    ) {
      fields.push(field);
    }
    return field
  }

FieldWithType 'FieldWithType' 
  = str:([A-Za-z0-9_\.]+) type:FieldType?{
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
      ].indexOf(field) === -1
    ) {
      fields.push(field);
    }
    return {fieldName: field, fieldType: type}
  }

FieldType 'FieldType'
  // = '<' type:('IPv4' / 'IPv6' / 'Array' / 'Array<IPv4>' / 'Array<IPv6>') '>'{
  = '<' frist:([A-Za-z0-9]+) second:FieldSecondType? '>'{
    const topTypeArr = ['IPv4' , 'IPv6' , 'Array']; // 'Number' , 'String' , 
    const str = frist.join('');
    if(topTypeArr.indexOf(str) === -1) {
      throw Error(`字段类型只能是${FIELD_TYPES.join('、')}`)
    }
    console.log(str, second)
    return str + (second ? `<${second}>` : '')
  }

FieldSecondType 'FieldSecondType'
  = '<' arr:([A-Za-z0-9]+) '>'{
    const str = arr.join('');
    console.log(str)
    if(['IPv4' , 'IPv6'].indexOf(str) === -1) {
      throw Error(`字段类型只能是${FIELD_TYPES.join('、')}`)
    }

    return str;
  }


// ----- 字段值 -----
Value "Value"
  = $[\u4e00-\u9fa5_a-zA-Z0-9\.\-?*:\/]+
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
NOT_LIKE = "NOT LIKE"i
