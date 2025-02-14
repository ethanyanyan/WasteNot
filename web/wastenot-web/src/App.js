import { BrowserRouter as Router, Route, Routes, useLocation } from 'react-router-dom';
import Navbar from './Navbar';
import Home from './Home';
import Inventory from './Inventory';
import Scan from './Scan';
import Sensor from './Sensor';
import CommunitySwap from './CommunitySwap';
import Profile from './Profile';
import Login from './Login';

function App() {
  return (
    <Router>
      <MainContent />
    </Router>
  );
}

function MainContent() {
  const location = useLocation();
  const hideNavbar = location.pathname === "/";

  return (
    <div className="App">
      {!hideNavbar && <Navbar />}
      <div className="content">
        <Routes>
          <Route path="/" element={<Login />} />
          <Route path="/home" element={<Home />} />
          <Route path="/inventory" element={<Inventory />} />
          <Route path="/scan" element={<Scan />} />
          <Route path="/sensor" element={<Sensor />} />
          <Route path="/communityswap" element={<CommunitySwap />} />
          <Route path="/profile" element={<Profile />} />
        </Routes>
      </div>
    </div>
  );
}

export default App;
