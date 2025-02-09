const Navbar = () => {
    return ( 
        <nav className="navbar">
            <h1>WasteNot</h1>
            <div className="links">
                <a href="/Home">Home</a>
                <a href="/Inventory">Inventory</a>
                <a href="/scan">Scan</a>
                <a href="/communitySwap">Community Swap</a>
                <a href="/profile">Profile</a>
            </div>
        </nav>
     );
}
 
export default Navbar;