
import { useState, useRef, useEffect } from "react";
import "./Scan.css";
import Quagga from "quagga";
import { db, auth } from "./firebase";
import { query, where, getDocs } from "firebase/firestore";
import { collection, doc, setDoc, Timestamp } from "firebase/firestore";
import { useAuthState } from "react-firebase-hooks/auth";
import { useNavigate } from "react-router-dom";

const Scan = () => {
    const [barcode, setBarcode] = useState("");
    const [error, setError] = useState("");
    const [isCameraActive, setIsCameraActive] = useState(false);
    const [userInventories, setUserInventories] = useState([]);
    const [inventoryNameMap, setInventoryNameMap] = useState({});
    const [selectedInventoryId, setSelectedInventoryId] = useState(null);
    const [isProcessing, setIsProcessing] = useState(false);
    const [scanSuccess, setScanSuccess] = useState(false);
    const scannerRef = useRef(null);
    const hasAlertedRef = useRef(false);
    const [user] = useAuthState(auth);
    const navigate = useNavigate();

    const categoryReminderMap = {
        "Dairy": 10,
        "Vegetables": 5,
        "Frozen": 30,
        "Beverage": 183,
        "Meat": 4,
        "Other": 7
    };

    const predefinedCategories = Object.keys(categoryReminderMap);

    useEffect(() => {
        if (user) {
            fetchInventories();
        }
    }, [user]);

    const fetchInventories = async () => {
        if (user) {
            try {
                console.log("Fetching inventories for user:", user.uid);
                
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

                // Default to display "Personal Inventory"
                const personal = inventories.find(inv => nameMap[inv.id] === "Personal Inventory");
                setSelectedInventoryId(personal?.id || inventories[0]?.id || null);
                
            } catch (error) {
                console.error("Error fetching inventories:", error);
                setError("Failed to load your inventories. Please try again later.");
            }
        }
    };

    const fuzzyMatchCategory = (inputCategory) => {
        if (!inputCategory) return "Other";

        const lowerInput = inputCategory.toLowerCase();
        for (const category of predefinedCategories) {
            if (lowerInput.includes(category.toLowerCase())) {
                return category;
            }
        }
        return "Other";
    };

    // Function to start the webcam scanner
    const startWebcamScanner = () => {
        if (!scannerRef.current) {
            setError("Camera view not found. Please refresh the page.");
            console.error("Camera view not found.");
            return;
        }

        // Prevent stopping if Quagga hasn't started yet
        if (Quagga._scanner) {
            console.log("Stopping previous Quagga instance...");
            Quagga.stop();
            Quagga.offDetected();
        }

        setIsCameraActive(true);
        setScanSuccess(false);
        console.log("Initializing Quagga...");
        hasAlertedRef.current = false;

        Quagga.init(
            {
                inputStream: {
                    name: "Live",
                    type: "LiveStream",
                    target: scannerRef.current,
                    constraints: {
                        width: 640,
                        height: 480,
                        facingMode: "user",
                    },
                },
                decoder: {
                    readers: [
                        "ean_reader",
                        "code_128_reader",
                        "upc_reader",
                        "upc_e_reader",
                        "code_39_reader",
                        "code_93_reader",
                    ],
                },
                locate: true,
            },
            function (err) {
                if (err) {
                    console.error("Error initializing webcam scanner:", err);
                    setError("Failed to start the scanner. Check camera permissions.");
                    setIsCameraActive(false);
                    return;
                }
                console.log("Quagga webcam initialized successfully.");
                Quagga.start();
            }
        );

        Quagga.onDetected((data) => {
            if (hasAlertedRef.current) return;
            hasAlertedRef.current = true;

            const detectedBarcode = data.codeResult.code;
            console.log("Detected Barcode:", detectedBarcode);
            setBarcode(detectedBarcode);
            setError("");

            stopWebcamScanner();
            fetchProductInfo(detectedBarcode);
        });
    };

    // Function to stop the webcam scanner
    const stopWebcamScanner = () => {
        Quagga.offDetected();
        Quagga.stop();
        setIsCameraActive(false);
    };

    // Fetch product info from Open Food Facts API
    const fetchProductInfo = async (barcode) => {
        if (!user) {
            console.error("No authenticated user. Cannot save product.");
            alert("You must be logged in to save items.");
            return;
        }

        setIsProcessing(true);

        try {
            const response = await fetch(`https://world.openfoodfacts.org/api/v0/product/${barcode}.json`);
            const data = await response.json();

            if (data.status !== 1) {
                alert("Product not found in Open Food Facts database.");
                console.warn("Product not found:", barcode);
                setIsProcessing(false);
                return;
            }

            const product = data.product;
            const matchedCategory = fuzzyMatchCategory(product.categories);
            const reminderDays = categoryReminderMap[matchedCategory] || 7;
            const expirationDate = new Date();
            expirationDate.setDate(expirationDate.getDate() + reminderDays);
            const localExpirationDate = new Date(expirationDate.getTime() - expirationDate.getTimezoneOffset() * 60000);

            const productData = {
                barcode: barcode,
                brand: product.brands || "Unknown",
                category: matchedCategory,
                imageURL: product.image_url || "",
                ingredients: product.ingredients_text || "No ingredient data available.",
                itemName: product.product_name || "Unnamed Product",
                lastUpdated: new Date(),
                nutritionFacts: product.nutriments
                    ? `Energy ${product.nutriments.energy_kcal || "N/A"} kcal, Fat ${product.nutriments.fat || "N/A"} g, Carbs ${product.nutriments.carbohydrates || "N/A"} g, Sugars ${product.nutriments.sugars || "N/A"} g, Fiber ${product.nutriments.fiber || "N/A"} g, Protein ${product.nutriments.proteins || "N/A"} g, Salt ${product.nutriments.salt || "N/A"} g`
                    : "No nutrition data available.",
                productDescription: product.generic_name || "No description available.",
                quantity: 1,
                reminderDate: isNaN(expirationDate.getTime()) ? null : Timestamp.fromDate(localExpirationDate),
                title: product.product_name || "Unnamed Product",
            };

            console.log("Fetched product data:", productData);
            await saveProductToInventory(barcode, productData);
        } catch (error) {
            console.error("Error fetching product data:", error);
            alert("Failed to retrieve product details. Check network connection.");
            setIsProcessing(false);
        }
    };

    // Save product data to Firestore under the selected inventory
    const saveProductToInventory = async (barcode, productData) => {
        if (!user) {
            console.error("No authenticated user. Cannot write to Firestore.");
            setIsProcessing(false);
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
            const itemRef = doc(db, `inventories/${inventoryId}/items`, itemId);
            await setDoc(itemRef, productData);
        
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
                            { id: itemId, ...productData, inventoryId }
                        ]
                    };
                } else {
                    // If this is a newly created inventory, add it to the list
                    updatedInventories.push({
                        id: inventoryId,
                        items: [{ id: itemId, ...productData, inventoryId }]
                    });
                    
                    // Update the name map if it's a new inventory
                    setInventoryNameMap(prev => ({
                        ...prev,
                        [inventoryId]: "Personal Inventory" // Use the actual name if available
                    }));
                }
                
                return updatedInventories;
            });
        
            // Show inventory name in the alert
            const inventoryName = inventoryNameMap[inventoryId] || "selected inventory";
            alert(`Item added to your ${inventoryName}!`);
            setScanSuccess(true);
            setIsProcessing(false);
        
        } catch (error) {
            console.error("Error saving product:", error);
            alert("Failed to save product. Check Firestore rules and console for details.");
            setIsProcessing(false);
        }
    };

    const goToInventory = () => {
        navigate('/inventory');
    };

    return (
        <div className="scan-container">
            <h1>Barcode Scanner</h1>
            <p>Scan your product barcode to add it to your inventory.</p>

            {userInventories.length > 0 && (
                <div className="inventory-selector">
                    <label htmlFor="inventory-dropdown">Select Inventory to Add Items:</label>
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
            )}

            {!scanSuccess ? (
                <>
                    <button 
                        onClick={startWebcamScanner} 
                        disabled={isCameraActive || isProcessing}
                        className={`scan-button ${isCameraActive || isProcessing ? 'disabled' : ''}`}
                    >
                        {isCameraActive ? "Scanning..." : isProcessing ? "Processing..." : "Start Scanning"}
                    </button>

                    <div ref={scannerRef} id="interactive" className="viewport"></div>

                    {isCameraActive && <button onClick={stopWebcamScanner}>Stop Scanning</button>}

                    {barcode && <p className="barcode-result">Detected Barcode: {barcode}</p>}
                    {error && <p className="error">{error}</p>}
                </>
            ) : (
                <div className="scan-success">
                    <h3>Product Successfully Added!</h3>
                    <p>Your item was added to {inventoryNameMap[selectedInventoryId] || "your inventory"}.</p>
                    <div className="scan-actions">
                        <button onClick={() => {
                            setBarcode("");
                            setScanSuccess(false);
                        }}>
                            Scan Another Item
                        </button>
                        <button onClick={goToInventory}>
                            View Inventory
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Scan;