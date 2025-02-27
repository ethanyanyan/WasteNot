import { useState, useRef } from "react";
import "./Scan.css";
import Quagga from "quagga";
import { db, auth } from "./firebase";
import { doc, setDoc } from "firebase/firestore";
import { useAuthState } from "react-firebase-hooks/auth";

const Scan = () => {
    const [barcode, setBarcode] = useState("");
    const [error, setError] = useState("");
    const [isCameraActive, setIsCameraActive] = useState(false);
    const scannerRef = useRef(null);
    const [user] = useAuthState(auth);

    // Function to start the webcam scanner
    const startWebcamScanner = () => {
        if (!scannerRef.current) {
            setError("Camera view not found. Please refresh the page.");
            return;
        }

        setIsCameraActive(true);

        Quagga.init(
            {
                inputStream: {
                    name: "Live",
                    type: "LiveStream",
                    target: scannerRef.current,
                    constraints: {
                        width: 640,
                        height: 480,
                        facingMode: "environment",
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
                console.log("Quagga webcam initialized.");
                Quagga.start();
            }
        );

        // Detect barcode
        Quagga.onDetected((data) => {
            const detectedBarcode = data.codeResult.code;
            console.log("Webcam Barcode Detected:", detectedBarcode);
            setBarcode(detectedBarcode);
            setError("");

            stopWebcamScanner(); // Stop scanner immediately to prevent duplicate scans
            fetchProductInfo(detectedBarcode); // Fetch and store product data
        });
    };

    // Function to stop the webcam scanner
    const stopWebcamScanner = () => {
        Quagga.stop();
        setIsCameraActive(false);
    };

    // Fetch product info from Open Food Facts API
    const fetchProductInfo = async (barcode) => {
        if (!user) {
            alert("You must be logged in to save items.");
            return;
        }

        try {
            const response = await fetch(`https://world.openfoodfacts.org/api/v0/product/${barcode}.json`);
            const data = await response.json();

            if (data.status === 1) {
                const product = data.product;

                const expirationDate = product.expiration_date ? new Date(product.expiration_date) : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

                const productData = {
                    barcode: barcode,
                    brand: product.brands || "Unknown",
                    category: product.categories || "Other",
                    imageURL: product.image_url || "",
                    ingredients: product.ingredients_text || "No ingredient data available.",
                    itemName: product.product_name || "Unnamed Product",
                    lastUpdated: new Date(),
                    nutritionFacts: product.nutriments
                        ? `Energy ${product.nutriments.energy_kcal || "N/A"} kcal, Fat ${product.nutriments.fat || "N/A"} g, Carbs ${product.nutriments.carbohydrates || "N/A"} g, Sugars ${product.nutriments.sugars || "N/A"} g, Fiber ${product.nutriments.fiber || "N/A"} g, Protein ${product.nutriments.proteins || "N/A"} g, Salt ${product.nutriments.salt || "N/A"} g`
                        : "No nutrition data available.",
                    productDescription: product.generic_name || "No description available.",
                    quantity: 1,
                    reminderDate: expirationDate, // Use expiration date if available
                    title: product.product_name || "Unnamed Product"
                };

                // Save product to Firestore under the logged-in user's inventory
                await saveProductToInventory(barcode, productData);
            } else {
                alert("Product not found in Open Food Facts database.");
            }
        } catch (error) {
            console.error("Error fetching product data:", error);
            alert("Failed to retrieve product details.");
        }
    };

    // Save product data to Firestore under the logged-in user's inventory
    const saveProductToInventory = async (barcode, productData) => {
        try {
            const userInventoryRef = doc(db, `users/${user.uid}/inventory/${barcode}`);
            await setDoc(userInventoryRef, productData);
            alert("Product saved to inventory!");
        } catch (error) {
            console.error("Error saving product:", error);
            alert("Failed to save product.");
        }
    };

    return (
        <div className="scan-container">
            <h1>Barcode Scanner</h1>
            <h2>Approach A: Scan Receipts or Barcodes with Webcam</h2>
            <p>Scan your grocery receipt or barcode to auto-populate your inventory.</p>

            {/* Webcam Barcode Scanner */}
            <button onClick={startWebcamScanner} disabled={isCameraActive}>
                {isCameraActive ? "Scanning..." : "Scan with Webcam"}
            </button>

            {/* Scanner View */}
            <div ref={scannerRef} id="interactive" className="viewport"></div>

            {isCameraActive && <button onClick={stopWebcamScanner}>Stop Scanning</button>}

            {/* Display detected barcode */}
            {barcode && <p className="barcode-result">Detected Barcode: {barcode}</p>}
            {error && <p className="error">{error}</p>}
        </div>
    );
};

export default Scan;
