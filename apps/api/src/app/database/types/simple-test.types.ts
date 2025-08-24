/** Types generated for queries found in "apps/api/src/app/database/queries/00_test/simple-test.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetVersion' parameters type */
export type IGetVersionParams = void;

/** 'GetVersion' return type */
export interface IGetVersionResult {
  db_version: string | null;
}

/** 'GetVersion' query type */
export interface IGetVersionQuery {
  params: IGetVersionParams;
  result: IGetVersionResult;
}

const getVersionIR: any = {"usedParamSet":{},"params":[],"statement":"SELECT version() as db_version"};

/**
 * Query generated from SQL:
 * ```
 * SELECT version() as db_version
 * ```
 */
export const getVersion = new PreparedQuery<IGetVersionParams,IGetVersionResult>(getVersionIR);


/** 'GetCurrentTimestamp' parameters type */
export type IGetCurrentTimestampParams = void;

/** 'GetCurrentTimestamp' return type */
export interface IGetCurrentTimestampResult {
  current_time: Date | null;
}

/** 'GetCurrentTimestamp' query type */
export interface IGetCurrentTimestampQuery {
  params: IGetCurrentTimestampParams;
  result: IGetCurrentTimestampResult;
}

const getCurrentTimestampIR: any = {"usedParamSet":{},"params":[],"statement":"SELECT NOW() as current_time"};

/**
 * Query generated from SQL:
 * ```
 * SELECT NOW() as current_time
 * ```
 */
export const getCurrentTimestamp = new PreparedQuery<IGetCurrentTimestampParams,IGetCurrentTimestampResult>(getCurrentTimestampIR);


