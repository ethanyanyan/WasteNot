import { useLocation } from "react-router-dom";

const Navbar = () => {
    const location = useLocation();
    const currentPath = location.pathname.toLowerCase(); // Convert path to lowercase

    // Hide links based on the current approach
    const isReceiptPage = currentPath === "/scan";
    const isSensorPage = currentPath === "/sensor";
    const isCommunitySwapPage = currentPath === "/communityswap";

    return (
        <nav className="navbar">
            <h1>WasteNot</h1>
            <div className="links">
                <a href="/home">Home</a>
                <a href="/inventory">Inventory</a>
                {!isCommunitySwapPage && !isSensorPage && <a href="/scan">Receipt (Approach A)</a>}
                {!isReceiptPage && !isCommunitySwapPage && <a href="/sensor">Sensor (Approach B)</a>}
                {!isSensorPage && !isReceiptPage && <a href="/communityswap">Community Swap (Approach C)</a>}
                <a href="/profile">Profile</a>
            </div>
        </nav>
    );
};

export default Navbar;
