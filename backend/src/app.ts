// src/app.ts
import express, { Request, Response } from "express";
import bodyParser from "body-parser";
import dotenv from "dotenv";
import inventoryRoutes from "./routes/inventory";

dotenv.config();

const app = express();
app.use(bodyParser.json());

// Register inventory CRUD routes
app.use("/inventory", inventoryRoutes);

// Health-check route (optional)
app.get("/", (req: Request, res: Response) => {
  res.json({ message: "WasteNot backend is up!" });
});

export default app;
