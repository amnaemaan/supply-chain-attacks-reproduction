const express = require('express');
const app = express();
const port = 3000;

console.log("Starting victim-app...");

try {
  require('company-internal-logger');
} catch (e) {
  console.error("Error loading company-internal-logger:", e.message);
}

app.get('/', (req, res) => {
  res.send('Hello from the victim app! Check the logs for signs of the attack.');
});

app.listen(port, () => {
  console.log(`Victim app listening at http://localhost:${port}`);
});