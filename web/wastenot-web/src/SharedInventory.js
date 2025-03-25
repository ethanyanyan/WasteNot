import React, { useState } from "react";
import { db, auth } from "./firebase";
import { useAuthState } from "react-firebase-hooks/auth";
import { doc, updateDoc, getDocs, collection, query, where, arrayUnion } from "firebase/firestore";
import "./SharedInventory.css";

const SharedInventory = () => {
    const [user] = useAuthState(auth);
    const [newMemberEmail, setNewMemberEmail] = useState("");
    const [message, setMessage] = useState("");

    const handleAddMember = async () => {
        if (!newMemberEmail.trim()) {
            alert("Please enter a valid email address.");
            return;
        }

        try {
            const usersRef = collection(db, "users");
            const q = query(usersRef, where ("email", "==", newMemberEmail));
            const userSnapshot = await getDocs(q);

            if (userSnapshot.empty) {
                alert("User not found!");
                return;
            }

            const memberId = userSnapshot.docs[0].id;
            const inventoryRef = doc(db, "inventories", user.uid);

            await updateDoc(inventoryRef, {
                [`members.${memberId}`]: "member",
                membersArray: arrayUnion(memberId)
            });

            setMessage("Member added successfully!");
            setNewMemberEmail("");
        } catch (error) {
            console.error("Error adding member:", error);
            alert("Failed to add member. Please try again");
        }
    };

    return (
        <div className="shared-inventory">
            <h2>Shared Inventory</h2>
            <input 
                type="email"
                placeholder="Member email"
                value={newMemberEmail}
                onChange={(e) => setNewMemberEmail(e.target.value)}
            />
            <button onClick={handleAddMember}>Add Member</button>
            {message && <p>{message}</p>}
        </div>
    );
};

export default SharedInventory;