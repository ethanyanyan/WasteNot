import React, { useEffect, useState } from "react";
import { db, auth } from "./firebase";
import { collection, getDocs } from "firebase/firestore";
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

  return (
    <div className="inventory">
      <h2>Fridge Inventory</h2>
      <div className="inventory-list">
        {inventoryItems.length > 0 ? (
          inventoryItems.map((item) => (
            <div key={item.id} className="inventory-item">
              <span>{item.title} {item.imageURL && <img src={item.imageURL} alt={item.title} width="50" />}</span>
              <span>Expires: {item.reminderDate ? new Date(item.reminderDate.seconds * 1000).toLocaleDateString() : "Unknown"}</span>
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
