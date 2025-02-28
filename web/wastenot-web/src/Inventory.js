import React, { useEffect, useState } from "react";
import { db, auth } from "./firebase";
import { collection, getDocs, doc, updateDoc, deleteDoc } from "firebase/firestore";
import { useAuthState } from "react-firebase-hooks/auth";
import "./Inventory.css";

const Inventory = () => {
  const [inventoryItems, setInventoryItems] = useState([]);
  const [user] = useAuthState(auth);

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
            item.id === itemId ? { ...item, quantity: newQuantity } : item )
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

        // Remove from state
        setInventoryItems(prevItems => prevItems.filter(item => item.id !== itemId));
      } catch (error) {
        console.error("Error removing item:", error);
      }
    }
  };

  return (
    <div className="inventory">
      <h2>Fridge Inventory</h2>
      <div className="inventory-list">
        {inventoryItems.length > 0 ? (
          inventoryItems.map((item) => (
            <div key={item.id} className="inventory-item">
              <span>{item.title} {item.imageURL && <img src={item.imageURL} alt={item.title} width="50" />}</span>
              <span>Expires: {item.reminderDate ? new Date(item.reminderDate.seconds * 1000).toLocaleDateString() : "Unknown"}</span>
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
    </div>
  );
};

export default Inventory;
