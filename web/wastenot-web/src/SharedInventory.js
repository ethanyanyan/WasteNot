import React, { useState } from "react";
import { db, auth } from "./firebase";
import { useAuthState } from "react-firebase-hooks/auth";
import { doc, updateDoc, getDocs, collection, query, where, arrayUnion, getDoc, setDoc } from "firebase/firestore";
import "./SharedInventory.css";

const SharedInventory = () => {
    const [user] = useAuthState(auth);
    const [newMemberEmail, setNewMemberEmail] = useState("");
    const [message, setMessage] = useState("");

    const handleAddMember = async () => {
        if (!user) {
            console.error("User is not authenticated.");
            alert("Please log in first.");
            return;
        }
        if (!newMemberEmail.trim()) {
            alert("Please enter a valid email address.");
            return;
        }
        console.log("Authenticated user:", user.uid);
    
        try {
            const usersRef = collection(db, "users");
            const q = query(usersRef, where("email", "==", newMemberEmail));
            const userSnapshot = await getDocs(q);
    
            if (userSnapshot.empty) {
                alert("User not found!");
                console.warn("User not found with email:", newMemberEmail);
                return;
            }
    
            const memberId = userSnapshot.docs[0].id;
            console.log("Found member ID:", memberId);
    
            const inventoryRef = doc(db, "sharedInventories", user.uid);
            console.log("Document path:", inventoryRef.path);

            const inventoryData = {
                owner: user.uid,
                name: "Home",
                createdAt: new Date(),
                members: {
                    [user.uid]: "owner",
                    [memberId]: "member"
                },
                membersArray: [user.uid, memberId],
            };
            console.log("Inventory data to be set:", inventoryData);

            const inventoryDoc = await getDoc(inventoryRef);
            console.log("Shared Inventory Document Exists:", inventoryDoc.exists());
            if (!inventoryDoc.exists()) {
                await setDoc(inventoryRef, inventoryData);
                console.log("Created new shared inventory document with owner:", user.uid);
            } else {
                await updateDoc(inventoryRef, {
                    [`members.${memberId}`]: "member",
                    membersArray: arrayUnion(memberId)
                });
                console.log("Updated existing shared inventory with new member:", memberId);
            }
    
            setMessage("Member added to shared inventory successfully!");
            setNewMemberEmail("");
        } catch (error) {
            console.error("Error adding member:", error.code, error.message, error);
            alert("Failed to add member to shared inventory. Please try again. Error: " + error.message);
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
