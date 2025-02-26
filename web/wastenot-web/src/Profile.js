import "./Profile.css";
import { auth } from "./firebase";
import { signOut } from "firebase/auth";
import { useNavigate } from "react-router-dom";

const Profile = ({ userData }) => {
    const navigate = useNavigate();

    const handleLogout = async () => {
        try {
            await signOut(auth);
            navigate("/"); // Redirect back to login page
        } catch (error) {
            console.error("Logout failed:", error);
        }
    };

    return ( 
        <div className="profile-container">
            <h2>Your Profile</h2>
            <img className="profile-icon" src="https://cdn-icons-png.flaticon.com/512/149/149071.png" alt="Profile Icon" />
            {userData ? (
                <>
                    <p><strong>Username:</strong> {userData.username}</p>
                    <p><strong>Email:</strong> {userData.email}</p>
                    <p><strong>Member Since:</strong> {new Date(userData.createdAt.seconds * 1000).toLocaleDateString()}</p>
                </>
            ) : (
                <p>Loading user data...</p>
            )}

            {/* Logout Button */}
            <button className="logout-button" onClick={handleLogout}>Logout</button>
        </div>
     );
}
 
export default Profile;
