import { BrowserRouter as Router, Route, Routes, Navigate } from "react-router-dom";
import { useAuthState } from "react-firebase-hooks/auth";
import { auth, db } from "./firebase";
import { doc, getDoc } from "firebase/firestore";
import { useEffect, useState } from "react";
import Navbar from "./Navbar";
import Home from "./Home";
import Inventory from "./Inventory";
import SharedInventory from "./SharedInventory";
import Scan from "./Scan";
import Profile from "./Profile";
import Login from "./Login";
import SignUp from "./SignUp";

function App() {
    const [user] = useAuthState(auth);
    const [userData, setUserData] = useState(null);

    // Load user data from Firestore
    useEffect(() => {
        const fetchUserData = async () => {
            if (user) {
                const docRef = doc(db, "users", user.uid);
                const docSnap = await getDoc(docRef);
                if (docSnap.exists()) {
                    setUserData(docSnap.data());
                }
            }
        };

        fetchUserData();
    }, [user]);

    return (
        <Router>
            <div className="App">
                {user && <Navbar />}
                <div className="content">
                    <Routes>
                        <Route path="/" element={user ? <Navigate to="/home" /> : <Login />} />
                        <Route path="/signup" element={<SignUp />} />
                        <Route path="/home" element={user ? <Home /> : <Navigate to="/" />} />
                        <Route path="/inventory" element={user ? <Inventory /> : <Navigate to="/" />} />
                        {/* <Route path="/sharedinventory" element={user ? <SharedInventory /> : <Navigate to="/" />} /> */}
                        <Route path="/scan" element={user ? <Scan /> : <Navigate to="/" />} />
                        <Route path="/profile" element={user ? <Profile userData={userData} /> : <Navigate to="/" />} />
                    </Routes>
                </div>
            </div>
        </Router>
    );
}

export default App;
