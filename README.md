# WasteNot

WasteNot is a multi-platform application designed to reduce household food waste by helping users manage grocery items and track expiration dates. With both iOS and web interfaces integrated with a serverless AWS backend, WasteNot streamlines grocery item entry, monitors food expiration, and sends timely notifications.

## Features

- **User Authentication:**  
  Secure sign in/sign up via AWS Cognito.

- **Item Entry:**  
  Scan or manually enter grocery items. Upload images (receipts, barcodes, etc.) to AWS S3.

- **AWS Backend Integration:**

  - API endpoints via API Gateway or Amplify DataStore
  - Data storage in DynamoDB
  - Scheduled AWS Lambda functions to monitor expiration dates
  - Notifications via AWS SNS (integrated with Apple APNs and web push)

- **Multi-Platform Access:**
  - iOS app (Swift/SwiftUI)
  - Responsive web application

## Technology Stack

- **Frontend:**

  - Mobile: iOS (Swift/SwiftUI)
  - Web: React or Angular (TBD)

- **Backend (AWS Free Tier Services):**
  - AWS Cognito (User Authentication)
  - API Gateway / AWS Amplify DataStore
  - AWS DynamoDB (Data Storage)
  - AWS S3 (Image Storage)
  - AWS Lambda (Serverless compute for scheduled tasks)
  - AWS SNS (Push Notifications)

## Project Structure

```
WasteNot/
├── backend/            # AWS Lambda functions, API configuration, CloudFormation templates
├── mobile/             # iOS application code (Swift/SwiftUI)
├── web/                # Web application code (React)
├── docs/               # Documentation (Sprint plans, architecture diagrams, design files, etc.)
├── prototypes/         # Low-fidelity prototypes and mockups
└── README.md
```

## Getting Started

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/your-username/WasteNot.git
   cd WasteNot
   ```

2. **Setup Development Environment:**

   - Follow the instructions in the `docs/` folder for AWS configuration and local development setup for both mobile and web apps.

3. **Branching Strategy:**
   - Use feature branches for development (e.g., `feature/aws-auth`, `feature/mobile-ui`, `feature/web-integration`).
   - Create pull requests for code reviews.
   - See [CONTRIBUTING.md](CONTRIBUTING.md) for further details.

## Sprint 1 Goals

For Sprint 1, our focus is on setting up the core AWS backend services and creating initial UI/UX prototypes for the iOS and web applications. For details, see our [Sprint 1 Documentation](docs/Sprint1.md).
