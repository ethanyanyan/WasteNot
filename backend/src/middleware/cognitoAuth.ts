// src/middleware/cognitoAuth.ts
import { Request, Response, NextFunction } from "express";

export interface CognitoAuthRequest extends Request {
  userId?: string;
}

export const cognitoAuth = (
  req: CognitoAuthRequest,
  res: Response,
  next: NextFunction
) => {
  // With Lambda proxy integration, the authorizer claims are available in req.requestContext.authorizer.claims
  const claims = (req as any).requestContext?.authorizer?.claims;
  if (claims && claims.sub) {
    req.userId = claims.sub; // 'sub' is the Cognito unique user id
    next();
  } else {
    res.status(401).json({ error: "Unauthorized" });
  }
};
