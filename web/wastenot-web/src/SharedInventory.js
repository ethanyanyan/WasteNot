import React, { useState } from "react";
import { db, auth } from "./firebase";
import { useAuthState } from "react-firebase-hooks/auth";
import { doc, getDocs, collection, query, where, setDoc } from "firebase/firestore";
import { v4 as uuidv4 } from "uuid";
import "./SharedInventory.css";

const SharedInventory = () => {
    const [user] = useAuthState(auth);
    const [newMemberEmail, setNewMemberEmail] = useState("");
    const [message, setMessage] = useState("");

    const handleAddMember = async () => {
        if (!user) {
            alert("Please log in first.");
            return;
        }
    
        if (!newMemberEmail.trim()) {
            alert("Please enter a valid email address.");
            return;
        }
    
        try {
            const usersRef = collection(db, "users");
            const q = query(usersRef, where("email", "==", newMemberEmail));
            const userSnapshot = await getDocs(q);
    
            if (userSnapshot.empty) {
                alert("User not found!");
                return;
            }
    
            const invitedUserId = userSnapshot.docs[0].id;
            const inventoriesRef = collection(db, "inventories");
    
            // Step 1: Get both inventories
            const currentUserInventoryQuery = query(inventoriesRef, where("owner", "==", user.uid));
            const invitedUserInventoryQuery = query(inventoriesRef, where("owner", "==", invitedUserId));
    
            const [currentUserInventorySnapshot, invitedUserInventorySnapshot] = await Promise.all([
                getDocs(currentUserInventoryQuery),
                getDocs(invitedUserInventoryQuery)
            ]);
    
            let currentUserDocRef = null;
            let invitedUserDocRef = null;
    
            const allMemberSet = new Set([user.uid, invitedUserId]);
    
            // Step 2: collect all members from current user's doc
            if (!currentUserInventorySnapshot.empty) {
                const docData = currentUserInventorySnapshot.docs[0].data();
                currentUserDocRef = currentUserInventorySnapshot.docs[0].ref;
                (docData.membersArray || []).forEach(uid => allMemberSet.add(uid));
            } else {
                currentUserDocRef = doc(db, "inventories", uuidv4());
            }
    
            // Step 3: collect all members from invited user's doc
            if (!invitedUserInventorySnapshot.empty) {
                const docData = invitedUserInventorySnapshot.docs[0].data();
                invitedUserDocRef = invitedUserInventorySnapshot.docs[0].ref;
                (docData.membersArray || []).forEach(uid => allMemberSet.add(uid));
            } else {
                invitedUserDocRef = doc(db, "inventories", uuidv4());
            }
    
            // Step 4: build unified members map
            const mergedMembersArray = Array.from(allMemberSet);
            const mergedMembersObject = {};
            mergedMembersArray.forEach(uid => {
                mergedMembersObject[uid] = (uid === user.uid || uid === invitedUserId) ? "owner" : "member";
            });
    
            // Step 5: define shared structure
            const newInventoryData = {
                name: "Home",
                createdAt: new Date(),
                members: mergedMembersObject,
                membersArray: mergedMembersArray
            };
    
            // Step 6: write to both inventories (merge so we don’t overwrite)
            await setDoc(currentUserDocRef, {
                ...newInventoryData,
                owner: user.uid
            }, { merge: true });
    
            await setDoc(invitedUserDocRef, {
                ...newInventoryData,
                owner: invitedUserId
            }, { merge: true });
    
            setMessage("Shared inventory updated successfully!");
            setNewMemberEmail("");
    
        } catch (error) {
            console.error("Error adding member:", error.code, error.message, error);
            alert("Failed to add member to shared inventory. Please try again. Error: " + error.message);
        }
    };        

    return (
        <div className="shared-inventory">
            <h2>Add new Member for Shared Inventory</h2>
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
