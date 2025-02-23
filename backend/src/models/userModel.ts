// src/models/userModel.ts
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.USERS_TABLE || "Users";

export interface User {
  id: string; // Cognito sub value (user's unique id)
  email: string;
  name?: string;
  // Add more profile fields as needed
}

export const createUser = async (
  user: User
): Promise<AWS.DynamoDB.DocumentClient.PutItemOutput> => {
  const params: AWS.DynamoDB.DocumentClient.PutItemInput = {
    TableName: TABLE_NAME,
    Item: user,
  };
  return dynamoDb.put(params).promise();
};

export const getUserById = async (id: string): Promise<User | null> => {
  const params: AWS.DynamoDB.DocumentClient.GetItemInput = {
    TableName: TABLE_NAME,
    Key: { id },
  };
  const result = await dynamoDb.get(params).promise();
  return (result.Item as User) || null;
};

export const updateUser = async (
  id: string,
  updates: Partial<User>
): Promise<AWS.DynamoDB.DocumentClient.UpdateItemOutput> => {
  let updateExp = "set";
  const ExpressionAttributeNames: { [key: string]: string } = {};
  const ExpressionAttributeValues: { [key: string]: any } = {};
  Object.keys(updates).forEach((key, index) => {
    updateExp += ` #attr${index} = :val${index},`;
    ExpressionAttributeNames[`#attr${index}`] = key;
    ExpressionAttributeValues[`:val${index}`] = (updates as any)[key];
  });
  updateExp = updateExp.slice(0, -1); // Remove trailing comma

  const params: AWS.DynamoDB.DocumentClient.UpdateItemInput = {
    TableName: TABLE_NAME,
    Key: { id },
    UpdateExpression: updateExp,
    ExpressionAttributeNames,
    ExpressionAttributeValues,
    ReturnValues: "UPDATED_NEW",
  };
  return dynamoDb.update(params).promise();
};
