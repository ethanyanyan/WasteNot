import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { auth, db } from "./firebase";
import { createUserWithEmailAndPassword } from "firebase/auth";
import { doc, setDoc } from "firebase/firestore";
import { signOut } from "firebase/auth";

const SignUp = () => {
    const navigate = useNavigate();
    const [username, setUsername] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");

    const handleSignUp = async () => {
        try {
            const userCredential = await createUserWithEmailAndPassword(auth, email, password);
            const user = userCredential.user;

            // Store user info in Firestore
            await setDoc(doc(db, "users", user.uid), {
                username: username,
                email: email,
                createdAt: new Date()
            });

            alert("Account created successfully! Please log in.");
            // Sign out the user before navigating to login
            await signOut(auth);
            navigate("/");  // Redirect back to login
        } catch (err) {
            setError("Error creating account. Try again.");
        }
    };

    return (
        <div className="signup">
            <h2>Create Account</h2>
            <input 
                type="text" 
                placeholder="Username" 
                value={username} 
                onChange={(e) => setUsername(e.target.value)} 
            />
            <input 
                type="email" 
                placeholder="Email" 
                value={email} 
                onChange={(e) => setEmail(e.target.value)} 
            />
            <input 
                type="password" 
                placeholder="Password" 
                value={password} 
                onChange={(e) => setPassword(e.target.value)} 
            />
            <button onClick={handleSignUp}>Sign Up</button>
            {error && <p style={{ color: "red" }}>{error}</p>}
            
            <p>Already have an account?</p>
            <button onClick={() => navigate("/")}>Back to Login</button>
        </div>
    );
};

export default SignUp;
