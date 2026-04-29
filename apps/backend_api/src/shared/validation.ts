import { ZodSchema } from 'zod';
import { Request, Response } from 'express';

export function readBody<T>(
  schema: ZodSchema<T>,
  req: Request,
  res: Response,
): T | null {
  const result = schema.safeParse(req.body);
  if (!result.success) {
    res.status(400).json({
      error: 'Invalid request body',
      details: result.error.flatten(),
    });
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
    res.status(400).json({
      error: 'Invalid route params',
      details: result.error.flatten(),
    });
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
    res.status(400).json({
      error: 'Invalid query params',
      details: result.error.flatten(),
    });
    return null;
  }
  return result.data;
}
