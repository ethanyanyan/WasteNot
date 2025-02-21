// src/routes/inventory.ts
import { Router } from "express";
import * as inventoryController from "../controllers/inventoryController";

const router = Router();

// Create a new inventory item
router.post("/", inventoryController.createItem);

// Get all inventory items
router.get("/", inventoryController.getAllItems);

// Get a single inventory item by id
router.get("/:id", inventoryController.getItemById);

// Update an inventory item by id
router.put("/:id", inventoryController.updateItem);

// Delete an inventory item by id
router.delete("/:id", inventoryController.deleteItem);

export default router;
