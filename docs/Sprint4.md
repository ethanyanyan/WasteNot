# Sprint 4: Shared Inventories & Invitation Management

## Overview

Building on the previous sprints, Sprint 4 focuses on implementing collaborative features for WasteNot. This sprint introduces shared inventories and invitation-based collaboration so that multiple users can manage the same grocery inventory. Key updates include:

- **Shared Inventory:**  
  Users can now create shared inventories that allow multiple collaborators. The owner of the inventory can add, edit, and manage members.
- **Inventory Invitations:**  
  Inventory owners can invite other users by email to join a shared inventory. Invitations are stored in Firestore along with the inventory’s name to avoid additional queries. Recipients can accept or decline invitations through a dedicated notifications screen.
- **Real-Time Notification Badge:**  
  The main Inventory view displays a notification badge on the bell icon reflecting the number of pending invitations.

- **Enhanced UI/UX:**  
  Improved toast notifications and email input fields (with no auto-capitalization) provide a smoother user experience.

## Objectives

### Shared Inventory Features

- Implement a Shared Inventory model that allows multiple users to access and manage a single inventory.
- Allow inventory owners to invite collaborators via email.
- Prevent duplicate invitations by verifying if a pending invitation exists.
- Store the inventory name in the invitation document to display it directly in the notifications screen.

### Invitation Management

- Build a Notifications screen where recipients can view, accept, or decline invitations.
- Update Firestore rules to ensure secure creation, reading, and updating of invitation documents.
- Display a notification badge on the main Inventory view indicating pending invitations.

### UI/UX Enhancements

- Update email text fields to prevent auto-capitalization and disable auto-correction.
- Ensure toast notifications are visible over modal sheets by using global overlays or ZStack wrappers.
- Automatically refresh shared inventory and item data upon accepting an invitation.

## Tasks & Timeline

### Week 1:

- **Shared Inventory Implementation:**
  - Define the SharedInventory model and update Firestore document structure.
  - Implement creation of shared inventories and update membership management.
- **Invitation Document Updates:**
  - Extend the InventoryInvitation model to include `inventoryName`.
  - Update invitation creation logic in NotificationsService.

### Week 2:

- **Invitation UI & Notifications:**
  - Build a NotificationsView to list pending invitations.
  - Create InvitationRow UI components to accept/decline invitations.
  - Implement duplicate invitation checks with debug logging.
- **Notification Badge:**
  - Add a dynamic notification badge to the Inventory view’s bell icon.

### Week 3:

- **Email Validation & Toasts:**
  - Enhance email TextFields to prevent auto-capitalization and disable auto-correction.
  - Update CreateSharedInventoryView to allow adding multiple emails and validate them.
  - Integrate global toast overlays so that toasts are visible even when modal sheets are presented.
- **Data Refresh:**
  - Implement automatic refresh of shared inventory and item data upon invitation acceptance.

## Risks & Mitigations

- **Permission & Security:**  
  _Risk:_ Incorrect Firestore rules could expose data or block legitimate writes.  
  _Mitigation:_ Thoroughly test Firestore rules in the Firebase console with multiple user scenarios.

- **User Experience:**  
  _Risk:_ Toast notifications may not display as expected over modal sheets.  
  _Mitigation:_ Implement global toast overlays at the root view level and test on multiple devices.

- **Backend Queries:**  
  _Risk:_ Duplicate invitations or stale data due to asynchronous updates.  
  _Mitigation:_ Use Firestore query checks and post notifications to refresh data in real time.

## Deliverables

- Updated mobile app with shared inventory creation and management.
- Inventory invitation system with email validation, duplicate checks, and a notifications screen.
- Updated Firestore rules covering users, shared inventories, and invitations.
- Revised UI prototypes and updated documentation.

## Next Steps

- Gather user feedback on the shared inventory and invitation flow.
- Prepare detailed test cases for both invitation acceptance and rejection.
- Refine the UI based on testing insights and integrate any additional collaboration features for future sprints.
