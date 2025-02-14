import { useState } from "react";
import "./Sensor.css";

const Sensor = () => {
    const [sensorData, setSensorData] = useState([
        { id: 1, name: "Milk", status: "No movement for 6 days" },
        { id: 2, name: "Cheese", status: "No movement for 3 days" },
        { id: 3, name: "Lettuce", status: "No movement for 5 days" }
    ]);

    const handleSensorUpdate = () => {
        alert("Simulating sensor update...");
        // You can modify sensorData here if needed
    };

    return (
        <div className="sensor-container">
            <h1>Sensor</h1>
            <h2>Approach B: IoT Sensor Monitoring</h2>
            <p>Simulated sensor output monitoring your fridge activity.</p>
            <button className="sensor-button" onClick={handleSensorUpdate}>Simulate Sensor Update</button>
            <div className="sensor-list">
                {sensorData.map(item => (
                    <div key={item.id} className="sensor-item">
                        {item.name}: {item.status}
                    </div>
                ))}
            </div>
        </div>
    );
};

export default Sensor;
