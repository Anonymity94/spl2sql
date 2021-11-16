// ESM
export = spl2sql;
// UMD
export as namespace spl2sql;

declare namespace spl2sql {
  interface IParseOptions {
    /**
     * 结果是否返回json
     * @default false
     */
    json?: boolean;
    /**
     * 是否根据开始时间推算流的老化时间
     * @default true
     */
    hasAgingTime?: boolean;
    /**
     * 时间精度
     * @value 3（毫秒）
     * @value 9（纳秒）
     * @default 9
     */
    timePrecision?: 3 | 9;
    /** 
     * 是否包含开始时间
     * @default true
     */
    includeStartTime?: boolean;
    /** 
     * 是否包含结束时间
     * @default true
     */
    includeEndTime?: boolean;
  }
  interface IParseResult {
    result: {
      /**
       * 原始SPL
       */
      source: string;
      /**
       * 转换出来的SQL
       */
      target: string;
      /**
       * 参数-值的映射对
       */
      params: {
        [propsName: string]: string | Array<string | number>;
      };
      dev: {
        expression: {
          /**
           * 同 `target` 字段
           */
          WHERE: string;
          /**
           * 排序条件
           */
          ORDER_BY: string;
          /**
           * LIMIT条件
           */
          LIMIT: string;
          /**
           * 时间范围
           */
          GENTIMES: {
            time_field: string;
            time_from: number;
            time_to: number;
          };
          /**
           * 自定义返回的字段
           */
          COLUMNS: string;
        };
        /**
         * SPL中包含的查询字段
         *
         * @description: 可以用来做字段合规性检验
         */
        fields: string[];

        fieldCollection: {
          field: string;
          fieldType:
          | "IPv4"
          | "IPv6"
          | "CIDR_IPv4"
          | "CIDR_IPv6"
          | "Array<IPv4>"
          | "Array<IPv6>";
          operator: "like" | "not_like" | "=" | "!=" | ">" | ">=" | "<" | "<=";
          operand: string | number;
        }[];
      };
    };
  }

  function parse(spl: string, options?: IParseOptions): IParseResult;
}