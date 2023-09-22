import express from 'express';
import dotenv from 'dotenv';
import { nocache, generateRTCToken, getFirebaseCreds, matchOClock } from './routes';
import { setCallTime } from './functions'
import cron from 'node-cron';

dotenv.config();
const port = 8080;  //default http value

// set call time when server starts + daily at midnight
setCallTime(false);
cron.schedule('0 0 * * *', () => {
    setCallTime(false);
});

const app = express();

// defines endpoint for token generation
app.get('/rtc/:channel/:uid', nocache, generateRTCToken);

// endpoint returning firebase credentials
app.get('/api/firebase', getFirebaseCreds);

// consider deleting this or further securing this after app store submission
app.post('/match/now', matchOClock)

app.listen(port, () => console.log(`Server listening on ${port}`));