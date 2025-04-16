import { useState, useRef } from "react";
import "./Scan.css";
import Quagga from "quagga";
import { db, auth } from "./firebase";
import { query, where, getDocs } from "firebase/firestore";
import { collection, doc, setDoc, Timestamp } from "firebase/firestore";
import { useAuthState } from "react-firebase-hooks/auth";

const Scan = () => {
    const [barcode, setBarcode] = useState("");
    const [error, setError] = useState("");
    const [isCameraActive, setIsCameraActive] = useState(false);
    const scannerRef = useRef(null);
    const hasAlertedRef = useRef(false);
    const [user] = useAuthState(auth);

    const categoryReminderMap = {
        "Dairy": 10,
        "Vegetables": 5,
        "Frozen": 30,
        "Beverage": 183,
        "Meat": 4,
        "Other": 7
    };

    const predefinedCategories = Object.keys(categoryReminderMap);

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

        try {
            const response = await fetch(`https://world.openfoodfacts.org/api/v0/product/${barcode}.json`);
            const data = await response.json();

            if (data.status !== 1) {
                alert("Product not found in Open Food Facts database.");
                console.warn("Product not found:", barcode);
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
        }
    };

    // Save product data to Firestore under the logged-in user's inventory
    const saveProductToInventory = async (barcode, productData) => {
        if (!user) {
            console.error("No authenticated user. Cannot write to Firestore.");
            return;
        }

        try {
            // const itemId = productData.id || doc(collection(db, `users/${user.uid}/inventory`)).id;

            // const userInventoryRef = doc(db, `users/${user.uid}/inventory/${itemId}`);
            // console.log("Saving product to Firestore at:", `users/${user.uid}/inventory/${itemId}`);
            // console.log("Product data being saved:", productData);

            // await setDoc(userInventoryRef, productData);
            // alert("Product saved to inventory!");

            const inventoriesRef = collection(db, "inventories");
            const q = query(inventoriesRef, where("membersArray", "array-contains", user.uid));
            const querySnapshot = await getDocs(q);
    
            let personalInventoryDoc = null;
    
            // Check for an inventory named "Personal Inventory"
            querySnapshot.forEach((docSnap) => {
                const data = docSnap.data();
                if (data.name === "Personal Inventory") {
                    personalInventoryDoc = docSnap;
                }
            });
    
            let inventoryId;
            if (personalInventoryDoc) {
                inventoryId = personalInventoryDoc.id;
                console.log("Using existing 'Personal Inventory':", inventoryId);
            } else {
                // Create a new personal inventory
                const newDocRef = doc(inventoriesRef);
                inventoryId = newDocRef.id;
    
                const newInventory = {
                    name: "Personal Inventory",
                    createdAt: new Date(),
                    members: { [user.uid]: "owner" },
                    membersArray: [user.uid],
                    owner: user.uid
                };
    
                await setDoc(newDocRef, newInventory);
                console.log("Created new 'Personal Inventory':", inventoryId);
            }
    
            // // Save item into the selected inventory
            // const itemId = doc(collection(db, `inventories/${inventoryId}/items`)).id;
            // const inventoryItemRef = doc(db, `inventories/${inventoryId}/items/${itemId}`);
            // await setDoc(inventoryItemRef, productData);
    
            // alert("Product saved to your Personal Inventory!");
            // Add item to the inventory’s items subcollection
            const itemId = doc(collection(db, `inventories/${inventoryId}/items`)).id;
            const localDate = new Date(productData.reminderDate);

            const newItemData = {
                ...productData,
                reminderDate: Timestamp.fromDate(localDate),
                lastUpdated: new Date(),
                quantity: productData.quantity > 0 ? productData.quantity : 1
            };

            const itemRef = doc(db, `inventories/${inventoryId}/items`, itemId);
            await setDoc(itemRef, newItemData);

            
        } catch (error) {
            console.error("Error saving product:", error);
            alert("Failed to save product. Check Firestore rules and console for details.");
        }
    };

    return (
        <div className="scan-container">
            <h1>Barcode Scanner</h1>
            <h2>Approach A: Scan Receipts or Barcodes with Webcam</h2>
            <p>Scan your grocery receipt or barcode to auto-populate your inventory.</p>

            <button onClick={startWebcamScanner} disabled={isCameraActive}>
                {isCameraActive ? "Scanning..." : "Scan with Webcam"}
            </button>

            <div ref={scannerRef} id="interactive" className="viewport"></div>

            {isCameraActive && <button onClick={stopWebcamScanner}>Stop Scanning</button>}

            {barcode && <p className="barcode-result">Detected Barcode: {barcode}</p>}
            {error && <p className="error">{error}</p>}
        </div>
    );
};

export default Scan;
