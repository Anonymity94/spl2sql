export = SplToSqlConverter;
export as namespace converter;

declare namespace SplToSqlConverter {
  interface IParseOptions {
    /**
     * 结果是否返回json
     */
    json?: boolean;
    /**
     * 应用
     */
    applications?: {
      [propsName: string | number]: string;
    };
  }
  interface IParseResult {
    result: {
      source: string;
      target: string;
      params: {
        [propsName: string]: string | Array<string | number>;
      };
      dev: {
        expression: {
          [propsName: IExpressionKey]: string;
        };
        fields: string[];
      };
    };
  }

  type IExpressionKey = "WHERE" | "ORDER_BY" | "LIMIT" | "GENTIMES" | "COLUMNS";
  function parse(spl: string, options?: IParseOptions): IParseResult;
}
