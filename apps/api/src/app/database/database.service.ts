import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { createPool, DatabasePool, sql } from 'slonik';

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(DatabaseService.name);
  private pool: DatabasePool | null = null;

  async onModuleInit() {
    const connectionString = `postgresql://${process.env.PGUSER}:${process.env.PGPASSWORD}@${process.env.PGHOST}:${process.env.PGPORT}/${process.env.PGDATABASE}`;
    
    this.logger.log(`Connecting to database: ${process.env.PGHOST}:${process.env.PGPORT}/${process.env.PGDATABASE}`);
    
    try {
      this.pool = await createPool(connectionString, {
        maximumPoolSize: 10,
      });
      
      // Test connection
      await this.pool.query(sql.unsafe`SELECT NOW()`);
      this.logger.log('Database connection established successfully');
      
    } catch (error) {
      this.logger.error('Failed to connect to database:', error);
      throw error;
    }
  }

  async onModuleDestroy() {
    if (this.pool) {
      await this.pool.end();
      this.logger.log('Database connection closed');
    }
  }

  getPool(): DatabasePool {
    if (!this.pool) {
      throw new Error('Database pool not initialized');
    }
    return this.pool;
  }

  async query(sqlQuery: any) {
    if (!this.pool) {
      throw new Error('Database pool not initialized');
    }
    return this.pool.query(sqlQuery);
  }
}