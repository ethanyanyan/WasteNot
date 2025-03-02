import React, { useEffect, useState } from "react";
import { db, auth } from "./firebase";
import { collection, getDocs, doc, updateDoc, deleteDoc, setDoc, Timestamp } from "firebase/firestore";
import { useAuthState } from "react-firebase-hooks/auth";
import "./Inventory.css";

const Inventory = () => {
  const [inventoryItems, setInventoryItems] = useState([]);
  const [user] = useAuthState(auth);
  const categoryReminderMap = {
    Dairy: 7,
    Vegetables: 5,
    Frozen: 30,
    Bakery: 3,
    Meat: 4,
    Other: 7
  };

  const [newItem, setNewItem] = useState({
    category: "Other",
    itemName: "",
    lastUpdated: new Date(),
    productDescription: "",
    quantity: 1,
    reminderDate: new Date().toISOString().split('T')[0], // Default to today's date
    barcode: "",
    imageURL: "",
    ingredients: "",
    nutritionFacts: "",
    title: ""
  });

  useEffect(() => {
    const fetchInventory = async () => {
      if (user) {
        try {
          const inventoryRef = collection(db, `users/${user.uid}/inventory`);
          const inventorySnapshot = await getDocs(inventoryRef);
          const items = inventorySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
          setInventoryItems(items);
        } catch (error) {
          console.error("Error fetching inventory:", error);
        }
      }
    };

    fetchInventory();
  }, [user]);

  const updateQuantity = async (itemId, newQuantity) => {
    if (user && newQuantity >= 0) {
      try {
        const itemRef = doc(db, `users/${user.uid}/inventory`, itemId);
        await updateDoc(itemRef, { quantity: newQuantity });

        setInventoryItems(prevItems =>
          prevItems.map(item =>
            item.id === itemId ? { ...item, quantity: newQuantity } : item
          )
        );
      } catch (error) {
        console.error("Error updating quantity:", error);
      }
    }
  };

  const removeItem = async (itemId) => {
    if (user) {
      try {
        const itemRef = doc(db, `users/${user.uid}/inventory`, itemId);
        await deleteDoc(itemRef);

        setInventoryItems(prevItems => prevItems.filter(item => item.id !== itemId));
      } catch (error) {
        console.error("Error removing item:", error);
      }
    }
  };

  const handleCategoryChange = (e) => {
    const selectedCategory = e.target.value;
    setNewItem(prevState => ({
      ...prevState,
      category: selectedCategory
    }));
  };

  const handleAddItem = async () => {
    if (user) {
        if (!newItem.itemName.trim() || !newItem.productDescription.trim() || !newItem.reminderDate) {
            alert("Please fill out all required fields: Item Name, Product Description, and Reminder Date.");
            return;
        }

        try {
            const itemId = doc(collection(db, `users/${user.uid}/inventory`)).id;

            // Preserve the user-selected date, and avoid timezone shifts by setting time to noon
            const reminderDate = new Date(newItem.reminderDate);
            reminderDate.setHours(12, 0, 0, 0);

            const newItemData = {
                ...newItem,
                reminderDate: Timestamp.fromDate(reminderDate), // Store the correct user-selected date
                lastUpdated: new Date(),
                quantity: newItem.quantity > 0 ? newItem.quantity : 1
            };

            const itemRef = doc(db, `users/${user.uid}/inventory`, itemId);
            await setDoc(itemRef, newItemData);

            setInventoryItems([...inventoryItems, { id: itemId, ...newItemData }]);

            setNewItem({
                category: "Other",
                itemName: "",
                lastUpdated: new Date(),
                productDescription: "",
                quantity: 1,
                reminderDate: new Date().toISOString().split('T')[0], // Reset correctly
                barcode: "",
                imageURL: "",
                ingredients: "",
                nutritionFacts: "",
                title: ""
            });

        } catch (error) {
            console.error("Error adding item:", error);
            alert("Failed to add item. Please try again.");
        }
    }
  };

  return (
    <div className="inventory">
      <h1>Fridge Inventory</h1>
      <div className="inventory-list">
        {inventoryItems.length > 0 ? (
          inventoryItems.map((item) => (
            <div key={item.id} className="inventory-item">
              <span>{item.itemName} {item.imageURL && <img src={item.imageURL} alt={item.itemName} width="50" />}</span>
              <span>
              Expires: {item.reminderDate ? 
                  (item.reminderDate.toDate ? 
                   new Date(item.reminderDate.toDate().getTime() + new Date().getTimezoneOffset() * 60000).toLocaleDateString() 
                   : new Date(item.reminderDate).toLocaleDateString()) 
                  : "Unknown"}
              </span>
              <div className="quantity-controls">
                <button onClick={() => updateQuantity(item.id, item.quantity - 1)}>-</button>
                <span>{item.quantity}</span>
                <button onClick={() => updateQuantity(item.id, item.quantity + 1)}>+</button>
              </div>
              <button className="remove-button" onClick={() => removeItem(item.id)}>Remove</button>
            </div>
          ))
        ) : (
          <p>No items in inventory.</p>
        )}
      </div>
      
      <div className="add-item">
        <h3>Add New Item</h3>

        <input
          type="text"
          placeholder="Item Name"
          value={newItem.itemName}
          onChange={(e) => setNewItem({ ...newItem, itemName: e.target.value })}
        />

        <input
          type="text"
          placeholder="Product Description"
          value={newItem.productDescription}
          onChange={(e) => setNewItem({ ...newItem, productDescription: e.target.value })}
        />

        <input
          type="number"
          placeholder="Quantity"
          min="1"
          value={newItem.quantity}
          onChange={(e) => setNewItem({ ...newItem, quantity: parseInt(e.target.value) || 1 })}
        />

        <input
          type="date"
          value={newItem.reminderDate}
          onChange={(e) => setNewItem({ ...newItem, reminderDate: e.target.value })}
        />

        <select
          value={newItem.category}
          onChange={handleCategoryChange}
        >
          {Object.keys(categoryReminderMap).map(category => (
            <option key={category} value={category}>{category}</option>
          ))}
        </select>

        <button onClick={handleAddItem}>Add Item</button>
      </div>
    </div>
  );
};

export default Inventory;
