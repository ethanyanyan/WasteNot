// src/controllers/userController.ts
import { Request, Response } from "express";
import * as userModel from "../models/userModel";

// Get user profile using the Cognito user id extracted by middleware
export const getProfile = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = (req as any).userId;
    if (!userId) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }
    const user = await userModel.getUserById(userId);
    if (!user) {
      res.status(404).json({ error: "User not found" });
      return;
    }
    res.status(200).json({ profile: user });
  } catch (error: any) {
    console.error("Error fetching profile:", error);
    res
      .status(500)
      .json({ error: "Could not fetch profile", details: error.message });
  }
};

// Update user profile (e.g., update name or other extra info)
export const updateProfile = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = (req as any).userId;
    if (!userId) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }
    const updates = req.body;
    await userModel.updateUser(userId, updates);
    res.status(200).json({ message: "Profile updated successfully" });
  } catch (error: any) {
    console.error("Error updating profile:", error);
    res
      .status(500)
      .json({ error: "Could not update profile", details: error.message });
  }
};
