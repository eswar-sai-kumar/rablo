const express = require('express');
const moment = require('moment-timezone');

const app = express();

app.get('/', (req, res) => {
  const timestampIST = moment().tz('Asia/Kolkata').format(); // Get current IST time
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;

  res.json({
    timestamp: timestampIST,
    ip: ip
  });
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`SimpleTimeService running at http://localhost:${PORT}`);
});
