# WasteNot

WasteNot is a multi-platform application designed to reduce household food waste by helping users manage grocery items and track expiration dates. With both iOS and web interfaces integrated with a modern, serverless backend, WasteNot streamlines grocery item entry, monitors food expiration, and sends timely notifications.

## Features

- **User Authentication & Data Storage:**  
  Secure sign in/sign up using Firebase Authentication with data managed in Firestore.

- **Item Entry & Barcode Scanning:**  
  Users can scan or manually enter grocery items. UPC barcodes are converted to detailed item information via the Barcode Lookup API.

- **Photo Storage:**  
  Upload images (e.g., receipts, barcodes) that are stored in Cloudinary.

- **Automated Daily Emails:**  
  A GitHub Actions workflow runs scheduled cron jobs that trigger daily email notifications to users using the SendGrid API.

- **Multi-Platform Access:**
  - iOS app (Swift/SwiftUI)
  - Responsive web application

## Technology Stack

- **Frontend:**

  - Mobile: iOS (Swift/SwiftUI)
  - Web: React (or similar framework)

- **Backend & External Services:**
  - **Firebase Authentication:** User Authentication
  - **Firestore:** Data Storage
  - **Barcode Lookup API:** Convert UPC to item details
  - **Cloudinary:** Photo/Image Storage
  - **GitHub Actions:** Scheduled Cron Jobs
  - **SendGrid API:** Email Notifications

## Architecture Diagram

Below is the high-level architecture diagram for WasteNot:

```mermaid
flowchart TD
    subgraph Clients
        A[iOS App]
        B[Web App]
    end

    subgraph Authentication & Database
        C[Firebase Auth]
        D[Firestore]
    end

    subgraph External Services
        E[Barcode Lookup API]
        F[Cloudinary]
        G[SendGrid API]
    end

    subgraph Automation
        H[GitHub Actions (Cron Jobs)]
    end

    A --> C
    B --> C
    C --> D
    A --> D
    B --> D
    A -- Scan UPC --> E
    B -- Scan UPC --> E
    A -- Upload Photos --> F
    B -- Upload Photos --> F
    H --> G
```

## Project Structure

```
WasteNot/
├── mobile/             # iOS application code (Swift/SwiftUI)
├── web/                # Web application code (React)
├── functions/          # Firebase Cloud Functions (if applicable)
├── workflows/          # GitHub Actions workflows (cron jobs)
├── docs/               # Documentation (architecture diagrams, design files, etc.)
└── README.md
```

## Getting Started

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/your-username/WasteNot.git
   cd WasteNot
   ```

2. **Setup Development Environment:**

   - Follow the instructions in the `docs/` folder for Firebase configuration and local development setup for both mobile and web apps.
   - Configure API keys for Barcode Lookup, Cloudinary, and SendGrid as specified in the project documentation.

3. **Branching Strategy:**
   - Use feature branches for development (e.g., `feature/firebase-auth`, `feature/ios-ui`, `feature/web-integration`).
   - Create pull requests for code reviews.
   - See [CONTRIBUTING.md](CONTRIBUTING.md) for further details.
