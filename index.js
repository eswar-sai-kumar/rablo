const express = require('express');

const app = express();

app.get('/', (req, res) => {
  res.send('Hello World');
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`SimpleTimeService running at http://localhost:${PORT}`);
});