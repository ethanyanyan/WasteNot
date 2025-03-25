import { useLocation, Link } from "react-router-dom";

const Navbar = () => {
    const location = useLocation();
    const currentPath = location.pathname.toLowerCase();

    const isReceiptPage = currentPath === "/scan";
    const isSensorPage = currentPath === "/sensor";
    const isCommunitySwapPage = currentPath === "/communityswap";

    return (
        <nav className="navbar">
            <h1>WasteNot</h1>
            <div className="links">
                <Link to="/home">Home</Link>
                <Link to="/inventory">Inventory</Link>
                <Link to="/sharedinventory">Shared Inventory</Link>
                {!isCommunitySwapPage && !isSensorPage && <Link to="/scan">Scan (Approach A)</Link>}
                {!isReceiptPage && !isCommunitySwapPage && <Link to="/sensor">Sensor (Approach B)</Link>}
                {!isSensorPage && !isReceiptPage && <Link to="/communityswap">Community Swap (Approach C)</Link>}
                <Link to="/profile">Profile</Link>
            </div>
        </nav>
    );
};

export default Navbar;
