/** Types generated for queries found in "apps/api/src/app/database/queries/03_financial/ledger/create_ledger_entry.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type ledger_account_type_enum = 'accounts_receivable' | 'credit' | 'refund' | 'revenue';

export type transaction_type_enum = 'adjustment' | 'charge' | 'credit' | 'refund';

/** 'CreateLedgerEntry' parameters type */
export type ICreateLedgerEntryParams = void;

/** 'CreateLedgerEntry' return type */
export interface ICreateLedgerEntryResult {
  account_type: ledger_account_type_enum;
  amount: string;
  category: string | null;
  created_at: Date;
  currency: string;
  description: string | null;
  id: string;
  reference_id: string;
  reference_type: string;
  stripe_reference: string | null;
  tenant_id: number;
  transaction_date: Date;
  transaction_type: transaction_type_enum;
}

/** 'CreateLedgerEntry' query type */
export interface ICreateLedgerEntryQuery {
  params: ICreateLedgerEntryParams;
  result: ICreateLedgerEntryResult;
}

const createLedgerEntryIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_create_ledger_entry()\n-- Type: INSERT\n-- Description: Create a new general ledger entry\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_transaction_type transaction_type_enum - Type of transaction\n--   $3: p_account_type ledger_account_type_enum - Account type\n--   $4: p_amount DECIMAL(10,2) - Transaction amount\n--   $5: p_reference_type VARCHAR(50) - Reference type\n--   $6: p_reference_id UUID - Reference ID\n--   $7: p_description TEXT - Transaction description\n--   $8: p_stripe_reference VARCHAR(255) - Stripe reference (optional)\n-- Returns: Created ledger entry\n-- ================================================================\n\n-- Create a new general ledger entry with automatic category assignment\n\nINSERT INTO general_ledger (\n    tenant_id,\n    transaction_type,\n    transaction_date,\n    account_type,\n    amount,\n    currency,\n    reference_type,\n    reference_id,\n    stripe_reference,\n    category,\n    description\n) VALUES (\n    $1::INTEGER,\n    $2::transaction_type_enum,\n    CURRENT_DATE,\n    $3::ledger_account_type_enum,\n    $4::DECIMAL(10,2),\n    'USD',\n    $5::VARCHAR(50),\n    $6::UUID,\n    $8::VARCHAR(255),\n    CASE \n        WHEN $5 = 'subscription' AND $2::TEXT = 'charge' THEN 'recurring_monthly'\n        WHEN $5 = 'service' THEN 'one_time'\n        WHEN $2::TEXT = 'refund' THEN 'refund'\n        ELSE NULL\n    END,\n    $7::TEXT\n)\nRETURNING \n    id,\n    tenant_id,\n    transaction_type,\n    transaction_date,\n    account_type,\n    amount,\n    currency,\n    reference_type,\n    reference_id,\n    stripe_reference,\n    category,\n    description,\n    created_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_create_ledger_entry()
 * -- Type: INSERT
 * -- Description: Create a new general ledger entry
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_transaction_type transaction_type_enum - Type of transaction
 * --   $3: p_account_type ledger_account_type_enum - Account type
 * --   $4: p_amount DECIMAL(10,2) - Transaction amount
 * --   $5: p_reference_type VARCHAR(50) - Reference type
 * --   $6: p_reference_id UUID - Reference ID
 * --   $7: p_description TEXT - Transaction description
 * --   $8: p_stripe_reference VARCHAR(255) - Stripe reference (optional)
 * -- Returns: Created ledger entry
 * -- ================================================================
 * 
 * -- Create a new general ledger entry with automatic category assignment
 * 
 * INSERT INTO general_ledger (
 *     tenant_id,
 *     transaction_type,
 *     transaction_date,
 *     account_type,
 *     amount,
 *     currency,
 *     reference_type,
 *     reference_id,
 *     stripe_reference,
 *     category,
 *     description
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::transaction_type_enum,
 *     CURRENT_DATE,
 *     $3::ledger_account_type_enum,
 *     $4::DECIMAL(10,2),
 *     'USD',
 *     $5::VARCHAR(50),
 *     $6::UUID,
 *     $8::VARCHAR(255),
 *     CASE 
 *         WHEN $5 = 'subscription' AND $2::TEXT = 'charge' THEN 'recurring_monthly'
 *         WHEN $5 = 'service' THEN 'one_time'
 *         WHEN $2::TEXT = 'refund' THEN 'refund'
 *         ELSE NULL
 *     END,
 *     $7::TEXT
 * )
 * RETURNING 
 *     id,
 *     tenant_id,
 *     transaction_type,
 *     transaction_date,
 *     account_type,
 *     amount,
 *     currency,
 *     reference_type,
 *     reference_id,
 *     stripe_reference,
 *     category,
 *     description,
 *     created_at
 * ```
 */
export const createLedgerEntry = new PreparedQuery<ICreateLedgerEntryParams,ICreateLedgerEntryResult>(createLedgerEntryIR);


