import * as admin from 'firebase-admin';
import axios from 'axios';
import * as apn from 'apn'; //fixing vulnerabilities makes it NOT work. lol
import * as cron from 'node-cron';
import { format, parse } from 'date-fns';

const serviceAccount = require('../matcha-5f2b0-firebase-adminsdk-cnl6c-bf9c67a9f8.json');

var options = {
  token: {
    key: 'AuthKey_NV8NM2JDKS.p8',
    keyId: "NV8NM2JDKS",
    teamId: "Y72QJH6U54"
  },
  production: false   //set to true once deployed
};

var apnProvider = new apn.Provider(options);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://matcha-5f2b0-default-rtdb.firebaseio.com'
})

const db = admin.database();

// schedules app functionality:
// - random call time set
// - notifications scheduled
// - matching scheduled
export async function setCallTime(rn: boolean) {
  // 0. clear matchpool of potential leftovers
  const pool = db.ref('matchPool');
  pool.remove();

  let callTime: Date = new Date(); 

  const callTimeRef = db.ref('callTime')
  let set: boolean = false; //whether we chillin rn or nah
  if (!rn) {
    // 1. check if calltime currently exists + is valid. otherwise set a valid call time 
    // initialize as invalid, will be overwritten
    callTime.setDate(callTime.getDate()-1);

    await callTimeRef.once('value', (snapshot) => {
      const callTimeValue = snapshot.val();
      console.log('callTime value fetched:', callTimeValue);
      if (callTimeValue != null) {
        callTime = parse(callTimeValue, 'yyyy-MM-dd HH:mm:ss', new Date());
      }

      const lastMidnight = new Date();
      lastMidnight.setHours(0);
      lastMidnight.setMinutes(0);

      const nextMidnight = new Date();
      nextMidnight.setDate(nextMidnight.getDate()+1);
      nextMidnight.setHours(0);
      nextMidnight.setMinutes(0);

      console.log("calltime", callTime)
      console.log("next midnight", nextMidnight)

      if (callTime > lastMidnight && callTime < nextMidnight) set = true;
      else {
        set = false;
        callTime = getRandomTime();
      }
      console.log("set", set);
    });
  }

  if (set) {
    console.log("CALL TIME WAS VALID TO BEGIN WITH")
    const now = new Date()
    if (callTime < now) {
      return;   //if today's call already happened let it be
    }
    // if today's call is yet to happen fill in everyone's info
  } 

  callTimeRef.set(format(callTime, 'yyyy-MM-dd HH:mm:ss'));

  // 2. if value set start counter + group users in groups of like, 100? less?
  console.log("SCHEDULING USER CALL TIMES STARTING AT: ", callTime);

  let uids: string[] = [];
  const users = db.ref('users');
  const userSnapshot = await users.once('value');
  userSnapshot.forEach((childSnapshot) => {
    var key = childSnapshot.key;
    if (key != null) {
      uids.push(key);
    }
  });

  let userCount: number = 0;
  const groupCap: number = 100; //to avoid too many concurrent users. limit is 100. drop if performance affected

  // want to batch these notifs later.
  //let deviceTokens: string[] = [];

  const notif = new apn.Notification({
    title: "MATCH O'CLOCK 🍵",
    body: "hop on now to meet someone new!",
    sound: "ping.aiff", //default
    topic: "com.chrisbeenchoi.Matcha"
  });

  await uids.forEach(uid => {
    let userCallTimeRef = users.child(uid).child("callTime");
    let userMatchInfoRef = users.child(uid).child("matchInfo");
    userMatchInfoRef.remove();

    let dtRef = users.child(uid).child("deviceToken");
    dtRef.once('value', (snapshot) => {
      const deviceToken = snapshot.val();
      if (deviceToken != null && deviceToken != "") {
        console.log('device token fetched:', deviceToken);
        // user logged in to valid device --> set call time + schedule notif

        // set call time, incremented by 2 minute intervals as needed
        let userCallTime: Date = callTime;
        userCallTime.setMinutes(callTime.getMinutes() + 2 * Math.floor(userCount / groupCap));
        userCallTimeRef.set(format(userCallTime.getTime(), 'yyyy-MM-dd HH:mm:ss'));
        userCount += 1;

        console.log("calltime set for ", uid);

        const cronExpression = `${userCallTime.getMinutes()} ${userCallTime.getHours()} ${userCallTime.getDate()} ${userCallTime.getMonth() + 1} *`;
        console.log("scheduling notif...")
        cron.schedule(cronExpression, () => {
          console.log("TIME TO SEND NOTIF!!!!!!!!")
          apnProvider.send(notif, deviceToken).then( (result) => {
            console.log("NOTIF SENT")
            console.log(result);
          });
        });
        console.log("notif scheduled.")
      }
    });
  });
  console.log("DONE PROCESSING USERS");

  // schedule necessary server functions to run continuously through active interval
  // make this window smaller. a lot of shit going on.
  console.log("preparing active window");
  let startTime = new Date(callTime); //decrement?
  let endTime = new Date(callTime);
  endTime.setMinutes(callTime.getMinutes() + 2 * (userCount/groupCap + 1));
  const cronExpression = `* * ${startTime.getHours()}-${Math.min(23, startTime.getHours()+1)} ${startTime.getDate()} ${startTime.getMonth() + 1} *`;
  cron.schedule(cronExpression, () => {
    matchUsers();
  });
}

// Generates random time to schedule notifs + call window
export function getRandomTime() {
  const now = new Date();

  // between 4pm and 11pm for now. will get messy if active window crosses over midnight
  let hour = Math.floor(Math.random() * 8) + 15;
  let min = Math.floor(Math.random() * 60);

  // also make sure calltime not in past
  if (now.getHours() >= hour) {
    let hourLowerBound = now.getHours() + 2;
    hour = Math.floor(Math.random() * (24 - hourLowerBound)) + hourLowerBound;
  }

  const callTime = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  callTime.setHours(hour);
  callTime.setMinutes(min);
  console.log(format(callTime, 'yyyy-MM-dd HH:mm:ss'));
    
  return callTime;
}

// this function runs every second during active window
// pairs up users and takes them out of pool once matched successfully
export async function matchUsers() {
  const pool = db.ref('matchPool');

  // save all users into an array 
  let uids: string[] = [];

  try {
    const snapshot = await pool.once('value');

    snapshot.forEach((childSnapshot) => {
      var key = childSnapshot.key;
      if (key != null) {
        uids.push(key);
      }
    });

    uids = shuffleArray(uids);

    const users = db.ref('users');

    // test with more than 2 users, odd number of users, users joining while function running
    for (let i = 0; i < uids.length; i += 2) {
      let uid1 = uids.pop();
      let uid2 = uids.pop();
      if (uid1 == null || uid2 == null) return;
      
      const blockRef1 = users.child(uid1).child("blocked").child(uid2);
      const blockRef2 = users.child(uid2).child("blocked").child(uid1);
      
      const blocked1 = await blockRef1.once('value');
      const blocked2 = await blockRef2.once('value');

      let blocked: boolean = blocked1.exists() || blocked2.exists();

      if (!blocked) {
        // use this as unique channel name
        const matchid = uid1+uid2 // right at 64 byte limit
      
        // request tokens from server --> update user nodes
        let url1 = 'http://44.224.156.71:8080/rtc/' + matchid + '/1';
        let url2 = 'http://44.224.156.71:8080/rtc/' + matchid + '/2';

        try {
          const response = await axios.get(url1);
          const token = response.data.rtcToken;
          console.log('Token 1 received:', token);
          users.child(uid1).child("matchInfo").set({ match: uid2, channel: matchid, token: token, channelUid: 1 })
        } catch (error) {
          console.error('Error fetching token 1:', error);
        }

        try {
          const response = await axios.get(url2);
          const token = response.data.rtcToken;
          console.log('Token 2 received:', token);
          users.child(uid2).child("matchInfo").set({ match: uid1, channel: matchid, token: token, channelUid: 2 })
        } catch (error) {
          console.error('Error fetching token 2:', error);
        }

        pool.child(uid1).remove();
        pool.child(uid2).remove();
      }
    }
  } catch (error) {
    console.log(error);
  }
}

function shuffleArray<T>(array: T[]): T[] {
  const shuffledArray = [...array];
  for (let i = shuffledArray.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffledArray[i], shuffledArray[j]] = [shuffledArray[j], shuffledArray[i]];
  }
  return shuffledArray;
}