// src/models/inventoryModel.ts
import AWS from "aws-sdk";

const dynamoDb = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.DYNAMODB_TABLE || "Inventory";

export const createItem = async (
  item: any
): Promise<AWS.DynamoDB.DocumentClient.PutItemOutput> => {
  const params: AWS.DynamoDB.DocumentClient.PutItemInput = {
    TableName: TABLE_NAME,
    Item: item,
  };
  return dynamoDb.put(params).promise();
};

export const getAllItems = async (): Promise<any[]> => {
  const params: AWS.DynamoDB.DocumentClient.ScanInput = {
    TableName: TABLE_NAME,
  };
  const data = await dynamoDb.scan(params).promise();
  return data.Items || [];
};

export const getItemById = async (id: string): Promise<any> => {
  const params: AWS.DynamoDB.DocumentClient.GetItemInput = {
    TableName: TABLE_NAME,
    Key: { id },
  };
  const data = await dynamoDb.get(params).promise();
  return data.Item;
};

export const updateItem = async (
  id: string,
  updates: any
): Promise<AWS.DynamoDB.DocumentClient.UpdateItemOutput> => {
  let updateExp = "set";
  const ExpressionAttributeNames: { [key: string]: string } = {};
  const ExpressionAttributeValues: { [key: string]: any } = {};
  Object.keys(updates).forEach((key, index) => {
    updateExp += ` #attr${index} = :val${index},`;
    ExpressionAttributeNames[`#attr${index}`] = key;
    ExpressionAttributeValues[`:val${index}`] = updates[key];
  });
  // Remove the trailing comma
  updateExp = updateExp.slice(0, -1);

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

export const deleteItem = async (
  id: string
): Promise<AWS.DynamoDB.DocumentClient.DeleteItemOutput> => {
  const params: AWS.DynamoDB.DocumentClient.DeleteItemInput = {
    TableName: TABLE_NAME,
    Key: { id },
  };

  return dynamoDb.delete(params).promise();
};
