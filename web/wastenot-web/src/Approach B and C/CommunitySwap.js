import { useState } from "react";
import "./CommunitySwap.css";

const CommunitySwap = () => {
    const [swapItems, setSwapItems] = useState([
        { id: 1, name: "John's Apples", expiration: "2025-02-12", image: "🍎" },
        { id: 2, name: "Sarah's Bread", expiration: "2025-02-14", image: "🍞" },
        { id: 3, name: "Mike's Carrots", expiration: "2025-02-16", image: "🥕" }
    ]);

    const handleAddListing = () => {
        alert("Simulating 'Add New Listing'...");
    };

    return (
        <div className="community-swap-container">
            <h1>Community Swap</h1>
            <p>List surplus food items and find neighbors to swap with.</p>
            <div className="swap-list">
                {swapItems.map(item => (
                    <div key={item.id} className="swap-item">
                        <span className="swap-icon">{item.image}</span>
                        <div className="swap-details">
                            <strong>{item.name}</strong>
                            <p>Expires: {item.expiration}</p>
                        </div>
                        <button className="contact-button">Contact</button>
                    </div>
                ))}
            </div>
            <button className="add-listing" onClick={handleAddListing}>Add New Listing</button>
        </div>
    );
};

export default CommunitySwap;
