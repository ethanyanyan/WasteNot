# Sprint 1: AWS Setup & Initial UI/UX Prototypes

## Overview

Sprint 1 focuses on laying the foundation for WasteNot. This includes configuring core AWS services for our backend and developing initial prototypes for both our iOS and web applications. The goal is to set up user authentication, item entry, and notification workflows.

## Objectives

### Backend Setup

- **AWS Cognito:**  
  Configure Cognito for secure user authentication (sign in/sign up).

- **API Endpoints:**  
  Set up API Gateway (or AWS Amplify DataStore) endpoints for:

  - Item entry (adding grocery items)
  - Retrieving item data

- **Database & Storage:**

  - Design and implement a basic DynamoDB schema for grocery items (name, quantity, expiration date, etc.).
  - Configure an S3 bucket for image uploads (e.g., receipts, barcodes).

- **Scheduled Tasks:**  
  Develop an initial AWS Lambda function triggered by EventBridge/CloudWatch to test scheduled queries on DynamoDB for items nearing expiration.

- **Notification System:**  
  Prepare for AWS SNS integration to send push notifications via Apple APNs (and web push if applicable).

### Mobile Application (iOS)

- **Project Initialization:**  
  Create an initial iOS project using Swift/SwiftUI and integrate AWS Amplify libraries.
- **Authentication Flow:**  
  Develop basic screens for user sign in/sign up.
- **Item Entry UI:**  
  Create a prototype screen for scanning or manually entering grocery items, including the ability to upload images.

### Web Application

- **Project Initialization:**  
  Set up the web application project (using React or Angular) with a basic project structure.
- **User Authentication:**  
  Integrate AWS Cognito for web-based authentication.
- **Dashboard:**  
  Develop a simple dashboard for adding, viewing, and managing grocery items.

### UX/UI and Prototyping

- **Wireframes & Mockups:**  
  Create initial wireframes and interactive prototypes for both the mobile and web interfaces.
- **User Flow Prototyping:**  
  Simulate the complete user journey from authentication to item entry and receiving notifications.

## Deliverables

- **Backend:**

  - AWS Cognito configuration documentation.
  - API endpoints for item CRUD operations.
  - DynamoDB schema design documentation.
  - S3 bucket configuration guide.
  - Initial Lambda function for scheduled expiration checks.

- **Mobile App:**

  - A basic iOS project with AWS Amplify integration.
  - Prototype screens for authentication and item entry.
  - Documentation on setup and integration challenges.

- **Web App:**

  - Starter project for the web application.
  - Basic authentication and item management interface.
  - Setup documentation.

- **UX/UI:**
  - Wireframes and interactive mockups for both platforms.
  - User testing plan and summary.

## Tasks & Timeline

### Week 1:

- [ ] **AWS Cognito:** Set up and document user authentication configuration.
- [ ] **API Gateway / Amplify DataStore:** Initialize endpoints for item entry.
- [ ] **DynamoDB Schema:** Design and document the data model.
- [ ] **S3 Bucket:** Configure and test image storage.
- [ ] **AWS Lambda:** Develop a preliminary Lambda function for scheduled expiration checks.

### Week 2:

- [ ] **iOS Project:** Initialize the project and integrate AWS Amplify.
- [ ] **Authentication Screens:** Develop and test sign in/sign up UI.
- [ ] **Item Entry Prototype (Mobile):** Create screens for scanning and manual entry.
- [ ] **Web Project:** Initialize the web application and integrate AWS Cognito.
- [ ] **Dashboard Prototype (Web):** Build a basic dashboard for item management.
- [ ] **Wireframes & Mockups:** Design initial UI/UX for both platforms.
- [ ] **GitHub Project Board:** Set up a Kanban board to track issues and progress.

### Week 3:

- [ ] **Integration Testing:** Ensure mobile and web apps communicate correctly with backend endpoints.
- [ ] **Image Upload Testing:** Validate item entry with image uploads.
- [ ] **User Testing:** Conduct initial testing sessions for both platforms and collect feedback.
- [ ] **Documentation Update:** Refine wireframes, update documentation based on feedback.

## Risks & Mitigation Strategies

- **AWS Integration Challenges:**

  - _Risk:_ Incorrect AWS configuration could disrupt authentication or API calls.
  - _Mitigation:_ Follow AWS best practices and consult official AWS documentation.

- **Prototype Development Delays:**
  - _Risk:_ UI/UX prototype delays may impact integration testing.
  - _Mitigation:_ Prioritize core functionality and maintain daily stand-ups to monitor progress.

## Next Steps

At the end of Sprint 1, hold a sprint review meeting to:

- Assess completed tasks and gather team feedback.
- Update documentation based on lessons learned.
- Adjust priorities for Sprint 2 focusing on deeper integration and enhanced UI/UX features.
