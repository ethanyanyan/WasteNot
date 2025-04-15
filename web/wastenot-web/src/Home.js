import "./Home.css";
// import { Link } from "react-router-dom";
import Scan from "./Scan";

const Home = () => {
    return ( 
        <div className="home">
            <Scan/>
            {/* <h2>Homepage</h2>
            <Link to="/scan">Barcode/Receipt Scanning Mobile App (Approach A)</Link>
            {/* <Link to="/sensor">Smart Fridge Sensor (Approach B)</Link> */}
            {/* <Link to="/communityswap">Community Swap / Donation Platform (Approach C)</Link>  */}
        </div>
     );
}
 
export default Home;