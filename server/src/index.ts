import express from 'express';
import dotenv from 'dotenv';
import { nocache, generateRTCToken, getFirebaseCreds } from './routes';
import { setCallTime } from './functions'
import cron from 'node-cron';

dotenv.config();
const port = 8080;  //default http value

// set call time when server starts + daily at midnight
setCallTime();
cron.schedule('0 0 * * *', setCallTime);

const app = express();

// defines endpoint for token generation
app.get('/rtc/:channel/:uid', nocache, generateRTCToken);

// endpoint returning firebase credentials
app.get('/api/firebase', getFirebaseCreds);

app.listen(port, () => console.log(`Server listening on ${port}`));