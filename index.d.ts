export = SplToSqlConverter;
export as namespace SplToSqlConverter;

declare namespace SplToSqlConverter {
  interface IParseOptions {
    /**
     * 结果是否返回json
     * 
     * 默认为 true
     */
    json?: boolean;
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
      };
    };
  }

  function parse(spl: string, options?: IParseOptions): IParseResult;
}
