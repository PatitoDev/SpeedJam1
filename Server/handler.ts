import { randomUUID } from 'crypto';
import { APIGatewayEvent } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocument, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import { S3 } from 'aws-sdk';

const internalClient = new DynamoDBClient({});
const client = DynamoDBDocument.from(internalClient);

const invalidRequest = { 
    status: 500,
    body: 'Invalid request',
};

const tableName = "duckheist-dev-UserScore";
const bucketName = "duckheist-dev-static";

interface ScoreItem {
    id: string,
    level: string,
    userName: string,
    rawScore: number,
    score: string,
    time: number,
    isCorrect: boolean,
}

export const setScore = async (event: APIGatewayEvent) => {
    if (!event.body) return invalidRequest;
    // TODO - check existance
    const {
        level,
        rawScore,
        scoreLabel,
        time,
        userName,
        image,
        isCorrect
    } = JSON.parse(event.body) as {
        userName: string,
        rawScore: number,
        scoreLabel: string,
        time: number,
        level: string,
        image: string,
        isCorrect: boolean
    };

    console.log(event.body);

    const id = randomUUID()
    const data:ScoreItem = {
        id,
        level,
        rawScore,
        score: scoreLabel,
        time,
        userName,
        isCorrect
    };

    await client.put({
        TableName: tableName,
        Item: data
    });

    console.log('created', data);
    // upload image
    await (new S3()).upload({
        Bucket: bucketName,
        Key: `${id}.png`,
        Body: Buffer.from(image as string, 'base64'),
        ContentEncoding: 'base64',
        ContentType: 'image/png',
        ACL: 'public-read'
    }).promise();
    console.log('uploaded image');
    return {
        statusCode: 200
    }
}

export const getAllLevelScores = async (event: APIGatewayEvent) => {
    const result = ((await client.scan({
        TableName: tableName,
    })).Items ?? []) as Array<Object>;
    console.log(result);

    return {
        statusCode: 200,
        body: JSON.stringify(result)
    }
}