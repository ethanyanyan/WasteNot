import "./Profile.css";

const Profile = ({ userData }) => {
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
        </div>
     );
}
 
export default Profile;
