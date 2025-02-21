// src/controllers/inventoryController.ts
import { Request, Response } from "express";
import * as inventoryModel from "../models/inventoryModel";

export const createItem = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const item = req.body; // Expected to have at least an "id" field
    await inventoryModel.createItem(item);
    res.status(201).json({ message: "Item created successfully", item });
  } catch (error) {
    console.error("Error creating item:", error);
    res.status(500).json({ error: "Could not create item" });
  }
};

export const getAllItems = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const items = await inventoryModel.getAllItems();
    res.status(200).json({ items });
  } catch (error) {
    console.error("Error fetching items:", error);
    res.status(500).json({ error: "Could not fetch items" });
  }
};

export const getItemById = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const item = await inventoryModel.getItemById(id);
    if (item) {
      res.status(200).json({ item });
    } else {
      res.status(404).json({ error: "Item not found" });
    }
  } catch (error) {
    console.error("Error fetching item:", error);
    res.status(500).json({ error: "Could not fetch item" });
  }
};

export const updateItem = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const updates = req.body;
    await inventoryModel.updateItem(id, updates);
    res.status(200).json({ message: "Item updated successfully" });
  } catch (error) {
    console.error("Error updating item:", error);
    res.status(500).json({ error: "Could not update item" });
  }
};

export const deleteItem = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    await inventoryModel.deleteItem(id);
    res.status(200).json({ message: "Item deleted successfully" });
  } catch (error) {
    console.error("Error deleting item:", error);
    res.status(500).json({ error: "Could not delete item" });
  }
};
