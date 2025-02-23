// src/routes/user.ts
import { Router } from "express";
import * as userController from "../controllers/userController";
import { cognitoAuth } from "../middleware/cognitoAuth";

const router = Router();

// Protected user profile endpoints:
router.get("/profile", cognitoAuth, userController.getProfile);
router.put("/profile", cognitoAuth, userController.updateProfile);

export default router;
