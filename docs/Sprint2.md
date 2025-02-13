# Sprint 2: Prototype Refinement & Integration

## Overview

Building on Sprint 1’s foundation, Sprint 2 focuses on refining our WasteNot prototypes and integrating deeper backend functionality. In this sprint we:

- Enhance UI/UX for all distinct solution approaches based on initial user feedback
- Integrate API endpoints for real-time data updates (inventory, recipe suggestions, sensor alerts)
- Implement additional interactive features such as push notifications (via AWS SNS) and preliminary user verification for the Community Swap view
- Further refine the debug toggle mechanism for seamless switching between approaches

These improvements directly address the user pain points and feature priorities outlined in our project notebook.

## Objectives

### UI/UX Refinement

- **Mobile App Enhancements:**
  - Polish Inventory, Scan (Approach A), Sensor (Approach B), Recipes, and Community Swap views with higher-fidelity UI elements and mock data
  - Add interactive buttons (e.g., “Scan Receipt,” “Simulate Sensor Update,” “View Recipe Details,” “Contact”)
- **Debug Toggle Enhancement:**
  - Refine the toggle on the Profile page for smooth switching between the approaches
- **Web App Refinement:**
  - Enhance the React-based dashboard for Approach C (Community Swap)

### Backend Integration

- **API Connectivity:**
  - Connect mobile screens with AWS API endpoints for item CRUD operations and recipe suggestions
- **Lambda & SNS Integration:**
  - Improve the Lambda function for more accurate expiration alert simulation
  - Integrate AWS SNS to simulate push notifications
- **Recipe Recommendation Engine:**
  - Incorporate a basic (mock) recipe engine that highlights missing ingredients for both Approach A and B

### User Testing & Feedback

- Develop and distribute updated user surveys (targeting 29 participants as per our recent interview round)
- Schedule and conduct in-person/remote testing sessions to gather qualitative and quantitative feedback
- Iterate on UI/UX refinements based on testing insights

## Deliverables

- **Refined Mobile Prototype:**
  - Higher-fidelity screens for Inventory, Scan/Sensor, Recipes, and Community Swap views with updated mock data and interactive elements
  - Improved Profile view with a refined debug toggle
- **Backend Integration:**
  - Updated API endpoints and Lambda function logic for inventory updates and expiration alerts
  - Simulated push notifications via AWS SNS
- **User Testing Materials:**
  - Revised user testing plan, survey instruments, and session recordings
- **Documentation:**
  - Updated technical documentation, revised wireframes, and a sprint review report summarizing user feedback and integration challenges

## Tasks & Timeline

### Week 1:

- **UI/UX Refinement:**
  - Redesign mobile screens for improved aesthetics and usability (Inventory, Scan/Sensor, Recipes, Swap)
  - Update Figma prototypes with refined layouts and interactive elements
- **Backend Connectivity:**
  - Integrate Inventory and Recipe views with AWS API endpoints
  - Update the Lambda function for better simulation of expiration alerts
- **Toggle Enhancement:**
  - Refine and test the debug toggle in the Profile view for smooth approach switching

### Week 2:

- **Push Notifications & Advanced Features:**
  - Integrate AWS SNS to simulate push notifications for expiring items
  - Add interactive elements (e.g., "View Recipe Details", "Add New Listing", "Contact" buttons) in all views
  - Implement preliminary user verification and rating mock-ups for Community Swap
- **Web Dashboard Enhancements:**
  - Refine the React-based dashboard prototype for surplus food listings
- **User Testing Preparation:**
  - Update and distribute revised user surveys (target: 29 respondents)
  - Schedule testing sessions with target user groups

### Week 3:

- **User Testing & Iterative Improvements:**
  - Conduct testing sessions (both in-person and remote)
  - Analyze qualitative and quantitative feedback
  - Implement iterative improvements based on testing outcomes
- **Documentation Update:**
  - Revise technical documentation, update wireframes, and prepare a comprehensive sprint review report

## Risks & Mitigation Strategies

- **Integration Delays:**  
  _Risk:_ Backend connectivity issues might delay UI testing.  
  _Mitigation:_ Use modular integration and maintain close collaboration between frontend and backend teams.
- **Ambiguous User Feedback:**  
  _Risk:_ Conflicting feedback may complicate design refinements.  
  _Mitigation:_ Prioritize common pain points using quantitative survey data.
- **Scope Creep:**  
  _Risk:_ Adding too many advanced features may impact core prototype delivery.  
  _Mitigation:_ Focus on essential functionalities and defer non-critical enhancements to later sprints.

## Next Steps

- Summarize user testing feedback and finalize design adjustments
- Develop a detailed plan for Sprint 3 to produce a high-fidelity prototype and integrate advanced features (e.g., AI-driven recipe recommendations)
- Update overall project documentation, wireframes, and integration guidelines

---

## Appendix

### Appendix A: Project Notebook References

- **Problem Overview & Domain Research:**  
  Food waste is a significant concern due to over-purchasing, poor inventory tracking, and confusion over expiration dates. USDA statistics and user interviews confirm these pain points.
- **Solution Approaches:**
  - **Approach A:** Barcode/Receipt Scanning for automated inventory entry and recipe suggestions.
  - **Approach B:** Smart Fridge Sensor for real-time monitoring and automated alerts.
  - **Approach C:** Community Swap/Donation for redistributing surplus food locally.

### Appendix B: Use Cases & Interview Insights

- **Use Cases:**
  - Approach A: Busy Parent, Health-Conscious Student, and Housemate Collaboration.
  - Approach B: Single Professional, Large Family, and IoT Integration for Home Automation Enthusiasts.
  - Approach C: Overstocked Shopper, New Neighborhood Resident, and Local Food Bank Collaboration.
- **Interview Highlights:**  
  Detailed summaries (see project notebook Appendix A) illustrate challenges with manual tracking, sensor reliability, and community trust.

### Appendix C: Architecture & Technology Stack (Detailed in Sprint 1)

- **Approaches A & B:**  
  iOS mobile app (SwiftUI) using AWS API Gateway, Lambda, DynamoDB, and SNS.
- **Approach C:**  
  React-based web app with companion mobile notifications, and additional modules for user verification and ratings.

### Appendix D: Value Proposition Canvas

- The VPC maps our customer segments (busy individuals, families, eco-conscious consumers) to their jobs, pains, and gains, and aligns these with our solution’s features (automated alerts, personalized recipes, community sharing). (Refer to the full VPC diagram in the project notebook.)

### Appendix E: Updated UI & Prototype Screenshots

- Updated screenshots of refined UI for Login, Profile (with debug toggle), Inventory, Scan, Sensor, Recipes, and Community Swap views are available on GitHub and have been revised based on Sprint 1 user feedback.
