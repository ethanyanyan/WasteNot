# WasteNot Backend (TypeScript)

This is the serverless backend for the WasteNot project (Approach A: Barcode/Receipt Scanning) written in TypeScript. It implements basic CRUD operations for inventory management using DynamoDB and is deployed on AWS Lambda via the Serverless Framework.

## Project Structure

```
backend/
├── src/
│   ├── controllers/
│   │   └── inventoryController.ts   # CRUD logic for inventory endpoints
│   ├── models/
│   │   └── inventoryModel.ts          # DynamoDB integration functions (with types)
│   ├── routes/
│   │   └── inventory.ts               # Express routes for CRUD operations
│   └── app.ts                         # Main Express app (exported for Lambda)
├── handler.ts                         # Wraps the Express app for AWS Lambda
├── serverless.yml                     # Serverless Framework configuration
├── package.json                       # Node.js project manifest
├── tsconfig.json                      # TypeScript configuration
├── .env                               # Environment variables (local development)
└── README.md                          # Project documentation and deployment instructions
```

## Setup and Deployment

### Prerequisites

- Node.js (v14 or later)
- AWS CLI configured with appropriate credentials
- Serverless Framework CLI (`npm install -g serverless`)

### Installation

1. Clone the repository and navigate to the `backend/` folder.
2. Install dependencies:
   ```bash
   npm install
   ```

### Local Development

Run the server locally with:

```bash
npm run dev
```

_Note: The Express app will run normally for testing purposes. In production, it is deployed to AWS Lambda._

### Deploying to AWS

1. Build the TypeScript files:
   ```bash
   npm run build
   ```
2. Deploy the application:
   ```bash
   npm run deploy
   ```
3. The deployment output will display an API Gateway endpoint URL.

## AWS Resources

- **API Gateway & Lambda:**  
  The Express app (wrapped with serverless-http) is deployed as a Lambda function and exposed via API Gateway.

- **DynamoDB:**  
  The backend uses a DynamoDB table (default name: `Inventory`) to store inventory items. Ensure this table exists in your AWS account.

- **SNS:**  
  AWS SNS is set up for potential push notifications (stubbed integration).

## Endpoints

- **POST /inventory**  
  Create a new inventory item.  
  _Body:_ JSON containing at least an `id` field and other item attributes.

- **GET /inventory**  
  Retrieve all inventory items.

- **GET /inventory/{id}**  
  Retrieve a specific inventory item.

- **PUT /inventory/{id}**  
  Update an inventory item.  
  _Body:_ JSON with attributes to update.

- **DELETE /inventory/{id}**  
  Delete an inventory item.

## Future Tasks

- Add authentication and input validation.
- Write unit and integration tests.
- Enhance error handling and logging.
- Refine IAM policies for production use.

## Contact

For issues or further instructions, please contact the backend lead.
