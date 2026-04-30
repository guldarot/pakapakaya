import { ZodSchema } from 'zod';
import { Request, Response } from 'express';

import { sendError } from './http.js';

export function readBody<T>(
  schema: ZodSchema<T>,
  req: Request,
  res: Response,
): T | null {
  const result = schema.safeParse(req.body);
  if (!result.success) {
    sendError(res, 400, 'Invalid request body', result.error.flatten());
    return null;
  }
  return result.data;
}

export function readParams<T>(
  schema: ZodSchema<T>,
  req: Request,
  res: Response,
): T | null {
  const result = schema.safeParse(req.params);
  if (!result.success) {
    sendError(res, 400, 'Invalid route params', result.error.flatten());
    return null;
  }
  return result.data;
}

export function readQuery<T>(
  schema: ZodSchema<T>,
  req: Request,
  res: Response,
): T | null {
  const result = schema.safeParse(req.query);
  if (!result.success) {
    sendError(res, 400, 'Invalid query params', result.error.flatten());
    return null;
  }
  return result.data;
}
