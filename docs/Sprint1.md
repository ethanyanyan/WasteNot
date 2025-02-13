# Sprint 1: AWS Setup & Initial UI/UX Prototypes

## Overview

In Sprint 1 we established the technical and design foundations for WasteNot. Our work focused on:

- Configuring core AWS services for our backend (Cognito, API Gateway, Lambda, DynamoDB, S3, and SNS)
- Developing low-fidelity prototypes for our mobile and web applications
- Setting up distinct prototype flows for the three proposed solution approaches:
  - **Approach A:** Barcode/Receipt Scanning – Automatic inventory entry with recipe suggestions
  - **Approach B:** Smart Fridge Sensor (IoT) – Real-time sensor simulation and automated alerts
  - **Approach C:** Community Swap/Donation – Localized surplus food listings and sharing
- Integrating a debug toggle (located on the Profile page) to switch between prototype approaches

These efforts directly address the core problem (food waste due to poor inventory tracking and over-purchasing) as described in our project notebook.

## Objectives

### Backend Setup

- **AWS Cognito:**  
  Configured for secure user authentication (sign in/sign up) per team member Ethan’s backend setup.
- **API Endpoints:**  
  Created endpoints (via API Gateway / Amplify DataStore) for:
  - Item entry (scanned or manually entered grocery items)
  - Retrieval of inventory data
- **Database & Storage:**
  - Designed a basic DynamoDB schema (storing name, quantity, expiration date, etc.)
  - Configured an S3 bucket for image uploads (receipts, barcodes)
- **Scheduled Tasks & Notifications:**
  - Developed a Lambda function (triggered by EventBridge/CloudWatch) to check for items nearing expiration
  - Prepared for integration with AWS SNS to send push notifications

### Mobile & Web Prototyping

- **Mobile (iOS):**
  - Developed authentication screens and a common Inventory view
  - Built distinct screens for each approach:
    - **Approach A:** Scan view (with a "Scan Receipt" button) and a Recipes view (with personalized recipe suggestions)
    - **Approach B:** Sensor view (simulating IoT sensor updates) and a Recipes view
    - **Approach C:** Community Swap view (showing mock listings with “Contact” buttons)
  - Embedded a debug toggle (on the Profile page) to switch between approaches
- **Web:**
  - Initiated a React-based prototype for the Community Swap dashboard, enabling users to view and coordinate pick-ups

### UX/UI & Prototyping

- Created initial wireframes and clickable prototypes in Figma
- Defined user flows from authentication through inventory management to notifications
- Gathered early user insights (via interviews and surveys) to validate our design direction

## Deliverables

- **Backend Documentation:**
  - AWS Cognito configuration
  - API endpoints and DynamoDB schema documentation
  - S3 bucket and Lambda function setup guides
- **Mobile Prototype:**
  - A low-fidelity iOS project (SwiftUI) containing:
    - Inventory, Scan/Sensor, Recipes, and Community Swap views with mock data
    - A Profile view with a debug toggle for approach switching
- **Web Prototype:**
  - A basic React dashboard for Approach C (Community Swap)
- **UX/UI Assets:**
  - Wireframes, clickable prototypes, and an initial user testing plan

## Tasks & Timeline

### Week 1:

- **AWS Setup:**
  - Configure Cognito, API endpoints, DynamoDB, S3, Lambda, and SNS
- **Project Initialization:**
  - Establish iOS and web project structures in GitHub
- **Architecture Documentation:**
  - Draft initial architecture overview (see Appendix C)

### Week 2:

- **Prototype Development:**
  - Build authentication and Inventory views
  - Implement distinct screens for:
    - Approach A (Scan & Recipes)
    - Approach B (Sensor & Recipes)
    - Approach C (Community Swap)
  - Integrate the debug toggle in the Profile view
- **UX/UI Wireframes:**
  - Develop and refine Figma prototypes based on team feedback

### Week 3:

- **Integration Testing:**
  - Test AWS connectivity and data flow between mobile/web apps and the backend
- **Initial User Testing:**
  - Conduct interviews with 10 users (as per Appendix A)
- **Documentation Update:**
  - Revise sprint documentation based on testing and integration feedback

## Risks & Mitigation Strategies

- **AWS Integration:**  
  _Risk:_ Misconfiguration may disrupt authentication or data retrieval.  
  _Mitigation:_ Follow AWS best practices and refer to official documentation.
- **Prototype Complexity:**  
  _Risk:_ Handling three distinct approaches in one codebase can lead to UI inconsistencies.  
  _Mitigation:_ Use a modular design with a debug toggle to isolate prototype logic.
- **User Adoption:**  
  _Risk:_ Manual scanning in Approach A might deter busy users.  
  _Mitigation:_ Simplify the scanning process and plan for incentive elements (gamification).

## Next Steps

- Review Sprint 1 outcomes and integrate feedback from user testing
- Prioritize refinements based on interview insights and survey data
- Transition to deeper integration in Sprint 2

---

## Appendix

### Appendix A: Interview Summaries (Sprint 1)

- **Adult Professional (G.E.):**  
  “I often forget what’s in my fridge until it’s already spoiled.”  
  _Pain Points:_ Poor tracking of perishable items, wasted money
- **Adult Professional with Partner (M.L.):**  
  “Meal planning apps are too much work…”  
  _Pain Points:_ Manual logging, forgotten groceries
- **Grad Student (C.L.):**  
  “I feel bad throwing away food…”  
  _Pain Points:_ Unpredictable schedule, budget constraints
- **Busy Parent (C.Y.):**  
  “I do a weekly grocery run, but by midweek I forget what’s left…”  
  _Pain Points:_ Overbuying, lack of inventory tracking
- (Additional interview summaries are documented in the project notebook.)

### Appendix B: Sprint Changes & To-Do Checklists

- **Sprint 1 Work (Completed):**
  - Team name, roles, and initial agreements
  - Problem overview, domain research, and competitive analysis
  - Proposed solution approaches and use cases
  - Initial architecture diagram (see Appendix C)
- **Sprint 2 Checklist (Planned for Sprint 2):**
  - Refine prototypes based on user feedback
  - Conduct additional interviews (target: 29 respondents)
  - Develop and refine the Value Proposition Canvas (Appendix D)

### Appendix C: Application Architecture Diagrams

- **Approach A & B:**  
  iOS front end (SwiftUI) integrated with AWS API Gateway, Lambda, DynamoDB, and SNS.
- **Approach C:**  
  React-based web app with companion mobile notifications; shared backend with added modules for user verification.

### Appendix D: Value Proposition Canvas

- Detailed VPC mapping customer jobs, pains, and gains to our solution’s features (see Mermaid code in project notebook).

### Appendix E: Mobile Skeleton Prototype UI

- Screenshots of Login, Profile (with toggle), Inventory, Scan, Sensor, Recipes, and Swap views are stored on GitHub and referenced in our project notebook.
