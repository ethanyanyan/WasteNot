import React from "react";

const Inventory = () => {
  return (
    <div className="inventory">
      <h2>Fridge Inventory</h2>
      
      {/* Placeholder list */}
      <div className="inventory-list">
        <div className="inventory-item">
          <span>🥛 Milk </span>
          <span>Expires: 2025-02-20</span>
        </div>
        <div className="inventory-item">
          <span>🍎 Apples </span>
          <span>Expires: 2025-02-18</span>
        </div>
        <div className="inventory-item">
          <span>🥚 Eggs </span>
          <span>Expires: 2025-02-25</span>
        </div>
      </div>

      {/* Placeholder buttons */}
      <div className="inventory-actions">
        <button className="add-btn">+ Add Item</button>
        <button className="remove-btn">- Remove Item</button>
      </div>
    </div>
  );
};

export default Inventory;
