import React, { useEffect, useState } from "react";
import { db, auth } from "./firebase";
import { collection, getDocs, doc, updateDoc, deleteDoc, setDoc, Timestamp, query, where } from "firebase/firestore";
import { useAuthState } from "react-firebase-hooks/auth";
import "./Inventory.css";

const Inventory = () => {
  // const [inventoryItems, setInventoryItems] = useState([]);
  const [user] = useAuthState(auth);
  const [editItem, setEditItem] = useState(null);
  const [editedDate, setEditedDate] = useState("");
  const [userInventories, setUserInventories] = useState([]);
  const [selectedInventoryId, setSelectedInventoryId] = useState(null);
  const [inventoryNameMap, setInventoryNameMap] = useState({});

  
  const categoryReminderMap = {
    Dairy: 10,
    Vegetables: 5,
    Frozen: 30,
    beverage: 183,
    Meat: 4,
    Other: 7
  };

  const [newItem, setNewItem] = useState(() => {
    const defaultReminderDate = new Date();
    defaultReminderDate.setDate(defaultReminderDate.getDate() + 7); // Add 7 days from today

    return {
        category: "Other",
        itemName: "",
        lastUpdated: new Date(),
        productDescription: "",
        quantity: 1,
        reminderDate: defaultReminderDate.toISOString().split('T')[0], // Set to 7 days from now
        barcode: "",
        imageURL: "",
        ingredients: "",
        nutritionFacts: "",
        title: ""
    };
  });

  useEffect(() => {
    if (user) {
      fetchInventories();
    }
    
  }, [user]);

  const fetchInventories = async () => {
    if (user) {
      try {
        console.log("User ID:", user.uid);
        

        const inventoriesRef = collection(db, "inventories");
        const q = query(inventoriesRef, where("membersArray", "array-contains", user.uid));
        const snapshot = await getDocs(q);

        const inventories = [];
        const nameMap = {};

        for (const docSnap of snapshot.docs) {
          const inventoryId = docSnap.id;
          const data = docSnap.data();
          nameMap[inventoryId] = data.name;

          const itemsRef = collection(db, `inventories/${inventoryId}/items`);

          const itemSnapshot = await getDocs(itemsRef);
          const items = itemSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            inventoryId
          }));

          inventories.push({id: inventoryId, items});
        }
        setUserInventories(inventories);
        setInventoryNameMap(nameMap);

        //Default to display "Personal Inventory"

        const personal = inventories.find(inv => nameMap[inv.id] === "Personal Inventory");
        setSelectedInventoryId(personal?.id || inventories[0]?.id || null);

        
      } catch (error) {
        console.error("Error fetching inventory:", error);
      }
    }
  };

  

  const updateReminderDate = async (itemId) => {
    // if (user && editedDate) {
    //     try {
    //         const itemRef = doc(db, `users/${user.uid}/inventory`, itemId);
    //         const newTimestamp = Timestamp.fromDate(new Date(editedDate));

    //         await updateDoc(itemRef, { reminderDate: newTimestamp });

    //         setInventoryItems(prevItems =>
    //             prevItems.map(item =>
    //                 item.id === itemId ? { ...item, reminderDate: newTimestamp } : item
    //             )
    //         );

    //         setEditItem(null);
    //         setEditedDate("");
    //     } catch (error) {
    //         console.error("Error updating reminder date:", error);
    //     }
    // }
    if (user && editedDate && selectedInventoryId) {
      try {
        const itemRef = doc(db, `inventories/${selectedInventoryId}/items`, itemId);
        const newTimestamp = Timestamp.fromDate(new Date(editedDate));
  
        await updateDoc(itemRef, { reminderDate: newTimestamp });
  
        setUserInventories(prev =>
          prev.map(inv =>
            inv.id === selectedInventoryId
              ? {
                  ...inv,
                  items: inv.items.map(item =>
                    item.id === itemId ? { ...item, reminderDate: newTimestamp } : item
                  )
                }
              : inv
          )
        );
  
        setEditItem(null);
        setEditedDate("");
      } catch (error) {
        console.error("Error updating reminder date:", error);
      }
    }
  };


  const updateQuantity = async (itemId, newQuantity) => {
    // if (user && newQuantity >= 0) {
    //   try {
    //     const itemRef = doc(db, `users/${user.uid}/inventory`, itemId);
    //     await updateDoc(itemRef, { quantity: newQuantity });

    //     setInventoryItems(prevItems =>
    //       prevItems.map(item =>
    //         item.id === itemId ? { ...item, quantity: newQuantity } : item
    //       )
    //     );
    //   } catch (error) {
    //     console.error("Error updating quantity:", error);
    //   }
    // }

    if (user && selectedInventoryId && newQuantity >= 0) {
      try {
        const itemRef = doc(db, `inventories/${selectedInventoryId}/items`, itemId);
        await updateDoc(itemRef, { quantity: newQuantity });
  
        setUserInventories(prev =>
          prev.map(inv =>
            inv.id === selectedInventoryId
              ? {
                  ...inv,
                  items: inv.items.map(item =>
                    item.id === itemId ? { ...item, quantity: newQuantity } : item
                  )
                }
              : inv
          )
        );
      } catch (error) {
        console.error("Error updating quantity:", error);
      }
    }
  };

  const removeItem = async (itemId) => {
    // if (user) {
    //   try {
    //     const itemRef = doc(db, `users/${user.uid}/inventory`, itemId);
    //     await deleteDoc(itemRef);

    //     setInventoryItems(prevItems => prevItems.filter(item => item.id !== itemId));
    //   } catch (error) {
    //     console.error("Error removing item:", error);
    //   }
    // }

    if (user && selectedInventoryId) {
      try {
        const itemRef = doc(db, `inventories/${selectedInventoryId}/items`, itemId);
        await deleteDoc(itemRef);
  
        setUserInventories(prev =>
          prev.map(inv =>
            inv.id === selectedInventoryId
              ? {
                  ...inv,
                  items: inv.items.filter(item => item.id !== itemId)
                }
              : inv
          )
        );
      } catch (error) {
        console.error("Error removing item:", error);
      }
    }
  };

  const handleCategoryChange = (e) => {
    const selectedCategory = e.target.value;
    const daysToExpire = categoryReminderMap[selectedCategory] || 7; // Default to 7 days if not found
    const newReminderDate = new Date();
    newReminderDate.setDate(newReminderDate.getDate() + daysToExpire); // Add the category-based days

    setNewItem(prevState => ({
        ...prevState,
        category: selectedCategory,
        reminderDate: newReminderDate.toISOString().split('T')[0] // Format to YYYY-MM-DD
    }));
  };


  // const handleAddItem = async () => {
  //   if (user) {
  //       if (!newItem.itemName.trim() || !newItem.productDescription.trim() || !newItem.reminderDate) {
  //           alert("Please fill out all required fields: Item Name, Product Description, and Reminder Date.");
  //           return;
  //       }

  //       try {

  //           // Look for existing "Personal Inventory"
  //           const inventoriesRef = collection(db, "inventories");
  //           const q = query(inventoriesRef, where("membersArray", "array-contains", user.uid));
  //           const querySnapshot = await getDocs(q);

  //           let personalInventoryDoc = null;

  //           querySnapshot.forEach((docSnap) => {
  //               const data = docSnap.data();
  //               if (data.name === "Personal Inventory") {
  //                   personalInventoryDoc = docSnap;
  //               }
  //           });

  //           let inventoryId;
  //           if (personalInventoryDoc) {
  //               inventoryId = personalInventoryDoc.id;
  //               console.log("Using existing 'Personal Inventory':", inventoryId);
  //           } else {
  //               // Create new "Personal Inventory" if it doesn't already exist
  //               const newInventoryRef = doc(inventoriesRef);
  //               inventoryId = newInventoryRef.id;

  //               const newInventoryData = {
  //                   name: "Personal Inventory",
  //                   createdAt: new Date(),
  //                   members: { [user.uid]: "owner" },
  //                   membersArray: [user.uid],
  //                   owner: user.uid
  //               };

  //               await setDoc(newInventoryRef, newInventoryData);
  //               console.log("Created new 'Personal Inventory':", inventoryId);
  //           }

  //           // Add item to the inventory’s items subcollection
  //           const itemId = doc(collection(db, `inventories/${inventoryId}/items`)).id;
  //           const localDate = new Date(newItem.reminderDate);

  //           const newItemData = {
  //               ...newItem,
  //               reminderDate: Timestamp.fromDate(localDate),
  //               lastUpdated: new Date(),
  //               quantity: newItem.quantity > 0 ? newItem.quantity : 1
  //           };

  //           const itemRef = doc(db, `inventories/${inventoryId}/items`, itemId);
  //           await setDoc(itemRef, newItemData);

            
  //           setUserInventories(prev => {
  //             const updatedInventories = [...prev];
  //             const inventoryIndex = updatedInventories.findIndex(inv => inv.id === inventoryId);
              
  //             if (inventoryIndex >= 0) {
  //               // Add the new item to the existing inventory
  //               updatedInventories[inventoryIndex] = {
  //                 ...updatedInventories[inventoryIndex],
  //                 items: [
  //                   ...updatedInventories[inventoryIndex].items,
  //                   { id: itemId, ...newItemData, inventoryId }
  //                 ]
  //               };
  //             } else {
  //               // If this is a newly created inventory, add it to the list
  //               updatedInventories.push({
  //                 id: inventoryId,
  //                 items: [{ id: itemId, ...newItemData, inventoryId }]
  //               });
                
  //               // Update the name map
  //               setInventoryNameMap(prev => ({
  //                 ...prev,
  //                 [inventoryId]: "Personal Inventory"
  //               }));
                
  //               // If this is the first inventory, select it
  //               if (!selectedInventoryId) {
  //                 setSelectedInventoryId(inventoryId);
  //               }
  //             }
              
  //             return updatedInventories;
  //           });

  //           // Reset form state
  //           const defaultReminderDate = new Date();
  //           defaultReminderDate.setDate(defaultReminderDate.getDate() + 7);

  //           setNewItem({
  //               category: "Other",
  //               itemName: "",
  //               lastUpdated: new Date(),
  //               productDescription: "",
  //               quantity: 1,
  //               reminderDate: defaultReminderDate.toISOString().split('T')[0],
  //               barcode: "",
  //               imageURL: "",
  //               ingredients: "",
  //               nutritionFacts: "",
  //               title: ""
  //           });

  //           alert("Item added to your Personal Inventory!");

  //       } catch (error) {
  //           console.error("Error adding item:", error);
  //           alert("Failed to add item. Please try again.");
  //       }
  //   }
  // };
  

  const handleAddItem = async () => {
    if (user) {
      if (!newItem.itemName.trim() || !newItem.productDescription.trim() || !newItem.reminderDate) {
        alert("Please fill out all required fields: Item Name, Product Description, and Reminder Date.");
        return;
      }
  
      try {
        let inventoryId;
        
        // If there's a selected inventory, use that
        if (selectedInventoryId) {
          inventoryId = selectedInventoryId;
          console.log("Adding to selected inventory:", inventoryId);
        } else {
          // If no inventory is selected, look for Personal Inventory or create one
          const inventoriesRef = collection(db, "inventories");
          const q = query(inventoriesRef, where("membersArray", "array-contains", user.uid));
          const querySnapshot = await getDocs(q);
  
          let personalInventoryDoc = null;
  
          querySnapshot.forEach((docSnap) => {
            const data = docSnap.data();
            if (data.name === "Personal Inventory") {
              personalInventoryDoc = docSnap;
            }
          });
  
          if (personalInventoryDoc) {
            inventoryId = personalInventoryDoc.id;
            console.log("No inventory selected. Using 'Personal Inventory':", inventoryId);
          } else {
            // Create new "Personal Inventory" if it doesn't already exist
            const newInventoryRef = doc(inventoriesRef);
            inventoryId = newInventoryRef.id;
  
            const newInventoryData = {
              name: "Personal Inventory",
              createdAt: new Date(),
              members: { [user.uid]: "owner" },
              membersArray: [user.uid],
              owner: user.uid
            };
  
            await setDoc(newInventoryRef, newInventoryData);
            console.log("Created new 'Personal Inventory':", inventoryId);
          }
          
          // Also set it as the selected inventory
          setSelectedInventoryId(inventoryId);
        }
  
        // Add item to the selected inventory's items subcollection
        const itemId = doc(collection(db, `inventories/${inventoryId}/items`)).id;
        const localDate = new Date(newItem.reminderDate);
  
        const newItemData = {
          ...newItem,
          reminderDate: Timestamp.fromDate(localDate),
          lastUpdated: new Date(),
          quantity: newItem.quantity > 0 ? newItem.quantity : 1
        };
  
        const itemRef = doc(db, `inventories/${inventoryId}/items`, itemId);
        await setDoc(itemRef, newItemData);
  
        // Update the userInventories state
        setUserInventories(prev => {
          const updatedInventories = [...prev];
          const inventoryIndex = updatedInventories.findIndex(inv => inv.id === inventoryId);
          
          if (inventoryIndex >= 0) {
            // Add the new item to the existing inventory
            updatedInventories[inventoryIndex] = {
              ...updatedInventories[inventoryIndex],
              items: [
                ...updatedInventories[inventoryIndex].items,
                { id: itemId, ...newItemData, inventoryId }
              ]
            };
          } else {
            // If this is a newly created inventory, add it to the list
            updatedInventories.push({
              id: inventoryId,
              items: [{ id: itemId, ...newItemData, inventoryId }]
            });
            
            // Update the name map if it's a new inventory
            setInventoryNameMap(prev => ({
              ...prev,
              [inventoryId]: "Personal Inventory" // Use the actual name if available
            }));
          }
          
          return updatedInventories;
        });
  
        // Reset form state
        const defaultReminderDate = new Date();
        defaultReminderDate.setDate(defaultReminderDate.getDate() + 7);
  
        setNewItem({
          category: "Other",
          itemName: "",
          lastUpdated: new Date(),
          productDescription: "",
          quantity: 1,
          reminderDate: defaultReminderDate.toISOString().split('T')[0],
          barcode: "",
          imageURL: "",
          ingredients: "",
          nutritionFacts: "",
          title: ""
        });
  
        // Show inventory name in the alert
        const inventoryName = inventoryNameMap[inventoryId] || "selected inventory";
        alert(`Item added to your ${inventoryName}!`);
  
      } catch (error) {
        console.error("Error adding item:", error);
        alert("Failed to add item. Please try again.");
      }
    }
  };
  const displayedItems = userInventories.find(inv => inv.id === selectedInventoryId)?.items || [];

  return (
    <div className="inventory">
      <h1>Fridge Inventory</h1>
      <div className="inventory-selector">
        <label htmlFor="inventory-dropdown">Select Inventory:</label>
        <select
          id="inventory-dropdown"
          value={selectedInventoryId || ""}
          onChange={(e) => setSelectedInventoryId(e.target.value)}
        >
          {userInventories.map(inv => (
            <option key={inv.id} value={inv.id}>
              {inventoryNameMap[inv.id] || "Unnamed Inventory"}
            </option>
          ))}
        </select>
      </div>

      <div className="inventory-list">
        {displayedItems.length > 0 ? (
          displayedItems.map((item) => (
            <div key={item.id} className={`inventory-item ${item.shared ? "shared-item" : ""}`}>
              <span>
                {item.itemName} 
                {item.imageURL && <img src={item.imageURL} alt={item.itemName} width="50" />}
                {item.shared && "(Shared)"}
              </span>
              {/* <span>{item.itemName} {item.shared && "(Shared)"}</span> */}
              {/* <span>{item.itemName} {item.imageURL && <img src={item.imageURL} alt={item.itemName} width="50" />}</span> */}
              <span>
              Expires: {item.reminderDate ? 
                new Date(item.reminderDate.toDate().getTime() + new Date().getTimezoneOffset() * 60000).toLocaleDateString(undefined, {
                    year: "numeric", month: "2-digit", day: "2-digit"
                }) : "Unknown"}
              </span>
              {editItem === item.id ? (
                  <div>
                      <input
                          type="date"
                          value={editedDate}  // Use value instead of defaultValue
                          onChange={(e) => setEditedDate(e.target.value)} // Update editedDate correctly
                      />
                      <button onClick={() => updateReminderDate(item.id)}>Save</button>
                      <button onClick={() => setEditItem(null)}>Cancel</button>
                  </div>
              ) : (
                <button className="edit-date-btn" onClick={() => { 
                  setEditItem(item.id); 
                  setEditedDate(new Date(item.reminderDate.toDate().getTime()).toISOString().split('T')[0]); 
                }}>
                  Edit Date
                </button>
              )}
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

        <select
          value={newItem.category}
          onChange={handleCategoryChange}
        >
          {Object.keys(categoryReminderMap).map(category => (
            <option key={category} value={category}>{category}</option>
          ))}
        </select>

        <input
          type="date"
          value={newItem.reminderDate}
          onChange={(e) => setNewItem({ ...newItem, reminderDate: e.target.value })}
        />

        <button onClick={handleAddItem}>Add Item</button>
      </div>
    </div>
  );
};

export default Inventory;
