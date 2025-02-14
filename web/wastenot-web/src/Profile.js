import "./Profile.css";

const Profile = () => {
    return ( 
        <div className="profile-container">
            <h2>Your Profile</h2>
            <img className="profile-icon" src="https://cdn-icons-png.flaticon.com/512/149/149071.png" alt="Profile Icon" />
            <p><strong>Username:</strong> JohnDoe123</p>
            <p><strong>Email:</strong> <a href="mailto:john.doe@example.com">john.doe@example.com</a></p>
            <p><strong>Member Since: </strong>Feb 2025</p>
        </div>
     );
}
 
export default Profile;