import express from 'express';
import { RtcTokenBuilder, RtcRole } from 'agora-access-token';
import dotenv from 'dotenv';
import { Request, Response } from "express";
import { setCallTime } from './functions'

dotenv.config();
const appId = process.env.APP_ID;
const appCertificate = process.env.APP_CERTIFICATE;

export function nocache(_: Request, res: Response, next: Function) {
    res.setHeader('Cache-Control', 'private, no-cache, no-store, must-revalidate');
    res.setHeader('Expires', '-1');
    res.setHeader('Pragma', 'no-cache');
    next();
};

// Builds Agora channel token (valid for two minutes)
export async function generateRTCToken(req: Request, res: Response) {
    if (appId === undefined || appId === '') {
        res.status(400).send('app id invalid');
        return;
    } 
    if (appCertificate === undefined || appCertificate === '') {
        res.status(400).send('app certificate invalid');
        return;
    } 

    res.setHeader('Access-Control-Allow-Origin', '*'); //change later
    let channelName = req.params.channel as string;
    if (channelName === undefined) {
        res.status(400).send('channel name required');
        return;
    } 
    let uid = req.params.uid as string;
    if (uid === undefined) {
        res.status(400).send('uid required');
        return;
    } else if (isNaN(parseInt(uid, 10)) || parseInt(uid, 10) < 1) {
        res.status(400).send('uid must be a positive integer');
        return;
    }
    let role = RtcRole.PUBLISHER;
    let duration = 120;
    const currentTime = Math.floor(Date.now() / 1000);
    const expireTime = currentTime + duration;
    
    console.log(appId)
    console.log(appCertificate)
    console.log(channelName)
    console.log(parseInt(uid, 10))
    console.log(role)
    console.log(expireTime)

    let token = RtcTokenBuilder.buildTokenWithUid(appId, appCertificate, channelName, parseInt(uid, 10), role, expireTime);

    res.status(200).send({ 'rtcToken': token });
};

// Sends credentials to configure client with Firebase
export async function getFirebaseCreds(req: Request, res: Response) {
    const firebaseConfig = {
        appID: process.env.FIREBASE_APP_ID,
        senderID: process.env.FIREBASE_SENDER_ID,
        apiKey: process.env.FIREBASE_API_KEY,
        projectID: process.env.FIREBASE_PROJECT_ID
    };

    res.status(200).send(firebaseConfig);
}

// Sets Match o'clock to current moment
export async function matchOClock(req: Request, res: Response) {
    setCallTime(true);
    res.status(200).send("CALL TIME SET");
}