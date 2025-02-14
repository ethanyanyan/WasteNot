import { useState } from "react";
import "./Scan.css";

const Scan = () => {
    const [lastScan, setLastScan] = useState("Last scan on 2025-02-20: Milk, Eggs, Bread added.");

    const handleScan = () => {
        // Simulate scanning action
        alert("Simulating receipt scan...");
    };

    return ( 
        <div className="scan-container">
            <h1>Scan</h1>
            <h2>Approach A: Scan Receipts</h2>
            <p>Scan your grocery receipt to auto-populate your inventory.</p>
            <button className="scan-button" onClick={handleScan}>Scan Receipt</button>
            <p className="last-scan">{lastScan}</p>
        </div>
     );
}
 
export default Scan;