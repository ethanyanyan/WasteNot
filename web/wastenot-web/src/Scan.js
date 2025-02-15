import { useState } from "react";
import "./Scan.css";

const Scan = () => {
    const [lastScan, setLastScan] = useState("Last scan on 2025-02-20: Milk, Eggs, Bread added.");

    const handleScan = () => {
        // Simulate scanning action
        alert("Simulating receipt upload...");
    };

    return ( 
        <div className="scan-container">
            <h1>Receipt/Barcode</h1>
            <h2>Approach A: Upload Receipts or Barcodes</h2>
            <p>Upload your grocery receipt or barcode to auto-populate your inventory.</p>
            <button className="upload-button" onClick={handleScan}>Upload Receipt</button>
            <p className="last-scan">{lastScan}</p>
        </div>
     );
}
 
export default Scan;