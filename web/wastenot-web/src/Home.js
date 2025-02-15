import "./Home.css";

const Home = () => {
    return ( 
        <div className="home">
            <h2>Homepage</h2>
            <a href="/scan">Barcode/Receipt Scanning Mobile App (Approach A)</a>
            <a href="/sensor">Smart Fridge Sensor (Approach B)</a>
            <a href="/communitySwap">Community Swap / Donation Platform (Approach C)</a>
        </div>
     );
}
 
export default Home;