// src/app.ts
import express, { Request, Response } from "express";
import bodyParser from "body-parser";
import dotenv from "dotenv";
import inventoryRoutes from "./routes/inventory";
import userRoutes from "./routes/user";

dotenv.config();

const app = express();
app.use(bodyParser.json());

// Register  routes
app.use("/inventory", inventoryRoutes);
app.use("/user", userRoutes);

// Health-check route (optional)
app.get("/", (req: Request, res: Response) => {
  res.json({ message: "WasteNot backend is up!" });
});

export default app;
